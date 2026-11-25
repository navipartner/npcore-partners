#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248580 "NPR Entria Order Import JQ"
{
    Access = Internal;
    Permissions = tabledata "NPR Entria Order Imp. Failure" = rimd;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        StartTime: DateTime;
        MaxDuration: Duration;
    begin
        _EntriaIntegrationMgt.CheckIsEnabled('');
        SetTimeMarkers(StartTime, MaxDuration);
        repeat
            if ShouldSoftExit(Rec.ID) then
                exit;
            ProcessEnabledStores();
            Commit();
            if Rec."Recurring Job" then
                Sleep(1000);
        until (not Rec."Recurring Job") or EcomJobManagement.DurationLimitReached(StartTime, MaxDuration);
    end;

    local procedure SetTimeMarkers(var StartTime: DateTime; var MaxDuration: Duration)
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        StartTime := CurrentDateTime();
        MaxDuration := JobQueueManagement.HoursToDuration(6);
        InitGlobals();
    end;

    local procedure ShouldSoftExit(JobQueueEntryID: Guid): Boolean
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
    begin
        exit(EcomJobManagement.ShouldSoftExit(JobQueueEntryID));
    end;

    internal procedure ProcessEnabledStores()
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        EntriaStore.Reset();
        EntriaStore.ReadIsolation := IsolationLevel::ReadCommitted;
        EntriaStore.SetCurrentKey(Enabled);
        EntriaStore.SetRange(Enabled, true);
        EntriaStore.SetRange("Sales Order Integration", true);
        EntriaStore.SetLoadFields(Code, "Location Code");
        if EntriaStore.FindSet() then
            repeat
                if _EcomJobManagement.ApplicationChanged() then
                    exit;
                ProcessStore(EntriaStore);
            until EntriaStore.Next() = 0;
    end;

    local procedure ProcessStore(EntriaStore: Record "NPR Entria Store")
    var
        ListFetched: Boolean;
    begin
        ListFetched := DownloadOrders(EntriaStore);
        ProcessDueRetries(EntriaStore, ListFetched);
    end;

    local procedure DownloadOrders(EntriaStore: Record "NPR Entria Store"): Boolean
    var
        ExpectedMarkerDT: DateTime;
        WindowStartDT: DateTime;
        Cursor: Text;
        NextCursor: Text;
        PageCount: Integer;
        InvalidCursor: Boolean;
    begin
        InitializeDownloadState(EntriaStore.Code, ExpectedMarkerDT, Cursor, WindowStartDT);

        repeat
            if _EcomJobManagement.ApplicationChanged() then
                exit(false);

            if not DownloadOrdersPage(EntriaStore, Cursor, WindowStartDT, NextCursor, PageCount, InvalidCursor) then
                exit(HandleDownloadFailure(EntriaStore.Code, Cursor, InvalidCursor));

            if _EcomJobManagement.ApplicationChanged() then
                exit(false);

            if not TryFlushCursorState(EntriaStore.Code, ExpectedMarkerDT, Cursor, NextCursor) then
                exit(true);

            Cursor := NextCursor;
        until PageCount < OrderPageSize();

        exit(true);
    end;

    local procedure InitializeDownloadState(StoreCode: Code[20]; var ExpectedMarkerDT: DateTime; var Cursor: Text; var WindowStartDT: DateTime)
    var
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
    begin
        GetSyncState(StoreCode, false, EntriaStoreSyncState);

        ExpectedMarkerDT := EntriaStoreSyncState."Last Orders Imported At";
        Cursor := EntriaStoreSyncState."Order Cursor";

        // GetSyncState may have inserted the row. Do not keep that transaction open
        // while Medusa is holding the long-poll request.
        Commit();

        WindowStartDT := PassWindowStart(ExpectedMarkerDT);
        _SessionMaxBcStatusUpdatedAt.Set(StoreCode, WindowStartDT);
    end;

    local procedure DownloadOrdersPage(EntriaStore: Record "NPR Entria Store"; Cursor: Text; FromDT: DateTime; var NextCursor: Text; var PageCount: Integer; var InvalidCursor: Boolean): Boolean
    var
        OrdersArr: JsonArray;
    begin
        PageCount := 0;

        if not GetOrderList(EntriaStore, OrdersArr, Cursor, OrderPageSize(), FromDT, NextCursor, InvalidCursor) then
            exit(false);

        PageCount := OrdersArr.Count();
        if PageCount = 0 then
            exit(true);

        exit(ProcessList(OrdersArr, EntriaStore));
    end;

    local procedure HandleDownloadFailure(StoreCode: Code[20]; Cursor: Text; InvalidCursor: Boolean): Boolean
    begin
        if InvalidCursor then begin
            ResetCursor(StoreCode, Cursor);
            exit(true);
        end;

        EmitError(StoreCode, '');
        exit(false);
    end;

    local procedure OrderPageSize(): Integer
    begin
        exit(40);
    end;

    internal procedure TryFlushCursorState(StoreCode: Code[20]; var ExpectedMarkerDT: DateTime; RequestCursor: Text; NextCursor: Text): Boolean
    var
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
        SessionMax: DateTime;
        Changed: Boolean;
    begin
        GetSyncState(StoreCode, true, EntriaStoreSyncState);

        if CursorStateChanged(EntriaStoreSyncState, ExpectedMarkerDT, RequestCursor) then begin
            Commit();
            exit(false);
        end;

        SessionMax := _SessionMaxBcStatusUpdatedAt.Get(StoreCode);

        if SessionMax > EntriaStoreSyncState."Last Orders Imported At" then begin
            EntriaStoreSyncState."Last Orders Imported At" := SessionMax;
            Changed := true;
        end;

        if EntriaStoreSyncState."Order Cursor" <> NextCursor then begin
            EntriaStoreSyncState."Order Cursor" := CopyStr(NextCursor, 1, MaxStrLen(EntriaStoreSyncState."Order Cursor"));
            Changed := true;
        end;

        if Changed then
            EntriaStoreSyncState.Modify();

        ExpectedMarkerDT := EntriaStoreSyncState."Last Orders Imported At";

        Commit();
        exit(true);
    end;

    local procedure CursorStateChanged(EntriaStoreSyncState: Record "NPR Entria Store Sync State"; ExpectedMarkerDT: DateTime; RequestCursor: Text): Boolean
    begin
        if EntriaStoreSyncState."Order Cursor" <> RequestCursor then
            exit(true);

        exit(MarkerMoved(EntriaStoreSyncState."Last Orders Imported At", ExpectedMarkerDT));
    end;

    local procedure MarkerMoved(StoredMarkerDT: DateTime; ExpectedMarkerDT: DateTime): Boolean
    begin
        if (StoredMarkerDT = 0DT) or (ExpectedMarkerDT = 0DT) then
            exit(StoredMarkerDT <> ExpectedMarkerDT);

        // SQL Server datetime may differ by ~1-2 ms after read-back.
        // Only a difference of at least one second is considered an external change.
        exit((StoredMarkerDT <= ExpectedMarkerDT - 1000) or (StoredMarkerDT >= ExpectedMarkerDT + 1000));
    end;

    local procedure ResetCursor(StoreCode: Code[20]; RequestCursor: Text)
    var
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
    begin
        GetSyncState(StoreCode, true, EntriaStoreSyncState);

        // Do not overwrite a newer cursor written by another session.
        if EntriaStoreSyncState."Order Cursor" = RequestCursor then begin
            EntriaStoreSyncState."Order Cursor" := '';
            EntriaStoreSyncState.Modify();
        end;

        Commit();
        EmitCursorResetEvent(StoreCode);
    end;

    internal procedure GetSyncStateMarker(StoreCode: Code[20]): DateTime
    var
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
    begin
        GetSyncState(StoreCode, false, EntriaStoreSyncState);
        exit(EntriaStoreSyncState."Last Orders Imported At");
    end;

    local procedure GetSyncState(StoreCode: Code[20]; LockRow: Boolean; var EntriaStoreSyncState: Record "NPR Entria Store Sync State")
    begin
        if LockRow then
            EntriaStoreSyncState.ReadIsolation := IsolationLevel::UpdLock;
        if EntriaStoreSyncState.Get(StoreCode) then
            exit;

        EntriaStoreSyncState.Init();
        EntriaStoreSyncState."Store Code" := StoreCode;
        if not EntriaStoreSyncState.Insert() then
            EntriaStoreSyncState.Get(StoreCode);
    end;

    internal procedure GetOrderList(EntriaStore: Record "NPR Entria Store"; var OrdersArr: JsonArray; Cursor: Text; Limit: Integer; BcStatusUpdatedAtFrom: DateTime; var NextCursor: Text; var InvalidCursor: Boolean): Boolean
    var
        EntriaResponse: JsonToken;
        ResponseText: Text;
        HttpStatusCode: Integer;
    begin
        Clear(OrdersArr);
        Clear(NextCursor);
        InvalidCursor := false;

        if not SendOrderListRequest(EntriaStore, Cursor, Limit, BcStatusUpdatedAtFrom, EntriaResponse, HttpStatusCode, ResponseText) then begin
            InvalidCursor := IsInvalidCursorResponse(Cursor, HttpStatusCode, ResponseText);
            exit(false);
        end;

        if not TryGetOrdersArray(EntriaResponse, OrdersArr) then
            exit(false);

        if not TryGetNextCursor(EntriaResponse, NextCursor) then
            exit(false);

        exit(TryCheckCursorAdvanced(Cursor, NextCursor, OrdersArr.Count(), Limit));
    end;

    local procedure SendOrderListRequest(EntriaStore: Record "NPR Entria Store"; Cursor: Text; Limit: Integer; BcStatusUpdatedAtFrom: DateTime; var EntriaResponse: JsonToken; var HttpStatusCode: Integer; var ResponseText: Text): Boolean
    var
        Request: Text;
    begin
        Request := GenerateGetOrderListRequest(Cursor, Limit, BcStatusUpdatedAtFrom);
        exit(_EntriaAPIHandler.SendEntriaRequest(EntriaStore.Code, Request, Enum::"Http Request Type"::GET, ListRequestTimeout(), EntriaResponse, HttpStatusCode, ResponseText));
    end;

    local procedure IsInvalidCursorResponse(Cursor: Text; HttpStatusCode: Integer; ResponseText: Text): Boolean
    var
        InvalidCursorMsgTxt: Label 'Invalid ''after'' cursor', Locked = true;
    begin
        exit((Cursor <> '') and (HttpStatusCode = 400) and ResponseText.Contains(InvalidCursorMsgTxt));
    end;

    internal procedure ListRequestTimeout(): Duration
    begin
        // Medusa may keep an idle request open for up to 115 seconds.
        // Keep a 15-second margin for transport and response processing.
        exit(130 * 1000);
    end;

    [TryFunction]
    local procedure TryGetOrdersArray(EntriaResponse: JsonToken; var OrdersArr: JsonArray)
    var
        OrdersToken: JsonToken;
        NoOrdersArrayErr: Label 'The Entria order list request succeeded but its response contains no "orders" array, so the importer cannot tell an empty page from a broken payload.', Locked = true;
    begin
        if not EntriaResponse.SelectToken('orders', OrdersToken) then
            Error(NoOrdersArrayErr);

        if not OrdersToken.IsArray() then
            Error(NoOrdersArrayErr);

        OrdersArr := OrdersToken.AsArray();
    end;

    [TryFunction]
    local procedure TryGetNextCursor(EntriaResponse: JsonToken; var NextCursor: Text)
    var
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
        NextToken: JsonToken;
        RawNext: Text;
        NoNextCursorErr: Label 'The Entria order list request succeeded but its response contains no usable "next" cursor (missing, null, not a non-empty string, or longer than %1 characters), so the importer cannot continue from this page.', Comment = '%1 - maximum cursor length', Locked = true;
    begin
        if EntriaResponse.SelectToken('next', NextToken) then
            if NextToken.IsValue() then
                if not NextToken.AsValue().IsNull() then begin
                    NextToken.WriteTo(RawNext);
                    if RawNext.StartsWith('"') then
                        RawNext := NextToken.AsValue().AsText()
                    else
                        RawNext := '';
                end;

        if (RawNext = '') or (StrLen(RawNext) > MaxStrLen(EntriaStoreSyncState."Order Cursor")) then
            Error(NoNextCursorErr, MaxStrLen(EntriaStoreSyncState."Order Cursor"));

        NextCursor := RawNext;
    end;

    [TryFunction]
    local procedure TryCheckCursorAdvanced(Cursor: Text; NextCursor: Text; PageCount: Integer; Limit: Integer)
    var
        CursorNotAdvancedErr: Label 'The Entria order list returned a full page but the same "next" cursor it was called with, so fetching again would serve the same page forever.', Locked = true;
    begin
        // An empty or short page with the same cursor is the normal idle answer.
        if (PageCount >= Limit) and (NextCursor = Cursor) then
            Error(CursorNotAdvancedErr);
    end;

    internal procedure GenerateGetOrderListRequest(Cursor: Text; Limit: Integer; BcStatusUpdatedAtFrom: DateTime): Text
    var
        WindowText: Text;
    begin
        if (Cursor = '') and (BcStatusUpdatedAtFrom <> 0DT) then
            WindowText := StrSubstNo('&bc_status_updated_at[$gte]=%1', Format(BcStatusUpdatedAtFrom, 0, 9));

        exit(StrSubstNo('admin/orders/bc-sync?after=%1&bc_status=pending%2&limit=%3&%4', Cursor, WindowText, Limit, GetOrderFieldsProjection()));
    end;

    local procedure GetOrderFieldsProjection(): Text
    begin
        exit('fields=-summary,+billing_address.*,+shipping_address.*,+shipping_methods.name,+currency_code,+email,+payment_collections.payments.*');
    end;

    /// <summary>
    /// Start of the time filter, which is only sent on a first call or after a cursor reset. Later
    /// pages follow the cursor, so the overlap is applied once per reset, never per page.
    /// </summary>
    internal procedure PassWindowStart(MarkerDT: DateTime): DateTime
    begin
        if MarkerDT = 0DT then
            exit(0DT);

        exit(MarkerDT - PropagationOverlap());
    end;

    internal procedure PropagationOverlap(): Duration
    begin
        exit(30 * 1000);
    end;

    local procedure NextFilterChunk(Values: List of [Text]; var NextIndex: Integer; var FilterTxt: Text): Boolean
    var
        Value: Text;
    begin
        FilterTxt := '';
        while NextIndex <= Values.Count() do begin
            Value := Values.Get(NextIndex);
            if (FilterTxt <> '') and (StrLen(FilterTxt) + 1 + StrLen(Value) > MaxFilterLength()) then
                exit(true);

            NextIndex += 1;
            if FilterTxt <> '' then
                FilterTxt += '|';
            FilterTxt += Value;
        end;
        exit(FilterTxt <> '');
    end;

    internal procedure MaxFilterLength(): Integer
    begin
        // Comfortably inside AL's filter expression cap, with room left for the field name and the
        // platform's own overhead. 
        exit(1800);
    end;

    local procedure ToTextList(Values: List of [Code[20]]) TextValues: List of [Text]
    var
        Value: Code[20];
    begin
        foreach Value in Values do
            TextValues.Add(Value);
    end;

    local procedure GetExistingEcomDocsForBatch(DocumentNos: Dictionary of [Code[20], Boolean]; var ExistingDocs: Dictionary of [Code[20], Boolean]; EntriaStoreCode: Code[20])
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Values: List of [Text];
        FilterTxt: Text;
        NextIndex: Integer;
    begin
        Clear(ExistingDocs);
        Values := ToTextList(DocumentNos.Keys());
        NextIndex := 1;

        while NextFilterChunk(Values, NextIndex, FilterTxt) do begin
            EcomSalesHeader.Reset();
            EcomSalesHeader.ReadIsolation := IsolationLevel::ReadCommitted;
            EcomSalesHeader.SetRange("Document Type", EcomSalesHeader."Document Type"::Order);
            EcomSalesHeader.SetRange("Ecommerce Store Code", EntriaStoreCode);
            EcomSalesHeader.SetFilter("External No.", FilterTxt);
            EcomSalesHeader.SetLoadFields("External No.");
            if EcomSalesHeader.FindSet() then
                repeat
                    if not ExistingDocs.ContainsKey(EcomSalesHeader."External No.") then
                        ExistingDocs.Add(EcomSalesHeader."External No.", true);
                until EcomSalesHeader.Next() = 0;
        end;
    end;

    local procedure GetFailedOrderIdsForBatch(OrderIds: Dictionary of [Text, Boolean]; var FailedOrderIds: Dictionary of [Text, Boolean]; EntriaStoreCode: Code[20])
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        Values: List of [Text];
        FilterTxt: Text;
        NextIndex: Integer;
    begin
        Clear(FailedOrderIds);
        Values := OrderIds.Keys();
        NextIndex := 1;

        while NextFilterChunk(Values, NextIndex, FilterTxt) do begin
            EntriaOrderImpFailure.Reset();
            EntriaOrderImpFailure.ReadIsolation := IsolationLevel::ReadCommitted;
            EntriaOrderImpFailure.SetRange("Store Code", EntriaStoreCode);
            EntriaOrderImpFailure.SetFilter("Order Id", FilterTxt);
            EntriaOrderImpFailure.SetLoadFields("Order Id");
            if EntriaOrderImpFailure.FindSet() then
                repeat
                    if not FailedOrderIds.ContainsKey(EntriaOrderImpFailure."Order Id") then
                        FailedOrderIds.Add(EntriaOrderImpFailure."Order Id", true);
                until EntriaOrderImpFailure.Next() = 0;
        end;
    end;

    internal procedure ProcessList(OrdersArr: JsonArray; EntriaStore: Record "NPR Entria Store"): Boolean
    var
        OrderIds: Dictionary of [Text, Boolean];
        DocumentNos: Dictionary of [Code[20], Boolean];
        ExistingDocs: Dictionary of [Code[20], Boolean];
        FailedOrderIds: Dictionary of [Text, Boolean];
        BcStatusUpdatedAts: Dictionary of [Text, DateTime];
        OrderTkn: JsonToken;
        i: Integer;
    begin
        if not TryCollectPageKeys(OrdersArr, OrderIds, DocumentNos, BcStatusUpdatedAts) then
            exit(false);

        if OrderIds.Count() = 0 then
            exit(true);

        GetExistingEcomDocsForBatch(DocumentNos, ExistingDocs, EntriaStore.Code);
        GetFailedOrderIdsForBatch(OrderIds, FailedOrderIds, EntriaStore.Code);

        for i := 0 to OrdersArr.Count() - 1 do begin
            OrdersArr.Get(i, OrderTkn);
            ProcessListOrder(OrderTkn, ExistingDocs, FailedOrderIds, BcStatusUpdatedAts, EntriaStore);
        end;

        exit(true);
    end;

    [TryFunction]
    local procedure TryCollectPageKeys(OrdersArr: JsonArray; var OrderIds: Dictionary of [Text, Boolean]; var DocumentNos: Dictionary of [Code[20], Boolean]; var BcStatusUpdatedAts: Dictionary of [Text, DateTime])
    var
        OrderTkn: JsonToken;
        OrderId: Text[100];
        DocumentNo: Code[20];
        i: Integer;
    begin
        Clear(OrderIds);
        Clear(DocumentNos);
        Clear(BcStatusUpdatedAts);

        for i := 0 to OrdersArr.Count() - 1 do begin
            OrdersArr.Get(i, OrderTkn);

            OrderId := GetMedusaOrderId(OrderTkn);
            if not OrderIds.ContainsKey(OrderId) then
                OrderIds.Add(OrderId, true);

            if not BcStatusUpdatedAts.ContainsKey(OrderId) then
                BcStatusUpdatedAts.Add(OrderId, GetOrderBcStatusUpdatedAt(OrderTkn));

            DocumentNo := GetDocumentNo(OrderTkn);
            if DocumentNo <> '' then
                if not DocumentNos.ContainsKey(DocumentNo) then
                    DocumentNos.Add(DocumentNo, true);
        end;
    end;

    local procedure ProcessListOrder(OrderTkn: JsonToken; ExistingDocs: Dictionary of [Code[20], Boolean]; FailedOrderIds: Dictionary of [Text, Boolean]; BcStatusUpdatedAts: Dictionary of [Text, DateTime]; EntriaStore: Record "NPR Entria Store")
    var
        DocumentNo: Code[20];
        OrderId: Text[100];
        OrderBcStatusUpdatedAt: DateTime;
        OrderUpdatedAt: DateTime;
        DisplayNo: Integer;
    begin
        if _EcomJobManagement.ApplicationChanged() then
            exit;

        OrderId := GetMedusaOrderId(OrderTkn);
        // Taken from the page's pre-validated set, not re-read here: the Required read already
        // happened inside TryCollectPageKeys, where a missing field rejects the page instead of
        // erroring out of this unguarded chain.
        BcStatusUpdatedAts.Get(OrderId, OrderBcStatusUpdatedAt);
        UpdateSessionMaxBcStatusUpdatedAt(EntriaStore.Code, OrderBcStatusUpdatedAt);
        if FailedOrderIds.ContainsKey(OrderId) then
            exit;

        OrderUpdatedAt := GetOrderUpdatedAt(OrderTkn);
        DisplayNo := GetDisplayNo(OrderTkn);

        if not TryGetDocumentNo(OrderTkn, DocumentNo) then begin
            LogOrderFailure(EntriaStore, '', OrderId, OrderUpdatedAt, GetLastErrorText(), DisplayNo);
            Commit();
            exit;
        end;

        if ExistingDocs.ContainsKey(DocumentNo) then
            exit;

        ProcessOrder(EntriaStore, OrderTkn, DocumentNo, OrderId, OrderUpdatedAt, DisplayNo);
        Commit();
    end;

    local procedure GetOrderBcStatusUpdatedAt(OrderTkn: JsonToken) BcStatusUpdatedAt: DateTime
    var
        InvalidBcStatusUpdatedAtErr: Label 'Property %1 has incorrect value: %2.', Comment = '%1 - absolute path, %2 - value', Locked = true;
    begin
        BcStatusUpdatedAt := _JsonHelper.GetJDT(OrderTkn, 'bc_status_updated_at', true);
        if BcStatusUpdatedAt = 0DT then
            Error(InvalidBcStatusUpdatedAtErr, _JsonHelper.GetAbsolutePath(OrderTkn, 'bc_status_updated_at'), BcStatusUpdatedAt);
    end;

    local procedure GetOrderUpdatedAt(OrderTkn: JsonToken): DateTime
    begin
        exit(_JsonHelper.GetJDT(OrderTkn, 'updated_at', true));
    end;

    internal procedure ProcessOrder(EntriaStore: Record "NPR Entria Store"; OrderTkn: JsonToken; DocumentNo: Code[20]; MedusaOrderId: Text[100]; OrderUpdatedAt: DateTime; DisplayNo: Integer): Boolean
    var
        EntriaOrderProcessor: Codeunit "NPR Entria Order Processor";
        EcomSalesDocApiAgent: Codeunit "NPR EcomSalesDocApiAgentV2";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        ClearLastError();
        Clear(EntriaOrderProcessor);
        EntriaOrderProcessor.SetParams(OrderTkn, EntriaStore, DocumentNo);
        Commit();
        if EntriaOrderProcessor.Run(EcomSalesHeader) then begin
            if EcomSalesHeader."Bucket Id" = 0 then
                EcomSalesDocApiAgent.AssignBucketId(EcomSalesHeader);
            DeleteOrderFailure(EntriaStore.Code, MedusaOrderId);
            exit(true);
        end;

        LogOrderFailure(EntriaStore, DocumentNo, MedusaOrderId, OrderUpdatedAt, GetLastErrorText(), DisplayNo);
        exit(false);
    end;

    [TryFunction]
    local procedure TryGetDocumentNo(OrderTkn: JsonToken; var DocumentNo: Code[20])
    var
        MissingDocumentNoErr: Label 'The Entria order payload contains no non-empty custom_display_id.', Locked = true;
    begin
#pragma warning disable AA0139
        DocumentNo := _JsonHelper.GetJText(OrderTkn, 'custom_display_id', true);
#pragma warning restore AA0139
        if DocumentNo = '' then
            Error(MissingDocumentNoErr);
    end;

    local procedure GetDocumentNo(OrderTkn: JsonToken): Code[20]
    var
        DocumentNo: Code[20];
    begin
        if TryGetDocumentNo(OrderTkn, DocumentNo) then
            exit(DocumentNo);
        exit('');
    end;

    [TryFunction]
    local procedure TryGetDisplayNo(OrderTkn: JsonToken; var DisplayNo: Integer)
    begin
        DisplayNo := _JsonHelper.GetJInteger(OrderTkn, 'display_id', false);
    end;

    local procedure GetDisplayNo(OrderTkn: JsonToken): Integer
    var
        DisplayNo: Integer;
    begin
        if TryGetDisplayNo(OrderTkn, DisplayNo) then
            exit(DisplayNo);
        exit(0);
    end;

    local procedure GetMedusaOrderId(OrderTkn: JsonToken): Text[100]
    begin
#pragma warning disable AA0139
        exit(_JsonHelper.GetJText(OrderTkn, 'id', 100, true));
#pragma warning restore AA0139
    end;

    #region markers
    local procedure UpdateSessionMaxBcStatusUpdatedAt(StoreCode: Code[20]; BcStatusUpdatedAt: DateTime)
    var
        CurrentMax: DateTime;
    begin
        CurrentMax := _SessionMaxBcStatusUpdatedAt.Get(StoreCode);
        if BcStatusUpdatedAt > CurrentMax then
            _SessionMaxBcStatusUpdatedAt.Set(StoreCode, BcStatusUpdatedAt);
    end;

    internal procedure GetSessionMaxBcStatusUpdatedAt(StoreCode: Code[20]): DateTime
    begin
        exit(_SessionMaxBcStatusUpdatedAt.Get(StoreCode));
    end;

    internal procedure SeedSessionMax(StoreCode: Code[20])
    begin
        // Same seed as DownloadOrders: the pass start, overlap included. It sits below the stored
        // marker, so only a consumed order can move the marker forward on flush.
        _SessionMaxBcStatusUpdatedAt.Set(StoreCode, PassWindowStart(GetSyncStateMarker(StoreCode)));
    end;
    #endregion

    local procedure ShouldEmitSentryError(StoreCode: Code[20]): Boolean
    begin
        exit(ShouldEmitSentryError(StoreCode, CurrentDateTime()));
    end;

    /// <summary>
    /// One-hour dedup for the store-wide list-fetch failure
    /// </summary>
    internal procedure ShouldEmitSentryError(StoreCode: Code[20]; NowDT: DateTime): Boolean
    begin
        exit(ShouldEmitForKey(StrSubstNo('%1|<list-fetch>', StoreCode), NowDT));
    end;

    local procedure EmitSentryError(StoreCode: Code[20]; OrderRef: Text)
    var
        Sentry: Codeunit "NPR Sentry";
        TransactionName: Text;
    begin
        if OrderRef <> '' then
            TransactionName := StrSubstNo('Entria Order import failed: %1', OrderRef)
        else
            TransactionName := StrSubstNo('Entria Order list fetch failed: %1', StoreCode);

        Sentry.InitScopeAndTransaction(TransactionName, 'bc.entria.order.import.error');
        Sentry.AddTransactionTag('entria.store_code', StoreCode);
        Sentry.AddLastErrorInEnglish();
        Sentry.FinalizeScope();
    end;

    local procedure EmitError(StoreCode: Code[20]; DocumentNo: Code[20])
    begin
        if ShouldEmitSentryError(StoreCode) then
            EmitSentryError(StoreCode, DocumentNo);
    end;

    local procedure ShouldEmitCursorResetEvent(StoreCode: Code[20]): Boolean
    begin
        exit(ShouldEmitCursorResetEvent(StoreCode, CurrentDateTime()));
    end;

    /// <summary>
    /// One-hour dedup for the cursor reset, kept apart from the list-fetch key so neither hides the other.
    /// </summary>
    internal procedure ShouldEmitCursorResetEvent(StoreCode: Code[20]; NowDT: DateTime): Boolean
    begin
        exit(ShouldEmitForKey(StrSubstNo('%1|<cursor-reset>', StoreCode), NowDT));
    end;

    local procedure ShouldEmitForKey(DKey: Text; NowDT: DateTime): Boolean
    var
        LastEmitAt: DateTime;
        OneHour: Duration;
    begin
        OneHour := 60 * 60 * 1000;

        if not _LastErrorEmitAt.ContainsKey(DKey) then begin
            _LastErrorEmitAt.Add(DKey, NowDT);
            exit(true);
        end;

        LastEmitAt := _LastErrorEmitAt.Get(DKey);
        if NowDT - LastEmitAt < OneHour then
            exit(false);

        _LastErrorEmitAt.Set(DKey, NowDT);
        exit(true);
    end;

    local procedure EmitCursorResetEvent(StoreCode: Code[20])
    var
        Sentry: Codeunit "NPR Sentry";
        CursorResetTxt: Label 'Entria order cursor reset: %1', Comment = '%1 - store code', Locked = true;
    begin
        if not ShouldEmitCursorResetEvent(StoreCode) then
            exit;

        Sentry.InitScopeAndTransaction(StrSubstNo(CursorResetTxt, StoreCode), 'bc.entria.order.import.error');
        Sentry.AddTransactionTag('entria.store_code', StoreCode);
        Sentry.AddLastErrorInEnglish();
        Sentry.FinalizeScope();
    end;

    local procedure InitGlobals()
    begin
        Clear(_SessionMaxBcStatusUpdatedAt);
        Clear(_LastErrorEmitAt);
    end;

    #region order failure registry
    local procedure LogOrderFailure(EntriaStore: Record "NPR Entria Store"; DocumentNo: Code[20]; MedusaOrderId: Text[100]; OrderUpdatedAt: DateTime; ErrorText: Text; DisplayNo: Integer)
    var
        NewRetryCount: Integer;
    begin
        NewRetryCount := UpsertOrderFailure(EntriaStore.Code, DocumentNo, MedusaOrderId, OrderUpdatedAt, ErrorText, DisplayNo, CurrentDateTime());
        if ShouldEmitSentryErrorForOrder(NewRetryCount) then
            if DocumentNo <> '' then
                EmitSentryError(EntriaStore.Code, DocumentNo)
            else
                EmitSentryError(EntriaStore.Code, MedusaOrderId);
    end;

    internal procedure UpsertOrderFailure(StoreCode: Code[20]; DocumentNo: Code[20]; MedusaOrderId: Text[100]; OrderUpdatedAt: DateTime; ErrorText: Text; DisplayNo: Integer; NowDT: DateTime) RetryCount: Integer
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
    begin
        EntriaOrderImpFailure.ReadIsolation := IsolationLevel::UpdLock;

        if not EntriaOrderImpFailure.Get(StoreCode, MedusaOrderId) then begin
            EntriaOrderImpFailure.Init();
            EntriaOrderImpFailure."Store Code" := StoreCode;
            EntriaOrderImpFailure."Order Id" := MedusaOrderId;
            SetFailureFields(EntriaOrderImpFailure, DocumentNo, OrderUpdatedAt, ErrorText, DisplayNo, NowDT);
            if EntriaOrderImpFailure.Insert() then
                exit(EntriaOrderImpFailure."Retry Count");

            EntriaOrderImpFailure.Get(StoreCode, MedusaOrderId);
            exit(EntriaOrderImpFailure."Retry Count");
        end;

        EntriaOrderImpFailure."Retry Count" += 1;
        SetFailureFields(EntriaOrderImpFailure, DocumentNo, OrderUpdatedAt, ErrorText, DisplayNo, NowDT);
        EntriaOrderImpFailure.Modify();
        exit(EntriaOrderImpFailure."Retry Count");
    end;

    local procedure SetFailureFields(var EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure"; DocumentNo: Code[20]; OrderUpdatedAt: DateTime; ErrorText: Text; DisplayNo: Integer; NowDT: DateTime)
    begin
        if DocumentNo <> '' then
            EntriaOrderImpFailure."Document No." := DocumentNo;
        EntriaOrderImpFailure."Order Updated At" := OrderUpdatedAt;
        if DisplayNo <> 0 then
            EntriaOrderImpFailure."Display No." := DisplayNo;
        EntriaOrderImpFailure."Last Error" := CopyStr(ErrorText, 1, MaxStrLen(EntriaOrderImpFailure."Last Error"));
        if EntriaOrderImpFailure."Retry Count" < MaxRetries() then
            EntriaOrderImpFailure."Next Retry At" := NowDT + BackoffDuration(EntriaOrderImpFailure."Retry Count" + 1)
        else
            EntriaOrderImpFailure."Next Retry At" := 0DT;
        ApplyRetryBudgetStatus(EntriaOrderImpFailure);
    end;

    local procedure ApplyRetryBudgetStatus(var EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure")
    begin
        if EntriaOrderImpFailure.Status = EntriaOrderImpFailure.Status::Skipped then
            exit;

        if EntriaOrderImpFailure."Retry Count" < MaxRetries() then
            EntriaOrderImpFailure.Status := EntriaOrderImpFailure.Status::Pending
        else
            EntriaOrderImpFailure.Status := EntriaOrderImpFailure.Status::Error;
    end;

    internal procedure DeleteOrderFailure(StoreCode: Code[20]; OrderId: Text[100])
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
    begin
        EntriaOrderImpFailure.ReadIsolation := IsolationLevel::UpdLock;
        if EntriaOrderImpFailure.Get(StoreCode, OrderId) then
            EntriaOrderImpFailure.Delete();
    end;

    internal procedure ShouldEmitSentryErrorForOrder(RetryCount: Integer): Boolean
    begin
        exit(RetryCount = MaxRetries());
    end;

    internal procedure MaxRetries(): Integer
    begin
        exit(10);
    end;

    internal procedure BackoffDuration(RetryNumber: Integer): Duration
    var
        InvalidRetryNumberErr: Label 'Retry number %1 is outside the supported Entria order retry range. This is a programming bug.', Locked = true;
    begin
        case RetryNumber of
            1:
                exit(5 * 1000);
            2:
                exit(10 * 1000);
            3:
                exit(15 * 1000);
            4:
                exit(20 * 1000);
            5:
                exit(30 * 1000);
            6:
                exit(40 * 1000);
            7:
                exit(60 * 1000);
            8:
                exit(90 * 1000);
            9:
                exit((2 * 60 + 30) * 1000);
            10:
                exit(3 * 60 * 1000);
            else
                Error(InvalidRetryNumberErr, RetryNumber);
        end;
    end;
    #endregion

    internal procedure MarkOrderForRetry(var EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure")
    begin
        EntriaOrderImpFailure."Retry Count" := 0;
        EntriaOrderImpFailure."Next Retry At" := CurrentDateTime();
        EntriaOrderImpFailure.Status := EntriaOrderImpFailure.Status::Pending;
    end;

    internal procedure SkipOrder(var EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure")
    begin
        EntriaOrderImpFailure.Status := EntriaOrderImpFailure.Status::Skipped;
    end;


    #region bounded retry of registered failures

    internal procedure ProcessDueRetries(EntriaStore: Record "NPR Entria Store"; ListFetched: Boolean)
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        DueOrderIds: List of [Text];
        OrderId: Text;
    begin
        // A Medusa outage that failed the store-wide list fetch also means retries are pointless right now
        if not ListFetched then
            exit;

        CollectDueRetries(EntriaStore.Code, DueOrderIds);

        foreach OrderId in DueOrderIds do begin
            if _EcomJobManagement.ApplicationChanged() then
                exit;
            if EntriaOrderImpFailure.Get(EntriaStore.Code, OrderId) then
                if IsRetryDue(EntriaOrderImpFailure) then begin
                    ProcessDueRetry(EntriaStore, EntriaOrderImpFailure);
                    Commit();
                end;
        end;
    end;

    local procedure CollectDueRetries(StoreCode: Code[20]; var DueOrderIds: List of [Text])
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
    begin
        Clear(DueOrderIds);

        EntriaOrderImpFailure.SetCurrentKey(Status, "Next Retry At");
        EntriaOrderImpFailure.SetRange("Store Code", StoreCode);
        EntriaOrderImpFailure.SetRange(Status, EntriaOrderImpFailure.Status::Pending);
        EntriaOrderImpFailure.SetFilter("Retry Count", '<%1', MaxRetries());
        EntriaOrderImpFailure.SetFilter("Next Retry At", '<>%1&<=%2', 0DT, CurrentDateTime());
        if not EntriaOrderImpFailure.FindSet() then
            exit;

        repeat
            DueOrderIds.Add(EntriaOrderImpFailure."Order Id");
        until (EntriaOrderImpFailure.Next() = 0) or (DueOrderIds.Count() >= MaxRetryRowsPerCycle());
    end;

    internal procedure IsRetryDue(EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure"): Boolean
    begin
        exit((EntriaOrderImpFailure.Status = EntriaOrderImpFailure.Status::Pending) and (EntriaOrderImpFailure."Retry Count" < MaxRetries())
              and (EntriaOrderImpFailure."Next Retry At" <> 0DT) and (EntriaOrderImpFailure."Next Retry At" <= CurrentDateTime()));
    end;

    internal procedure IsOrderDueForIdBasedRetry(StoreCode: Code[20]; OrderId: Text): Boolean
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
        DueOrderIds: List of [Text];
    begin
        CollectDueRetries(StoreCode, DueOrderIds);
        if not DueOrderIds.Contains(OrderId) then
            exit(false);
        if not EntriaOrderImpFailure.Get(StoreCode, OrderId) then
            exit(false);
        exit(IsRetryDue(EntriaOrderImpFailure));
    end;

    local procedure MaxRetryRowsPerCycle(): Integer
    begin
        exit(20);
    end;

    local procedure ProcessDueRetry(EntriaStore: Record "NPR Entria Store"; EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure")
    var
        OrderTkn: JsonToken;
        DocumentNo: Code[20];
        OrderUpdatedAt: DateTime;
        DisplayNo: Integer;
        ErrorText: Text;
    begin
        if not GetSingleOrder(EntriaStore, EntriaOrderImpFailure."Order Id", OrderTkn) then begin
            ErrorText := GetLastErrorText();
            LogOrderFailure(EntriaStore, EntriaOrderImpFailure."Document No.", EntriaOrderImpFailure."Order Id", EntriaOrderImpFailure."Order Updated At", ErrorText, EntriaOrderImpFailure."Display No.");
            exit;
        end;
        OrderUpdatedAt := GetOrderUpdatedAt(OrderTkn);
        if IsPayloadFresher(OrderUpdatedAt, EntriaOrderImpFailure."Order Updated At") then
            ReArmOnFresherPayload(EntriaOrderImpFailure."Store Code", EntriaOrderImpFailure."Order Id", OrderUpdatedAt);

        DisplayNo := GetDisplayNo(OrderTkn);
        if not TryGetDocumentNo(OrderTkn, DocumentNo) then begin
            ErrorText := GetLastErrorText();
            LogOrderFailure(EntriaStore, '', EntriaOrderImpFailure."Order Id", OrderUpdatedAt, ErrorText, DisplayNo);
            exit;
        end;

        ProcessOrder(EntriaStore, OrderTkn, DocumentNo, EntriaOrderImpFailure."Order Id", OrderUpdatedAt, DisplayNo);
    end;

    internal procedure ReArmOnFresherPayload(StoreCode: Code[20]; OrderId: Text[100]; OrderUpdatedAt: DateTime)
    var
        EntriaOrderImpFailure: Record "NPR Entria Order Imp. Failure";
    begin
        EntriaOrderImpFailure.ReadIsolation := IsolationLevel::UpdLock;
        if not EntriaOrderImpFailure.Get(StoreCode, OrderId) then
            exit;
        if EntriaOrderImpFailure.Status <> EntriaOrderImpFailure.Status::Pending then
            exit;

        EntriaOrderImpFailure."Retry Count" := 0;
        EntriaOrderImpFailure."Order Updated At" := OrderUpdatedAt;
        EntriaOrderImpFailure.Modify();
    end;

    /// <summary>
    /// The row's timestamp passed through SQL's 1/300s datetime grid and can read back up to 2ms
    /// below what was written, while the payload value is freshly parsed at full precision. Without
    /// the slack an unmodified order looks fresher on every retry and its budget resets forever,
    /// never reaching parking. 10ms covers the rounding error and stays far below any real edit.
    /// </summary>
    internal procedure IsPayloadFresher(PayloadUpdatedAt: DateTime; RowUpdatedAt: DateTime): Boolean
    begin
        // Adding to 0DT would underflow the minimum date, so compare directly.
        if RowUpdatedAt = 0DT then
            exit(PayloadUpdatedAt <> 0DT);

        exit(PayloadUpdatedAt > (RowUpdatedAt + 10));
    end;

    local procedure GetSingleOrder(EntriaStore: Record "NPR Entria Store"; MedusaOrderId: Text[100]; var OrderTkn: JsonToken): Boolean
    var
        EntriaResponse: JsonToken;
        Request: Text;
    begin
        Clear(OrderTkn);
        Request := GenerateGetSingleOrderRequest(MedusaOrderId);
        if not _EntriaAPIHandler.SendEntriaRequest(EntriaStore.Code, Request, Enum::"Http Request Type"::GET, EntriaResponse) then
            exit(false);

        exit(TryGetSingleOrderToken(EntriaResponse, MedusaOrderId, OrderTkn));
    end;

    [TryFunction]
    local procedure TryGetSingleOrderToken(EntriaResponse: JsonToken; ExpectedOrderId: Text[100]; var OrderTkn: JsonToken)
    var
        OrderToken: JsonToken;
        ActualOrderId: Text;
        WrongOrderErr: Label 'The single-order response for Medusa order %1 did not contain that order (envelope/id mismatch; response carried id "%2").', Locked = true;
    begin
        if EntriaResponse.SelectToken('order', OrderToken) then
            OrderTkn := OrderToken
        else
            OrderTkn := EntriaResponse;

        ActualOrderId := _JsonHelper.GetJText(OrderTkn, 'id', 100, false);
        if ActualOrderId <> ExpectedOrderId then
            Error(WrongOrderErr, ExpectedOrderId, ActualOrderId);
    end;

    internal procedure GenerateGetSingleOrderRequest(MedusaOrderId: Text[100]): Text
    begin
        exit(StrSubstNo('admin/orders/%1?%2', MedusaOrderId, GetOrderFieldsProjection()));
    end;
    #endregion

    internal procedure SetupJobQueue(Enable: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        if not Enable then begin
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, GetCodeunitId());
            RemoveOrphanedMonitoredJQEntries();
            exit;
        end;

        //Purge before creating, never after: if the registration below is ever reached with a blank job queue
        //entry, a purge running afterwards would judge the row it had just created to be orphaned and delete it.
        RemoveOrphanedMonitoredJQEntries();

        JobQueueMgt.SetJobTimeout(7, 0);
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 30, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit, GetCodeunitId(),
            '', GetJQDescription(),
            CreateDateTime(Today(), 070000T), 1,
            '', JobQueueEntry)
        then begin
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
            if not IsNullGuid(JobQueueEntry.ID) then
                MonitoredJQMgt.AssignJobQueueEntryToManagedAndMonitored(false, true, JobQueueEntry);
        end;
    end;

    /// <summary>
    /// Tells whether the order import job queue entry exists and is in a status that gets picked up and run.
    /// </summary>
    /// <remarks>
    /// A query rather than a value returned by SetupJobQueue: a manually held entry, or one created by a session
    /// that may not schedule tasks, is registered and monitored while importing nothing, so callers reporting to
    /// a user must ask the entry rather than the master switch.
    /// </remarks>
    internal procedure IsJobQueueReadyToRun(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", GetCodeunitId());
        JobQueueEntry.SetFilter(Status, '%1|%2', JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process");
        exit(not JobQueueEntry.IsEmpty());
    end;

    /// <summary>
    /// Deletes monitored job queue entries for this codeunit whose related job queue entry no longer exists.
    /// Deleting an entry removes only its "NPR Managed By App Job Queue" row, and RemoveMonitoredJobQueueEntry()
    /// can only match on the job queue entry ID, so such a row is reachable by object identity alone - and nothing
    /// cleans it up automatically. Left behind it fails the refresher on every cycle with "Related job queue entry
    /// could not be found", stamped on the row as Last Refresh Status = Error.
    /// </summary>
    local procedure RemoveOrphanedMonitoredJQEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        MonitoredJQEntry.SetCurrentKey("Object ID to Run", "Object Type to Run");
        MonitoredJQEntry.SetRange("Object ID to Run", GetCodeunitId());
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        if not MonitoredJQEntry.FindSet(true) then
            exit;
        repeat
            if not JobQueueEntry.Get(MonitoredJQEntry."Job Queue Entry ID") then
                MonitoredJQEntry.Delete(true);
        until MonitoredJQEntry.Next() = 0;
    end;

    internal procedure GetCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Entria Order Import JQ");
    end;

    internal procedure GetJQDescription(): Text
    var
        GetOrdersFromEntriaLbl: Label 'Get Sales Orders from Entria';
    begin
        exit(GetOrdersFromEntriaLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeValidateCreateMissingCustomJQs, '', false, false)]
    local procedure SkipValidateCreateMissingCustomJQs(JobQueueEntry: Record "Job Queue Entry"; var SkipValidation: Boolean)
    begin
        if JobQueueEntry."Object Type to Run" <> JobQueueEntry."Object Type to Run"::Codeunit then
            exit;
        if JobQueueEntry."Object ID to Run" <> GetCodeunitId() then
            exit;

        //Without this the job queue refresher cannot recreate a deleted entry at all: the fallback it would
        //otherwise use consults OnRefreshserCheckIfCreateMissingCustomJobs, which nothing subscribes to, so a
        //monitored row whose job queue entry is missing just reports an error on every cycle.
        //
        //Unlike the ecommerce jobs that also subscribe to this event, the Entria order import job has a master
        //switch, so the opt-in is gated. Recreating it while the sales order integration is switched off produces
        //a job queue entry with nothing to import. It does not fail fast either: CheckIsEnabled() errors only when
        //the integration is off or no store is Enabled at all - it never consults "Sales Order Integration" - so
        //with an enabled store the recreated job passes its own gate rather than erroring out.
        //SetRereadSetup() is needed because the setup is cached on a single instance codeunit for the session.
        _EntriaIntegrationMgt.SetRereadSetup();
        if _EntriaIntegrationMgt.HasEnabledSalesOrderIntegrationStore() then
            SkipValidation := true;
    end;

    var
        _EcomJobManagement: Codeunit "NPR Ecom Job Management";
        _EntriaAPIHandler: Codeunit "NPR Entria API Handler";
        _EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
        _JsonHelper: Codeunit "NPR Json Helper";
        _SessionMaxBcStatusUpdatedAt: Dictionary of [Code[20], DateTime];
        _LastErrorEmitAt: Dictionary of [Text, DateTime];
}
#endif
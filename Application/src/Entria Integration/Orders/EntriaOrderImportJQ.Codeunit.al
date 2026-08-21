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
        ConsumedMaxDT: DateTime;
        Limit: Integer;
        Offset: Integer;
        PageCount: Integer;
    begin
        ExpectedMarkerDT := GetSyncStateMarker(EntriaStore.Code);
        WindowStartDT := PassWindowStart(ExpectedMarkerDT);
        _SessionMaxBcStatusUpdatedAt.Set(EntriaStore.Code, WindowStartDT);

        Offset := 0;
        Limit := 40;
        repeat
            if not DownloadOrdersPage(EntriaStore, WindowStartDT, Offset, Limit, PageCount) then begin
                EmitError(GetLastErrorText(), EntriaStore.Code, '');
                exit(false);
            end;

            if PageCount = 0 then
                exit(true);

            // False means the marker was rewound (moved backwards) in the database while we were
            // paging. A forward move is a parallel session's flush - it is adopted and paging continues.
            if not TryFlushMarker(EntriaStore.Code, ExpectedMarkerDT) then
                exit(true);

            // ConsumedMaxDT is the pass's running maximum, not this page's - it is seeded to
            // WindowStartDT and only ever raised.
            ConsumedMaxDT := GetSessionMaxBcStatusUpdatedAt(EntriaStore.Code);
            AdvancePagingCursor(ConsumedMaxDT, PageCount, WindowStartDT, Offset);
        until PageCount < Limit;
        exit(true);
    end;

    /// <summary>
    /// Keyset continuation: The window only ever moves FORWARD, to the highest bc_status_updated_at consumed so far, 
    /// and the offset resets to zero whenever it does. That reset is what makes the offset meaningful at all - 
    /// the offset may only be carried between requests whose filter is identical. It therefore survives for exactly one purpose: walking
    /// through a block of rows that share one timestamp, where the window cannot move.
    /// </summary>
    internal procedure AdvancePagingCursor(ConsumedMaxDT: DateTime; PageCount: Integer; var WindowStartDT: DateTime; var Offset: Integer)
    begin
        if ConsumedMaxDT > WindowStartDT then begin
            WindowStartDT := ConsumedMaxDT;
            Offset := 0;
        end else
            Offset += PageCount;
    end;

    local procedure DownloadOrdersPage(EntriaStore: Record "NPR Entria Store"; FromDT: DateTime; Offset: Integer; Limit: Integer; var PageCount: Integer): Boolean
    var
        OrdersArr: JsonArray;
    begin
        PageCount := 0;
        if not GetOrderList(EntriaStore, OrdersArr, Offset, Limit, FromDT) then
            exit(false);

        PageCount := OrdersArr.Count();
        if PageCount > 0 then
            exit(ProcessList(OrdersArr, EntriaStore));
        exit(true);
    end;

    internal procedure TryFlushMarker(StoreCode: Code[20]; var ExpectedMarkerDT: DateTime): Boolean
    var
        EntriaStoreSyncState: Record "NPR Entria Store Sync State";
        SessionMax: DateTime;
        MarkerMovedBack: Boolean;
    begin
        GetSyncState(StoreCode, true, EntriaStoreSyncState);

        // SQL Server datetime stores values on a 1/300s grid (.000/.003/.007) while the record
        // variable keeps the unrounded value after Modify(), so a read-back can be ~1-2ms lower
        // than what we wrote. A manual rewind is never sub-second, so only a move of 1s or more
        // counts as one; anything smaller is a rounding artifact.
        if ExpectedMarkerDT <> 0DT then
            MarkerMovedBack := EntriaStoreSyncState."Last Orders Imported At" < (ExpectedMarkerDT - 1000);
        SessionMax := _SessionMaxBcStatusUpdatedAt.Get(StoreCode);

        if not MarkerMovedBack then begin
            if SessionMax > EntriaStoreSyncState."Last Orders Imported At" then begin
                EntriaStoreSyncState."Last Orders Imported At" := SessionMax;
                EntriaStoreSyncState.Modify();
            end;
            // Track the value now in the database - our own write, or a parallel session's higher one 
            ExpectedMarkerDT := EntriaStoreSyncState."Last Orders Imported At";
        end;

        Commit();
        exit(not MarkerMovedBack);
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

        // A store that has never synced has no row yet.
        EntriaStoreSyncState.Init();
        EntriaStoreSyncState."Store Code" := StoreCode;
        if not EntriaStoreSyncState.Insert() then
            EntriaStoreSyncState.Get(StoreCode);
    end;

    internal procedure GetOrderList(EntriaStore: Record "NPR Entria Store"; var OrdersArr: JsonArray; Offset: Integer; Limit: Integer; BcStatusUpdatedAtFrom: DateTime): Boolean
    var
        EntriaResponse: JsonToken;
        Request: Text;
    begin
        Clear(OrdersArr);
        Request := GenerateGetOrderListRequest(Offset, Limit, BcStatusUpdatedAtFrom);
        if not _EntriaAPIHandler.SendEntriaRequest(EntriaStore.Code, Request, Enum::"Http Request Type"::GET, EntriaResponse) then
            exit(false);

        exit(TryGetOrdersArray(EntriaResponse, OrdersArr));
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

    internal procedure GenerateGetOrderListRequest(Offset: Integer; Limit: Integer; BcStatusUpdatedAtFrom: DateTime): Text
    var
        WindowText: Text;
    begin
        if BcStatusUpdatedAtFrom <> 0DT then
            WindowText := StrSubstNo('&bc_status_updated_at[$gte]=%1', Format(BcStatusUpdatedAtFrom, 0, 9));

        exit(StrSubstNo('admin/orders/bc-sync?bc_status=pending&limit=%1&offset=%2&order=bc_status_updated_at&%3%4', Limit, Offset, GetOrderFieldsProjection(), WindowText));
    end;

    local procedure GetOrderFieldsProjection(): Text
    begin
        exit('fields=-summary,+billing_address.*,+shipping_address.*,+shipping_methods.name,+currency_code,+email,+payment_collections.payments.*');
    end;

    /// <summary>
    /// The overlap is folded in exactly ONCE, here, against the fixed stored marker - never re-applied
    /// per page against the moving window. Subtracting it from a moving base lets the window rewind
    /// faster than it advances, and against densely stamped orders the same page is served forever.
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
        // Seeds to the window the pass would actually open with, overlap included - the same value
        // DownloadOrders seeds. Seeding to the bare marker would put the running maximum ahead of the
        // window, so the very first comparison would advance the window regardless of what was consumed.
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
    var
        DKey: Text;
        LastEmitAt: DateTime;
        OneHour: Duration;
    begin
        OneHour := 60 * 60 * 1000;
        DKey := StrSubstNo('%1|<list-fetch>', StoreCode);

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

    local procedure TelemetryTracking(ErrorText: Text; DocumentNo: Code[20])
    var
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
        EventId: Label 'NPR_EntriaAPI_OrderImportFailed', Locked = true;
    begin
        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_ErrorText', ErrorText);
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");
        CustomDimensions.Add('NPR_CallStack', GetLastErrorCallStack());
        if DocumentNo <> '' then
            CustomDimensions.Add('NPR_EntriaDocumentNo', DocumentNo);

        Session.LogMessage(EventId, ErrorText, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    local procedure EmitError(ErrorText: Text; StoreCode: Code[20]; DocumentNo: Code[20])
    begin
        if ShouldEmitSentryError(StoreCode) then
            EmitSentryError(StoreCode, DocumentNo);
        TelemetryTracking(ErrorText, DocumentNo);
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
        TelemetryTracking(ErrorText, DocumentNo);
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

        foreach OrderId in DueOrderIds do
            if EntriaOrderImpFailure.Get(EntriaStore.Code, OrderId) then
                if IsRetryDue(EntriaOrderImpFailure) then begin
                    ProcessDueRetry(EntriaStore, EntriaOrderImpFailure);
                    Commit();
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
        GetOrdersFromEntriaLbl: Label 'Get Sales Orders from Entria';
    begin
        if Enable then begin
            JobQueueMgt.SetJobTimeout(7, 0);
            JobQueueMgt.SetProtected(true);
            JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 30, '');
            if JobQueueMgt.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId(),
                '', GetOrdersFromEntriaLbl,
                CreateDateTime(Today(), 070000T), 1,
                '', JobQueueEntry)
            then
                JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
        end else
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId());
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Entria Order Import JQ");
    end;

    var
        _EntriaAPIHandler: Codeunit "NPR Entria API Handler";
        _EntriaIntegrationMgt: Codeunit "NPR Entria Integration Mgt.";
        _JsonHelper: Codeunit "NPR Json Helper";
        _SessionMaxBcStatusUpdatedAt: Dictionary of [Code[20], DateTime];
        _LastErrorEmitAt: Dictionary of [Text, DateTime];
}
#endif
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248580 "NPR Entria Order Import JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        StartTime: DateTime;
        MaxDuration: Duration;
    begin
        _EntriaIntegrationMgt.CheckIsEnabled('');
        Sentry.StartSpan(Span, StrSubstNo('bc.entria.orderimport'));
        SetTimeMarkers(StartTime, MaxDuration);
        repeat
            if ShouldSoftExit(Rec.ID, Span) then
                exit;
            ProcessEnabledStores();
            Sleep(1000);
        until (not Rec."Recurring Job") or DurationLimitReached(StartTime, MaxDuration);

        Span.Finish();
        FinalizeStoresMarkers();
    end;

    local procedure SetTimeMarkers(var StartTime: DateTime; var MaxDuration: Duration)
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        StartTime := CurrentDateTime();
        MaxDuration := JobQueueManagement.HoursToDuration(6);
        InitGlobals();
    end;

    local procedure ShouldSoftExit(JobQueueEntryID: Guid; var Span: Codeunit "NPR Sentry Span"): Boolean
    begin
        if not ShouldSoftExit(JobQueueEntryID) then
            exit(false);
        Span.Finish();
        exit(true);
    end;

    internal procedure ShouldSoftExit(JobQueueEntryId: Guid): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        ///When the status of the Job Queue that's running in a loop is changed to On Hold - active session won't be stopped.
        ///Job Queue will still run in background until loop finishes or exits on its own.
        ///This way, we'll exit the loop and stop further execution.
        ///The Error status is handled in case of unexpected behavior after an app upgrade — the JQ might get stuck in an error state while the log still shows it as being in process.
        if not JobQueueEntry.Get(JobQueueEntryId) then
            exit(true);

        if JobQueueEntry.Status in [JobQueueEntry.Status::"On Hold", JobQueueEntry.Status::Error] then
            exit(true);
        exit(false);
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
        EntriaStore.SetLoadFields(Code, "Last Orders Imported At", "Location Code", "Process Order On Import");
        if EntriaStore.FindSet() then
            repeat
                ProcessStore(EntriaStore);
            until EntriaStore.Next() = 0;
    end;

    local procedure ProcessStore(EntriaStore: Record "NPR Entria Store")
    begin
        SetMarkers(EntriaStore);
        DownloadOrders(EntriaStore);
        TryUpdateMarkers(EntriaStore);
    end;

    local procedure DownloadOrders(EntriaStore: Record "NPR Entria Store")
    var
        HasMore: Boolean;
        Limit: Integer;
        Offset: Integer;
        OrderCount: Integer;
        OrdersArr: JsonArray;
    begin
        Offset := 0;
        Limit := 40;
        HasMore := true;
        repeat
            if not GetOrderList(EntriaStore, OrdersArr, Offset, Limit, GetFromDT(EntriaStore)) then begin
                LogError(GetLastErrorText(), EntriaStore.Code, '');
                exit;
            end;
            OrderCount := OrdersArr.Count();
            if OrderCount = 0 then
                exit;
            ProcessList(OrdersArr, EntriaStore);

            HasMore := OrderCount = Limit;
            Offset += Limit;
        until not HasMore;
    end;

    local procedure BuildOrderDocNoIndex(OrdersArr: JsonArray; var DocToIdx: Dictionary of [Code[20], Integer])
    var
        i: Integer;
        OrderTkn: JsonToken;
        DocumentNo: Code[20];
    begin
        Clear(DocToIdx);

        for i := 0 to OrdersArr.Count() - 1 do begin
            OrdersArr.Get(i, OrderTkn);

            DocumentNo := GetDocumentNo(OrderTkn);
            if DocumentNo <> '' then
                if not DocToIdx.ContainsKey(DocumentNo) then
                    DocToIdx.Add(DocumentNo, i);
        end;
    end;

    local procedure GetOrderTokenByDocNo(OrdersArr: JsonArray; DocToIdx: Dictionary of [Code[20], Integer]; DocumentNo: Code[20]; var OrderTkn: JsonToken): Boolean
    var
        Idx: Integer;
    begin
        Clear(OrderTkn);

        if not DocToIdx.Get(DocumentNo, Idx) then
            exit(false);

        if (Idx < 0) or (Idx >= OrdersArr.Count()) then
            exit(false);

        OrdersArr.Get(Idx, OrderTkn);
        exit(true);
    end;

    internal procedure GetOrderList(EntriaStore: Record "NPR Entria Store"; var OrdersArr: JsonArray; Offset: Integer; Limit: Integer; UpdatedAtFrom: DateTime): Boolean
    var
        OrdersToken: JsonToken;
        EntriaResponse: JsonToken;
        Request: Text;
    begin
        Clear(OrdersArr);
        Request := GenerateGetOrderListRequest(Offset, Limit, UpdatedAtFrom);
        if not _EntriaAPIHandler.SendEntriaRequest(EntriaStore.Code, Request, Enum::"Http Request Type"::GET, EntriaResponse) then
            exit(false);
        if EntriaResponse.SelectToken('orders', OrdersToken) then
            if OrdersToken.IsArray() then
                OrdersArr := OrdersToken.AsArray();
        exit(true);
    end;

    local procedure GenerateGetOrderListRequest(Offset: Integer; Limit: Integer; UpdatedAtFrom: DateTime): Text
    var
        UpdatedAtText: Text;
    begin
        if UpdatedAtFrom <> 0DT then
            UpdatedAtText := StrSubstNo('&updated_at[$gte]=%1', FormatDateTime(UpdatedAtFrom));

        exit(StrSubstNo('admin/orders?offset=%1&limit=%2&order=updated_at&fields=-summary,+gift_card_transactions,+billing_address.*,+shipping_address.*,+currency_code,+email,+payment_collections.payments.*%3', Offset, Limit, UpdatedAtText));
    end;

    local procedure FormatDateTime(DT: DateTime): Text
    begin
        //Introduces a 6-minute safety overlap window in incremental sync to prevent missing recently updated orders due to Entria Admin API propagation delays
        exit(Format(DT - 6 * 60 * 1000, 0, 9));
    end;

    local procedure GetExistingEcomDocsForBatch(DocToIdx: Dictionary of [Code[20], Integer]; var ExistingDocs: Dictionary of [Code[20], Boolean]; EntriaStoreCode: Code[20])
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        FilterTxt: Text;
        DocNo: Code[20];
    begin
        // We limit each API page to 40 orders so the OR-filter stays bounded and safe for SetFilter.
        // Worst case length: 839 characters.
        Clear(ExistingDocs);

        foreach DocNo in DocToIdx.Keys() do
            if FilterTxt = '' then
                FilterTxt := DocNo
            else
                FilterTxt += '|' + DocNo;

        if FilterTxt = '' then
            exit;

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

    local procedure ProcessList(OrdersArr: JsonArray; EntriaStore: Record "NPR Entria Store")
    var
        DocToIdx: Dictionary of [Code[20], Integer];
        ExistingDocs: Dictionary of [Code[20], Boolean];
        DocumentNo: Code[20];
        OrderTkn: JsonToken;
    begin
        BuildOrderDocNoIndex(OrdersArr, DocToIdx);
        if DocToIdx.Count() = 0 then
            exit;

        GetExistingEcomDocsForBatch(DocToIdx, ExistingDocs, EntriaStore.Code);

        foreach DocumentNo in DocToIdx.Keys() do begin
            if not ExistingDocs.ContainsKey(DocumentNo) then
                if GetOrderTokenByDocNo(OrdersArr, DocToIdx, DocumentNo, OrderTkn) then begin
                    if ProcessOrder(EntriaStore, OrderTkn, DocumentNo) then
                        UpdateSessionMax(EntriaStore.Code, _JsonHelper.GetJDT(OrderTkn, 'updated_at', true));
                    Commit();
                end;
        end;
    end;

    internal procedure ProcessOrder(EntriaStore: Record "NPR Entria Store"; OrderTkn: JsonToken; DocumentNo: Code[20]): Boolean
    var
        EntriaOrderProcessor: Codeunit "NPR Entria Order Processor";
        EcomSalesDocApiAgent: Codeunit "NPR EcomSalesDocApiAgentV2";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        ClearLastError();
        Clear(EntriaOrderProcessor);
        EntriaOrderProcessor.SetParams(OrderTkn, EntriaStore, DocumentNo);
        if EntriaOrderProcessor.Run(EcomSalesHeader) then begin
            If EntriaStore."Process Order On Import" then
                EcomSalesDocApiAgent.PreProcessDocument(EcomSalesHeader);
            EcomSalesDocApiAgent.AssignBucketId(EcomSalesHeader);
            exit(true);
        end;
        LogError(GetErrorText(DocumentNo), EntriaStore.Code, DocumentNo);
        exit(false);
    end;

    local procedure GetDocumentNo(OrderTkn: JsonToken): Code[20]
    begin
#pragma warning disable AA0139
        exit(_JsonHelper.GetJText(OrderTkn, 'custom_display_id', false));
#pragma warning restore AA0139
    end;

    #region markers
    /// <summary>
    /// _InitialFromDT[StoreCode]
    ///   The baseline timestamp read from the database ("Last Orders Imported At").
    ///   Used as the starting point for updatedAt filtering during this JQ cycle.
    /// _SessionMaxUpdatedAt[StoreCode]
    ///   Tracks the highest updatedAt value encountered during this JQ cycle.
    ///   This value becomes the new "Last Orders Imported At" when the marker is updated.
    /// _LastMarkerUpdate[StoreCode]
    ///   Records the last time the marker was written to the database.
    ///   Used to control periodic marker updates and reduce database write frequency.
    ///_ErrorsSinceLastMarker[StoreCode]
    ///   Marker to track for any errors and prevent "Last Orders Imported At" from being updated is error exists.
    /// </summary>
    local procedure SetMarkers(EntriaStore: Record "NPR Entria Store")
    var
        FromDT: DateTime;
    begin
        if not _InitialFromDT.ContainsKey(EntriaStore.Code) then begin
            if EntriaStore."Last Orders Imported At" <> 0DT then
                FromDT := EntriaStore."Last Orders Imported At"
            else
                FromDT := GetDefaultFromDT();
            _InitialFromDT.Add(EntriaStore.Code, FromDT);
        end;

        if not _SessionMaxUpdatedAt.ContainsKey(EntriaStore.Code) then
            _SessionMaxUpdatedAt.Add(EntriaStore.Code, _InitialFromDT.Get(EntriaStore.Code));

        if not _LastMarkerUpdate.ContainsKey(EntriaStore.Code) then
            _LastMarkerUpdate.Add(EntriaStore.Code, CurrentDateTime());

        if not _ErrorsSinceLastMarker.ContainsKey(EntriaStore.Code) then
            _ErrorsSinceLastMarker.Add(EntriaStore.Code, false);
    end;

    local procedure TryUpdateMarkers(EntriaStore: Record "NPR Entria Store")
    var
        EntriaStoreUpd: Record "NPR Entria Store";
        NowDT: DateTime;
    begin
        NowDT := CurrentDateTime();
        if (NowDT - _LastMarkerUpdate.Get(EntriaStore.Code)) < (5 * 60000) then
            exit;
        if _ErrorsSinceLastMarker.Get(EntriaStore.Code) then
            exit;

        EntriaStoreUpd.ReadIsolation := IsolationLevel::UpdLock;
        EntriaStoreUpd.Get(EntriaStore.RecordId);
        UpdateLastImportedAt(EntriaStoreUpd);
        _LastMarkerUpdate.Set(EntriaStoreUpd.Code, NowDT);
    end;

    local procedure FinalizeStoresMarkers()
    var
        EntriaStore: Record "NPR Entria Store";
    begin
        EntriaStore.Reset();
        EntriaStore.ReadIsolation := IsolationLevel::ReadCommitted;
        EntriaStore.SetCurrentKey(Enabled);
        EntriaStore.SetRange(Enabled, true);
        EntriaStore.SetRange("Sales Order Integration", true);
        EntriaStore.SetLoadFields(Code, "Last Orders Imported At");
        if EntriaStore.FindSet() then
            repeat
                if _SessionMaxUpdatedAt.ContainsKey(EntriaStore.Code) then
                    if not _ErrorsSinceLastMarker.Get(EntriaStore.Code) then
                        UpdateLastImportedAt(EntriaStore);
            until EntriaStore.Next() = 0;
    end;

    local procedure UpdateSessionMax(StoreCode: Code[20]; UpdatedAt: DateTime)
    var
        CurrentMax: DateTime;
    begin
        CurrentMax := _SessionMaxUpdatedAt.Get(StoreCode);
        if UpdatedAt > CurrentMax then
            _SessionMaxUpdatedAt.Set(StoreCode, UpdatedAt);
    end;
    #endregion

    local procedure UpdateLastImportedAt(EntriaStore: Record "NPR Entria Store")
    var
        NewDT: DateTime;
    begin
        NewDT := _SessionMaxUpdatedAt.Get(EntriaStore.Code);
        if EntriaStore."Last Orders Imported At" < NewDT then begin
            EntriaStore.SetLastOrdersImportedAt(NewDT);
            _InitialFromDT.Set(EntriaStore.Code, NewDT);
        end;
        Commit();// Commit here is required to release UpdLock before next Sleep() iteration
    end;

    local procedure LogError(ErrMsg: Text; StoreCode: Code[20]; DocumentNo: Code[20])
    var
        EventIdLbl: Label 'NPR_EntriaAPI_OrderImportFailed', Locked = true;
    begin
        _ErrorsSinceLastMarker.Set(StoreCode, true);
        EmitError(ErrMsg, EventIdLbl, DocumentNo);
    end;

    local procedure EmitError(ErrorText: Text; EventId: Text; DocumentNo: Code[20])
    var
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
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

    local procedure InitGlobals()
    begin
        Clear(_InitialFromDT);
        Clear(_SessionMaxUpdatedAt);
        Clear(_LastMarkerUpdate);
        Clear(_ErrorsSinceLastMarker);
    end;

    local procedure GetFromDT(EntriaStore: Record "NPR Entria Store"): DateTime
    begin
        if _InitialFromDT.ContainsKey(EntriaStore.Code) then
            exit(_InitialFromDT.Get(EntriaStore.Code));
        exit(GetDefaultFromDT());
    end;

    local procedure GetErrorText(DocumentNo: Code[20]) ErrMsg: Text
    var
        FullOrderTxt: Label 'Import Order %1 from Entria failed: %2', Locked = true;
    begin
        ErrMsg := StrSubstNo(FullOrderTxt, DocumentNo, GetLastErrorText());
    end;

    local procedure GetDefaultFromDT(): DateTime
    begin
        exit(CreateDateTime(DMY2Date(1, 1, 2024), 0T));
    end;

    local procedure DurationLimitReached(StartDateTime: DateTime; DurationLimit: Duration): Boolean
    begin
        exit(CurrentDateTime - StartDateTime >= DurationLimit);
    end;

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
        _ErrorsSinceLastMarker: Dictionary of [Code[20], Boolean];
        _InitialFromDT: Dictionary of [Code[20], DateTime];
        _LastMarkerUpdate: Dictionary of [Code[20], DateTime];
        _SessionMaxUpdatedAt: Dictionary of [Code[20], DateTime];
}
#endif
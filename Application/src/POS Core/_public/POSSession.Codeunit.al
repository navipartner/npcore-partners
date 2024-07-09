codeunit 6150700 "NPR POS Session"
{
    SingleInstance = true;

    var
        _POSUnit: Record "NPR POS Unit";
        _FrontEnd: Codeunit "NPR POS Front End Management";
        _Sale: Codeunit "NPR POS Sale";
        _Setup: Codeunit "NPR POS Setup";
        _PosItemCheckAvail: Codeunit "NPR POS Item-Check Avail.";
        _ActionStateInt: Dictionary of [Text, Integer];
        _ActionStateDec: Dictionary of [Text, Decimal];
        _ActionStateText: Dictionary of [Text, Text];
        _ActionStateGuid: Dictionary of [Text, Guid];
        _DataStore: Codeunit "NPR Data Store";
        _CurrentView: Codeunit "NPR POS View";
        _ActionStateRecRef: array[1024] of RecordRef;
        _ActionStateCurrentActionId: Guid;
        _ActionStateCurrentAction: Text;
        _ActionStateRecRefCounter: Integer;
        _ActionStateInAction: Boolean;
        _InAction: Boolean;
        _SessionStarted: Boolean;
        _Initialized: Boolean;
        _InitializedUI: Boolean;
        _ActionsDiscovered: Boolean;
        _ErrorOnInitialize: Boolean;
        _ReportErrorMessage: Boolean;
        _DebugTrace: Text;
        _ServerStopwatch: Text;
        _POSPageId: Guid;
        _ACTION_STATE_ERROR: Label 'Action %1 has attempted to store an object into action state, which failed due to following error:\\%2';
        _SESSION_MISSING: Label 'POS Session object could not be retrieved. This is a programming bug, not a user error.';
        _SESSION_FINALIZED_ERROR: Label 'This POS window is no longer active.\This happens if you''ve opened the POS in a newer window. Please use that instead or reload this one.';
        _POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        TempSessionActions: Record "NPR POS Action" temporary;
        _DragonglassResponseQueue: Codeunit "NPR Dragonglass Response Queue";
        _POSRefreshData: Codeunit "NPR POS Refresh Data";


    //#region Initialization

    internal procedure Constructor(POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API")
    var
        JavaScriptInterface: Codeunit "NPR POS JavaScript Interface";
        PageId: Guid;
    begin
        PageId := _POSPageId;
        ClearAll();
        _POSPageId := PageId;

        _FrontEnd.Initialize();
        _Setup.Initialize();
        _Setup.GetPOSUnit(_POSUnit);

        JavaScriptInterface.Initialize(_FrontEnd);
        _POSBackgroundTaskAPI := POSBackgroundTaskAPI;

        _Initialized := true;
        OnInitialize(_FrontEnd);
    end;

    internal procedure ConstructFromWebserviceSession(Initial: Boolean; POSUnitNo: Text; SalesTicketNo: Text)
    begin
        _FrontEnd.Initialize();
        _Setup.Initialize();

        //Reconstruct global wrapper codeunits
        if POSUnitNo <> '' then begin
            _POSUnit.Get(POSUnitNo);
            _Setup.SetPOSUnit(_POSUnit);
        end else begin
            _Setup.GetPOSUnit(_POSUnit);
        end;

        if SalesTicketNo <> '' then begin
            _Sale.InitializeFromWebserviceSession(_POSUnit, _FrontEnd, _Setup, _Sale, SalesTicketNo);
        end;

        _Initialized := true;

        if Initial then begin
            OnInitialize(_FrontEnd);
        end;
    end;

    internal procedure ClearAll()
    begin
        Clear(_POSUnit);
        Clear(_FrontEnd);
        Clear(_Sale);
        Clear(_Setup);
        Clear(_ActionStateInt);
        Clear(_ActionStateDec);
        Clear(_ActionStateText);
        Clear(_ActionStateGuid);
        Clear(_DataStore);
        Clear(_CurrentView);
        Clear(_ActionStateRecRef);
        Clear(_ActionStateCurrentActionId);
        Clear(_ActionStateCurrentAction);
        Clear(_ActionStateRecRefCounter);
        Clear(_ActionStateInAction);
        Clear(_InAction);
        Clear(_SessionStarted);
        Clear(_Initialized);
        Clear(_InitializedUI);
        Clear(_ActionsDiscovered);
        Clear(_ErrorOnInitialize);
        Clear(_DebugTrace);
        Clear(_ServerStopwatch);
        Clear(_POSPageId);
        Clear(TempSessionActions);
        Clear(_POSBackgroundTaskAPI);
        Clear(_DragonglassResponseQueue);
        Clear(_POSRefreshData);
        Clear(_ReportErrorMessage);
    end;

    procedure IsInitialized(): Boolean
    begin
        exit(_Initialized);
    end;

    internal procedure SetPageId(PageId: Guid)
    begin
        _POSPageId := PageId;
    end;

    internal procedure InitializeUI()
    var
        Salesperson: Record "Salesperson/Purchaser";
        UI: Codeunit "NPR POS UI Management";
        UsesLegacyPOSMenus: Boolean;
    begin
        // This method is intended to be called only from the POS page during the initialization stage of the page.
        // Do not call this method from elsewhere!
        if _InitializedUI then
            exit;

        DebugWithTimestamp('GetSalespersonRecord');
        _Setup.GetSalespersonRecord(Salesperson);
        DebugWithTimestamp('GetPOSUnit');
        _Setup.GetPOSUnit(_POSUnit);
        UsesLegacyPOSMenus := not _Setup.UsesNewPOSFrontEnd();
        EmitPOSLayoutUsageTelemetry(_POSUnit, UsesLegacyPOSMenus);
        DebugWithTimestamp('UI.Initialize');
        UI.Initialize(_FrontEnd);
        DebugWithTimestamp('UI.SetOptions');
        UI.SetOptions(_Setup);
        DebugWithTimestamp('UI.InitializeCaptions');
        UI.InitializeCaptions();
        if UsesLegacyPOSMenus then begin
            DebugWithTimestamp('UI.InitializeLogo');
            UI.InitializeLogo(_POSUnit);
            DebugWithTimestamp('UI.InitializeNumberAndDateFormat');
            UI.InitializeNumberAndDateFormat(_POSUnit);
            DebugWithTimestamp('UI.ConfigureFonts');
            UI.ConfigureFonts();
            DebugWithTimestamp('UI.InitializeMenus');
            UI.InitializeMenus(_POSUnit, Salesperson);
            DebugWithTimestamp('InitializeTheme');
            UI.InitializeTheme(_POSUnit);
        end;
        DebugWithTimestamp('UI.ConfigureReusableWorkflow');
        UI.ConfigureReusableWorkflows(_Setup);
        DebugWithTimestamp('InitializeSecureMethods');
        _FrontEnd.ConfigureSecureMethods();
        DebugWithTimestamp('InitializeTelemetricsMetadata');
        _FrontEnd.InitializeTelemetricsMetadata();
        _InitializedUI := true;
    end;

    internal procedure InitializeSession(ResendMenus: Boolean)
    var
        Salesperson: Record "Salesperson/Purchaser";
        UI: Codeunit "NPR POS UI Management";
        PreviousRegisterNo: Code[10];
        UsesLegacyPOSMenus: Boolean;
    begin
        PreviousRegisterNo := _POSUnit."No.";
        _Setup.GetPOSUnit(_POSUnit);

        if (ResendMenus) then begin
            _Setup.GetSalespersonRecord(Salesperson);

            UI.Initialize(_FrontEnd);
            UI.SetOptions(_Setup);

            UsesLegacyPOSMenus := not _Setup.UsesNewPOSFrontEnd();
            if (PreviousRegisterNo <> _POSUnit."No.") then
                EmitPOSLayoutUsageTelemetry(_POSUnit, UsesLegacyPOSMenus);

            if UsesLegacyPOSMenus then begin
                UI.InitializeMenus(_POSUnit, Salesperson);

                if (PreviousRegisterNo <> _POSUnit."No.") then
                    UI.InitializeLogo(_POSUnit);
            end;

        end;
        StartPOSSession();
    end;

    local procedure InitializeDataSources()
    var
        DataSources: JsonArray;
    begin
        Clear(_DataStore);

        DataSources := _CurrentView.GetDataSources();
        _DataStore.Constructor(DataSources);

        OnInitializeDataSource(_DataStore);
    end;

    procedure StartPOSSession()
    begin
        InitializePOSSession();
        ChangeViewLogin();
        if not _SessionStarted then
            OnInitializationComplete(_FrontEnd);
        _SessionStarted := true;
    end;

    local procedure InitializePOSSession()
    begin
        ClearSale();
        _Setup.Initialize();
        _Setup.GetPOSUnit(_POSUnit);
        _Sale.InitializeAtLogin(_POSUnit, _Setup);
    end;

    internal procedure SetCursor(Context: JsonObject)
    var
        JToken: JsonToken;
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        GetSaleContext(POSSale, POSSaleLine, POSPaymentLine);

        if (Context.SelectToken('data.positions.BUILTIN_SALE', JToken)) then
            POSSale.SetPosition(JToken.AsValue().AsText());

        if (Context.SelectToken('data.positions.BUILTIN_SALELINE', JToken)) then
            POSSaleLine.SetPosition(JToken.AsValue().AsText());

        if (Context.SelectToken('data.positions.BUILTIN_PAYMENTLINE', JToken)) then
            POSPaymentLine.SetPosition(JToken.AsValue().AsText());
    end;

    local procedure EmitPOSLayoutUsageTelemetry(POSUnit: Record "NPR POS Unit"; UsesLegacyPOSMenus: Boolean)
    var
        ActiveSession: Record "Active Session";
        LogDict: Dictionary of [Text, Text];
        EventId: Text;
        EventMsg: Text;
        POSMenuEventIdTok: Label 'NPR_POSMenus', Locked = true;
        POSMenuTok: Label 'POS Unit: using legacy menus. Company: %1, Tenant: %2, Instance: %3, Server: %4, POS Unit No.: %5';
        POSLayoutEventIdTok: Label 'NPR_POSLayout', Locked = true;
        POSLayoutTok: Label 'POS Unit: using POS layouts: Company: %1, Tenant: %2, Instance: %3, Server: %4, POS Unit No.: %5, POS Layout Code: %6';
    begin
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);

        LogDict.Add('NPR_Server', ActiveSession."Server Computer Name");
        LogDict.Add('NPR_Instance', ActiveSession."Server Instance Name");
        LogDict.Add('NPR_TenantId', Database.TenantId());
        LogDict.Add('NPR_CompanyName', CompanyName());
        LogDict.Add('NPR_UserID', ActiveSession."User ID");
        LogDict.Add('NPR_POSUnitNo', POSUnit."No.");
        if UsesLegacyPOSMenus then begin
            EventId := POSMenuEventIdTok;
            EventMsg := StrSubstNo(POSMenuTok, CompanyName(), Database.TenantId(), ActiveSession."Server Instance Name", ActiveSession."Server Computer Name", POSUnit."No.");
        end else begin
            LogDict.Add('NPR_POSLayoutCode', POSUnit."POS Layout Code");
            EventId := POSLayoutEventIdTok;
            EventMsg := StrSubstNo(POSLayoutTok, CompanyName(), Database.TenantId(), ActiveSession."Server Instance Name", ActiveSession."Server Computer Name", POSUnit."No.", POSUnit."POS Layout Code");
        end;

        Session.LogMessage(EventId, EventMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, LogDict);
    end;
    //#endregion

    //#region  Workflows Session Storage

    procedure StartTransaction()
    var
        NullGuid: Guid;
    begin
        StartTransaction(NullGuid);
    end;

    procedure StartTransaction(SystemId: Guid)
    begin
        ClearSale();
        _Sale.InitializeNewSale(_POSUnit, _FrontEnd, _Setup, _Sale, SystemId);
    end;

    internal procedure ResumeTransaction(SalePOS: Record "NPR POS Sale")
    begin
        ClearSale();
        _Sale.ResumeExistingSale(SalePOS, _POSUnit, _FrontEnd, _Setup, _Sale);
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure BeginAction("Action": Text): Guid
    var
        Text004: Label 'Action %1 has been invoked while another action %2 with ID %3 is still running.';
    begin
        if _ActionStateInAction then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(Text004, Action, _ActionStateCurrentAction, _ActionStateCurrentActionId));

        _ActionStateInAction := true;
        Clear(_ActionStateInt);
        Clear(_ActionStateDec);
        Clear(_ActionStateText);
        Clear(_ActionStateGuid);
        Clear(_ActionStateRecRef);
        _ActionStateRecRefCounter := 1;
        _ActionStateCurrentAction := Action;
        _ActionStateCurrentActionId := CreateGuid();
        exit(_ActionStateCurrentActionId);
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure StoreActionState("Key": Text; "Object": Variant)
    var
        RecRefKey: Integer;
    begin
        if not Object.IsRecord then
            Error('Only record variants are supported');

        RecRefKey := StoreActionStateRecRef(Object);

        if not TryStoreActionState(Key, RecRefKey) then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(_ACTION_STATE_ERROR, _ActionStateCurrentAction, GetLastErrorText));
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure StoreActionState("Key": Text; "Object": Integer)
    begin
        if not TryStoreActionState(Key, Object) then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(_ACTION_STATE_ERROR, _ActionStateCurrentAction, GetLastErrorText));
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure StoreActionState("Key": Text; "Object": Text)
    begin
        if not TryStoreActionState(Key, Object) then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(_ACTION_STATE_ERROR, _ActionStateCurrentAction, GetLastErrorText));
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure StoreActionState("Key": Text; "Object": Decimal)
    begin
        if not TryStoreActionState(Key, Object) then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(_ACTION_STATE_ERROR, _ActionStateCurrentAction, GetLastErrorText));
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure StoreActionState("Key": Text; "Object": Guid)
    begin
        if not TryStoreActionState(Key, Object) then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(_ACTION_STATE_ERROR, _ActionStateCurrentAction, GetLastErrorText));
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure RetrieveActionState("Key": Text; var "Object": Integer)
    begin
        Object := _ActionStateInt.Get(Key);
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure RetrieveActionState("Key": Text; var "Object": Text)
    begin
        Object := _ActionStateText.Get(Key);
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure RetrieveActionState("Key": Text; var "Object": Decimal)
    begin
        Object := _ActionStateDec.Get(Key);
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure RetrieveActionState("Key": Text; var "Object": Guid)
    begin
        Object := _ActionStateGuid.Get(Key);
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure RetrieveActionStateSafe("Key": Text; var "Object": Integer): Boolean
    begin
        if _ActionStateInt.ContainsKey(Key) then begin
            RetrieveActionState(Key, Object);
            exit(true);
        end;
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure RetrieveActionStateSafe("Key": Text; var "Object": Text): Boolean
    begin
        if _ActionStateText.ContainsKey(Key) then begin
            RetrieveActionState(Key, Object);
            exit(true);
        end;
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure RetrieveActionStateSafe("Key": Text; var "Object": Decimal): Boolean
    begin
        if _ActionStateDec.ContainsKey(Key) then begin
            RetrieveActionState(Key, Object);
            exit(true);
        end;
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure RetrieveActionStateSafe("Key": Text; var "Object": Guid): Boolean
    begin
        if _ActionStateGuid.ContainsKey(Key) then begin
            RetrieveActionState(Key, Object);
            exit(true);
        end;
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure RetrieveActionStateRecordRef("Key": Text; var RecRef: RecordRef)
    var
        Index: Integer;
    begin
        Index := _ActionStateInt.Get(Key);
        RecRef := _ActionStateRecRef[Index];
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure EndAction("Action": Text; Id: Guid)
    var
        Text005: Label 'An attempt was made to finish action %1 with ID %2, while another action %3 with ID %4 is in progress.';
    begin
        if (Action <> _ActionStateCurrentAction) or (Id <> _ActionStateCurrentActionId) then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(Text005, Action, Id, _ActionStateCurrentAction, _ActionStateCurrentActionId));

        ClearActionState();
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.', '2023-06-28')]
    procedure ClearActionState()
    begin
        Clear(_ActionStateInAction);
        Clear(_ActionStateInt);
        Clear(_ActionStateDec);
        Clear(_ActionStateText);
        Clear(_ActionStateGuid);
        Clear(_ActionStateRecRefCounter);
        Clear(_ActionStateCurrentAction);
        Clear(_ActionStateCurrentActionId);
    end;

    local procedure StoreActionStateRecRef("Object": Variant) StoredIndex: Integer
    begin
        StoredIndex := _ActionStateRecRefCounter;
        _ActionStateRecRef[StoredIndex].GetTable(Object);
        _ActionStateRecRefCounter += 1;
    end;

    [TryFunction]
    local procedure TryStoreActionState("Key": Text; "Object": Integer)
    begin
        if _ActionStateInt.ContainsKey(Key) then
            _ActionStateInt.Remove(Key);

        _ActionStateInt.Add(Key, Object);
    end;

    [TryFunction]
    local procedure TryStoreActionState("Key": Text; "Object": Text)
    begin
        if _ActionStateText.ContainsKey(Key) then
            _ActionStateText.Remove(Key);

        _ActionStateText.Add(Key, Object);
    end;

    [TryFunction]
    local procedure TryStoreActionState("Key": Text; "Object": Decimal)
    begin
        if _ActionStateDec.ContainsKey(Key) then
            _ActionStateDec.Remove(Key);

        _ActionStateDec.Add(Key, Object);
    end;

    [TryFunction]
    local procedure TryStoreActionState("Key": Text; "Object": Guid)
    begin
        if _ActionStateGuid.ContainsKey(Key) then
            _ActionStateGuid.Remove(Key);

        _ActionStateGuid.Add(Key, Object);
    end;

    procedure ClearSale()
    var
        LastSalePOSEntry: Record "NPR POS Entry";
    begin
        _Sale.GetLastSalePOSEntry(LastSalePOSEntry);
        Clear(_Sale);
        _Sale.SetLastSalePOSEntry(LastSalePOSEntry);
    end;

    //#endregion

    //#region Session Action Methods

    // These methods are used to keep track of "known" actions inside of this session.
    // Primarily this is used to prevent invalid action setup.

    [Obsolete('Remove once workflow v1 and v2 is gone, since v3 keeps the persistant table "POS Action" up to date', '2023-06-28')]
    internal procedure DiscoverActionsOnce()
    var
        POSAction: Record "NPR POS Action";
    begin
        if _ActionsDiscovered then
            exit;

        POSAction.DiscoverActions();
        _ActionsDiscovered := true;
    end;

    [Obsolete('Remove once RetrieveSessionAction() is no longer in use', '2023-06-28')]
    internal procedure DiscoverSessionAction(var ActionIn: Record "NPR POS Action" temporary)
    begin
        TempSessionActions := ActionIn;
        if not TempSessionActions.Insert() then begin
            ActionIn.CalcFields(Workflow);
            TempSessionActions.Workflow := ActionIn.Workflow;
            ActionIn.CalcFields("Custom JavaScript Logic");
            TempSessionActions."Custom JavaScript Logic" := ActionIn."Custom JavaScript Logic";
            TempSessionActions.Modify();
        end;
    end;

    internal procedure SetErrorOnInitialize(ErrorOnInitialize: Boolean)
    begin
        _ErrorOnInitialize := ErrorOnInitialize;
    end;

    internal procedure GetErrorOnInitialize(): Boolean
    begin
        exit(_ErrorOnInitialize);
    end;

    procedure RetrieveSessionAction(ActionCode: Code[20]; var ActionOut: Record "NPR POS Action"): Boolean
    var
        POSAction: Record "NPR POS Action";
    begin
        Clear(ActionOut);
        if ActionCode = '' then
            exit(false);
        if not TempSessionActions.Get(ActionCode) then begin
            POSAction.SetAutoCalcFields(Workflow, "Custom JavaScript Logic");
            if (not POSAction.Get(ActionCode)) then
                exit(false);
            // During named workflow discovery, v3 workflows are not included in action discovery.             
            TempSessionActions.TransferFields(POSAction);
            TempSessionActions.Insert();
        end;

        ActionOut := TempSessionActions;
        TempSessionActions.CalcFields(Workflow);
        ActionOut.Workflow := TempSessionActions.Workflow;
        TempSessionActions.CalcFields("Custom JavaScript Logic");
        ActionOut."Custom JavaScript Logic" := TempSessionActions."Custom JavaScript Logic";
        exit(true);
    end;
    //#endregion

    //#region General Methods

    procedure GetSetup(var SetupOut: Codeunit "NPR POS Setup")
    begin
        ErrorIfNotInitialized();
        SetupOut := _Setup;
    end;

    procedure GetCurrentView(var ViewOut: Codeunit "NPR POS View")
    begin
        ErrorIfNotInitialized();
        ViewOut := _CurrentView;
    end;

    procedure GetSaleContext(var SaleOut: Codeunit "NPR POS Sale"; var SaleLineOut: Codeunit "NPR POS Sale Line"; var PaymentLineOut: Codeunit "NPR POS Payment Line")
    begin
        ErrorIfNotInitialized();
        SaleOut := _Sale;
        _Sale.GetContext(SaleLineOut, PaymentLineOut);
    end;

    procedure GetSale(var SaleOut: Codeunit "NPR POS Sale")
    begin
        ErrorIfNotInitialized();
        if _Sale.PosSaleRecMustExit() then
            _Sale.RefreshCurrent();
        SaleOut := _Sale;
    end;

    procedure GetSaleLine(var SaleLineOut: Codeunit "NPR POS Sale Line")
    var
        PaymentLineOut: Codeunit "NPR POS Payment Line";
    begin
        ErrorIfNotInitialized();
        _Sale.GetContext(SaleLineOut, PaymentLineOut);
    end;

    procedure GetPaymentLine(var PaymentLineOut: Codeunit "NPR POS Payment Line")
    var
        SaleLineOut: Codeunit "NPR POS Sale Line";
    begin
        ErrorIfNotInitialized();
        _Sale.GetContext(SaleLineOut, PaymentLineOut);
    end;

    internal procedure GetDataStore(var DataStoreOut: Codeunit "NPR Data Store")
    begin
        ErrorIfNotInitialized();
        DataStoreOut := _DataStore;
    end;

    internal procedure GetResponseQueue(var DragonglassResponseQueue: Codeunit "NPR Dragonglass Response Queue")
    begin
        DragonglassResponseQueue := _DragonglassResponseQueue;
    end;

    internal procedure PopResponseQueue() ResponseArray: JsonArray
    begin
        exit(_DragonglassResponseQueue.PopQueuedRequests());
    end;

    [Obsolete('Remove when obsolete references are gone. Workflow v3 only supports nesting on frontend inside the javascript', '2023-06-28')]
    procedure IsInAction(): Boolean
    begin
        exit(_InAction);
    end;

    [Obsolete('Remove when obsolete references are gone. Workflow v3 only supports nesting on frontend inside the javascript', '2023-06-28')]
    procedure SetInAction(InActionNew: Boolean)
    begin
        _InAction := InActionNew;
    end;

    procedure InitializeViewDataSources(View: Codeunit "NPR POS View")
    begin
        _CurrentView := View;
        InitializeDataSources();
    end;

    procedure DebugWithTimestamp(Trace: Text)
    begin
        _DebugTrace += Trace + ' at ' + Format(CurrentDateTime, 0, '<Hours24,2>:<Minutes,2>:<Seconds,2><Second dec>') + ';';
    end;

    procedure DebugFlush() Result: Text
    begin
        Result := _DebugTrace;
        _DebugTrace := '';
    end;

    procedure AddServerStopwatch(Keyword: Text; Duration: Duration)
    var
        ServerStopwatchLbl: Label '[%1:%2]', Locked = true;
        Durationms: Integer;
    begin
        Durationms := Duration;
        _ServerStopwatch += StrSubstNo(ServerStopwatchLbl, DelChr(Keyword, '=', '[:]'), Durationms);
    end;

    procedure ServerStopwatchFlush() Result: Text
    begin
        Result := _ServerStopwatch;
        _ServerStopwatch := '';
    end;

    procedure ErrorIfNotInitialized()
    begin
        if not _Initialized then
            Error(_SESSION_MISSING);
    end;

    procedure ErrorIfPageIdMismatch(Id: Guid)
    begin
        if (Id <> _POSPageId) then
            Error(_SESSION_FINALIZED_ERROR);
    end;

    //#endregion

    //#region Data Refresh

    [Obsolete('Refresh is automatically handled', '2023-06-28')]
    procedure RequestRefreshData()
    begin
    end;

    internal procedure SetPOSRefreshData(var POSRefreshData: Codeunit "NPR POS Refresh Data")
    begin
        _POSRefreshData := POSRefreshData;
    end;

    internal procedure RequestFullRefresh()
    begin
        _POSRefreshData.SetFullRefresh();
    end;
    //#endregion

    //#region View Changing Methods

    procedure ChangeViewLogin()
    begin
        ErrorIfNotInitialized();
        _FrontEnd.LoginView(_Setup);
    end;

    procedure ChangeViewSale()
    begin
        ErrorIfNotInitialized();
        _FrontEnd.SaleView(_Setup);
    end;

    procedure ChangeViewPayment()
    var
        POSViewChangeWorkflowMgt: Codeunit "NPR POS View Change WF Mgt.";
    begin
        ErrorIfNotInitialized();
        POSViewChangeWorkflowMgt.InvokeOnPaymentViewWorkflow();
        _FrontEnd.PaymentView(_Setup);
    end;

    procedure ChangeViewLocked()
    begin
        ErrorIfNotInitialized();
        _FrontEnd.LockedView(_Setup);
    end;

    procedure ChangeViewBalancing()
    begin
        ErrorIfNotInitialized();
        _FrontEnd.BalancingView(_Setup);
    end;

    procedure ChangeViewRestaurant()
    begin
        ErrorIfNotInitialized();
        _FrontEnd.RestaurantView(_Setup);
    end;

    procedure SetReportErrorMessage(SendErrorMessage: Boolean)
    begin
        _ReportErrorMessage := SendErrorMessage;
    end;

    procedure GetReportErrorMessage(): Boolean
    begin
        exit(_ReportErrorMessage);
    end;

    //#endregion

    [Obsolete('Use GetFrontEnd or just use session directly since it''s single instance now', '2023-06-28')]
    procedure IsActiveSession(var FrontEndOut: Codeunit "NPR POS Front End Management"): Boolean
    begin
        FrontEndOut := _FrontEnd;
        exit(_Initialized);
    end;

    [Obsolete('Use session directly since it''s single instance now, or use IsInitialized if you need to check if POS is running without error', '2023-06-28')]
    procedure GetSession(var POSSessionOut: Codeunit "NPR POS Session"; WithError: Boolean): Boolean
    var
        SESSION_MISSING: Label 'POS Session object could not be retrieved. This is a programming bug, not a user error.';
    begin
        if not _Initialized then begin
            if WithError then
                Error(SESSION_MISSING)
            else
                exit(false);
        end;
        exit(true);
    end;

    procedure GetFrontEnd(var POSFrontEndOut: Codeunit "NPR POS Front End Management"; WithError: Boolean): Boolean
    var
        FRONTEND_MISSING: Label 'POS Front End object could not be retrieved. This is a programming bug, not a user error.';
    begin
        if not _Initialized then begin
            if WithError then
                Error(FRONTEND_MISSING)
            else
                exit(false);
        end;

        POSFrontEndOut := _FrontEnd;
        exit(true);
    end;

    procedure GetFrontEnd(var POSFrontEndOut: Codeunit "NPR POS Front End Management")
    begin
        GetFrontEnd(POSFrontEndOut, true);
    end;

    internal procedure GetPOSBackgroundTaskAPI(var POSBackgroundTaskAPIOut: Codeunit "NPR POS Background Task API")
    begin
        ErrorIfNotInitialized();
        POSBackgroundTaskAPIOut := _POSBackgroundTaskAPI;
    end;

    internal procedure SetAvailabilityCheckState(var PosItemCheckAvailIn: Codeunit "NPR POS Item-Check Avail.")
    begin
        _PosItemCheckAvail := PosItemCheckAvailIn;
    end;

    internal procedure GetAvailabilityCheckState(var PosItemCheckAvailOut: Codeunit "NPR POS Item-Check Avail.")
    begin
        PosItemCheckAvailOut := _PosItemCheckAvail;
    end;

    internal procedure ClearAvailabilityCheckState()
    begin
        Clear(_PosItemCheckAvail);
    end;

    //#region Event Publishers

    [IntegrationEvent(false, false)]
    local procedure OnInitialize(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInitializationComplete(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitializeDataSource(DataStore: Codeunit "NPR Data Store")
    begin
    end;
    //#endregion
}
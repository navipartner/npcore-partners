codeunit 6150700 "NPR POS Session"
{
    SingleInstance = true;

    var
        _POSUnit: Record "NPR POS Unit";
        _FrontEnd: Codeunit "NPR POS Front End Management";
        _Sale: Codeunit "NPR POS Sale";
        _Setup: Codeunit "NPR POS Setup";
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
        _DebugTrace: Text;
        _ServerStopwatch: Text;
        _POSPageId: Guid;
        _Framework: Interface "NPR Framework Interface";
        _ACTION_STATE_ERROR: Label 'Action %1 has attempted to store an object into action state, which failed due to following error:\\%2';
        TempSessionActions: Record "NPR POS Action" temporary;

    //#region Initialization

    internal procedure Constructor(FrameworkIn: Interface "NPR Framework Interface"; FrontEndIn: Codeunit "NPR POS Front End Management"; SetupIn: Codeunit "NPR POS Setup"; PageId: Guid)
    var
        JavaScriptInterface: Codeunit "NPR POS JavaScript Interface";
    begin
        ClearAll();

        _POSPageId := PageId;
        FrontEndIn.Initialize(FrameworkIn);
        _FrontEnd := FrontEndIn;
        _Framework := FrameworkIn;
        _Setup := SetupIn;
        _Setup.Initialize();
        JavaScriptInterface.Initialize(FrontEndIn);

        _Initialized := true;
        OnInitialize(_FrontEnd);
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
        Clear(_DebugTrace);
        Clear(_ServerStopwatch);
        Clear(_POSPageId);
        Clear(_Framework);
        Clear(TempSessionActions);
    end;

    procedure IsInitialized(): Boolean
    begin
        exit(_Initialized);
    end;

    internal procedure AttachedToPageId(PageId: Guid): Boolean
    begin
        exit(_POSPageId = PageId);
    end;

    internal procedure SetPageId(PageId: Guid)
    begin
        _POSPageId := PageId;
    end;

    internal procedure GetFramework(var FrameworkOut: Interface "NPR Framework Interface")
    begin
        FrameworkOut := _Framework;
    end;

    internal procedure InitializeUI()
    var
        Salesperson: Record "Salesperson/Purchaser";
        UI: Codeunit "NPR POS UI Management";
    begin
        // This method is intended to be called only from the POS page during the initialization stage of the page.
        // Do not call this method from elsewhere!
        if _InitializedUI then
            exit;

        DebugWithTimestamp('GetSalespersonRecord');
        _Setup.GetSalespersonRecord(Salesperson);
        DebugWithTimestamp('GetPOSUnit');
        _Setup.GetPOSUnit(_POSUnit);
        DebugWithTimestamp('UI.Initialize');
        UI.Initialize(_FrontEnd);
        DebugWithTimestamp('UI.SetOptions');
        UI.SetOptions(_Setup);
        DebugWithTimestamp('UI.InitializeCaptions');
        UI.InitializeCaptions();
        DebugWithTimestamp('UI.InitializeNumberAndDateFormat');
        UI.InitializeNumberAndDateFormat(_POSUnit);
        DebugWithTimestamp('UI.InitializeLogo');
        UI.InitializeLogo(_POSUnit);
        DebugWithTimestamp('UI.ConfigureFonts');
        UI.ConfigureFonts();
        DebugWithTimestamp('UI.InitializeMenus');
        UI.InitializeMenus(_POSUnit, Salesperson);
        DebugWithTimestamp('UI.ConfigureReusableWorkflow');
        UI.ConfigureReusableWorkflows(_Setup);
        DebugWithTimestamp('AdvertiseStargatePackages');
#if not CLOUD
        _FrontEnd.AdvertiseStargatePackages();
        DebugWithTimestamp('InitializeSecureMethods');
#endif
        _FrontEnd.ConfigureSecureMethods();
        DebugWithTimestamp('ConfigureActionSequences');
        _FrontEnd.ConfigureActionSequences(TempSessionActions);
        DebugWithTimestamp('InitializeTheme');
        UI.InitializeTheme(_POSUnit);
        DebugWithTimestamp('InitializeAdminTemplates');
        UI.InitializeAdministrativeTemplates(_POSUnit);
        DebugWithTimestamp('InitializeTelemetricsMetadata');
        _FrontEnd.InitializeTelemetricsMetadata();
        _InitializedUI := true;
    end;

    internal procedure InitializeSession(ResendMenus: Boolean)
    var
        Salesperson: Record "Salesperson/Purchaser";
        UI: Codeunit "NPR POS UI Management";
        PreviousRegisterNo: Code[10];
    begin
        PreviousRegisterNo := _POSUnit."No.";
        _Setup.GetPOSUnit(_POSUnit);

        if (ResendMenus) then begin
            _Setup.GetSalespersonRecord(Salesperson);

            UI.Initialize(_FrontEnd);
            UI.InitializeMenus(_POSUnit, Salesperson);

            if (PreviousRegisterNo <> _POSUnit."No.") then
                UI.InitializeLogo(_POSUnit);

        end;
        StartPOSSession();
    end;

    local procedure InitializeDataSources()
    var
        JS: Codeunit "NPR POS JavaScript Interface";
        DataSources: JsonArray;
    begin
        Clear(_DataStore);

        DataSources := _CurrentView.GetDataSources();
        _DataStore.Constructor(DataSources);

        OnInitializeDataSource(_DataStore);

        if _DataStore.DataSources().Count() > 0 then begin
            JS.RefreshData(_FrontEnd);
        end;
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

    //#endregion

    //#region  Workflows Session Storage

    procedure StartTransaction()
    begin
        ClearSale();
        _Sale.InitializeNewSale(_POSUnit, _FrontEnd, _Setup, _Sale);
    end;

    internal procedure ResumeTransaction(SalePOS: Record "NPR POS Sale")
    begin
        ClearSale();
        _Sale.ResumeExistingSale(SalePOS, _POSUnit, _FrontEnd, _Setup, _Sale);
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
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

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
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

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure StoreActionState("Key": Text; "Object": Integer)
    begin
        if not TryStoreActionState(Key, Object) then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(_ACTION_STATE_ERROR, _ActionStateCurrentAction, GetLastErrorText));
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure StoreActionState("Key": Text; "Object": Text)
    begin
        if not TryStoreActionState(Key, Object) then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(_ACTION_STATE_ERROR, _ActionStateCurrentAction, GetLastErrorText));
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure StoreActionState("Key": Text; "Object": Decimal)
    begin
        if not TryStoreActionState(Key, Object) then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(_ACTION_STATE_ERROR, _ActionStateCurrentAction, GetLastErrorText));
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure StoreActionState("Key": Text; "Object": Guid)
    begin
        if not TryStoreActionState(Key, Object) then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(_ACTION_STATE_ERROR, _ActionStateCurrentAction, GetLastErrorText));
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure RetrieveActionState("Key": Text; var "Object": Integer)
    begin
        Object := _ActionStateInt.Get(Key);
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure RetrieveActionState("Key": Text; var "Object": Text)
    begin
        Object := _ActionStateText.Get(Key);
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure RetrieveActionState("Key": Text; var "Object": Decimal)
    begin
        Object := _ActionStateDec.Get(Key);
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure RetrieveActionState("Key": Text; var "Object": Guid)
    begin
        Object := _ActionStateGuid.Get(Key);
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure RetrieveActionStateSafe("Key": Text; var "Object": Integer): Boolean
    begin
        if _ActionStateInt.ContainsKey(Key) then begin
            RetrieveActionState(Key, Object);
            exit(true);
        end;
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure RetrieveActionStateSafe("Key": Text; var "Object": Text): Boolean
    begin
        if _ActionStateText.ContainsKey(Key) then begin
            RetrieveActionState(Key, Object);
            exit(true);
        end;
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure RetrieveActionStateSafe("Key": Text; var "Object": Decimal): Boolean
    begin
        if _ActionStateDec.ContainsKey(Key) then begin
            RetrieveActionState(Key, Object);
            exit(true);
        end;
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure RetrieveActionStateSafe("Key": Text; var "Object": Guid): Boolean
    begin
        if _ActionStateGuid.ContainsKey(Key) then begin
            RetrieveActionState(Key, Object);
            exit(true);
        end;
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure RetrieveActionStateRecordRef("Key": Text; var RecRef: RecordRef)
    var
        Index: Integer;
    begin
        Index := _ActionStateInt.Get(Key);
        RecRef := _ActionStateRecRef[Index];
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
    procedure EndAction("Action": Text; Id: Guid)
    var
        Text005: Label 'An attempt was made to finish action %1 with ID %2, while another action %3 with ID %4 is in progress.';
    begin
        if (Action <> _ActionStateCurrentAction) or (Id <> _ActionStateCurrentActionId) then
            _FrontEnd.ReportBugAndThrowError(StrSubstNo(Text005, Action, Id, _ActionStateCurrentAction, _ActionStateCurrentActionId));

        ClearActionState();
    end;

    [Obsolete('Only allowed cross invocation state sharing is the database or frontend. Use v3 workflows for better value passing between workflows.')]
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

    [Obsolete('Remove once workflow v1 and v2 is gone, since v3 keeps the persistant table "POS Action" up to date')]
    internal procedure DiscoverActionsOnce()
    var
        POSAction: Record "NPR POS Action";
    begin
        if _ActionsDiscovered then
            exit;

        POSAction.DiscoverActions();
        _ActionsDiscovered := true;
    end;

    [Obsolete('Remove once RetrieveSessionAction() is no longer in use')]
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

    procedure RetrieveSessionAction(ActionCode: Code[20]; var ActionOut: Record "NPR POS Action"): Boolean
    var
        POSAction: Record "NPR POS Action";
    begin
        Clear(ActionOut);
        if not TempSessionActions.Get(ActionCode) then begin
            if (not POSAction.Get(ActionCode)) then
                exit(false);
            // During named workflow discovery, v3 workflows are not included in action discovery. 
            POSAction.CalcFields(Workflow);
            POSAction.CalcFields("Custom JavaScript Logic");
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
        SetupOut := _Setup;
    end;

    procedure GetCurrentView(var ViewOut: Codeunit "NPR POS View")
    begin
        ViewOut := _CurrentView;
    end;

    procedure GetSaleContext(var SaleOut: Codeunit "NPR POS Sale"; var SaleLineOut: Codeunit "NPR POS Sale Line"; var PaymentLineOut: Codeunit "NPR POS Payment Line")
    begin
        SaleOut := _Sale;
        _Sale.GetContext(SaleLineOut, PaymentLineOut);
    end;

    procedure GetSale(var SaleOut: Codeunit "NPR POS Sale")
    begin
        if _Sale.PosSaleRecMustExit() then
            _Sale.RefreshCurrent();
        SaleOut := _Sale;
    end;

    procedure GetSaleLine(var SaleLineOut: Codeunit "NPR POS Sale Line")
    var
        PaymentLineOut: Codeunit "NPR POS Payment Line";
    begin
        _Sale.GetContext(SaleLineOut, PaymentLineOut);
    end;

    procedure GetPaymentLine(var PaymentLineOut: Codeunit "NPR POS Payment Line")
    var
        SaleLineOut: Codeunit "NPR POS Sale Line";
    begin
        _Sale.GetContext(SaleLineOut, PaymentLineOut);
    end;

    procedure GetDataStore(var DataStoreOut: Codeunit "NPR Data Store")
    begin
        DataStoreOut := _DataStore;
    end;

    [Obsolete('Remove when obsolete references are gone. Workflow v3 only supports nesting on frontend inside the javascript')]
    procedure IsInAction(): Boolean
    begin
        exit(_InAction);
    end;

    [Obsolete('Remove when obsolete references are gone. Workflow v3 only supports nesting on frontend inside the javascript')]
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
    //#endregion

    //#region Data Refresh

    [Obsolete('Refresh is automatically handled')]
    procedure RequestRefreshData()
    begin
    end;
    //#endregion

    //#region View Changing Methods

    procedure ChangeViewLogin()
    begin
        _FrontEnd.LoginView(_Setup);
    end;

    procedure ChangeViewSale()
    begin
        _FrontEnd.SaleView(_Setup);
    end;

    procedure ChangeViewPayment()
    var
        POSViewChangeWorkflowMgt: Codeunit "NPR POS View Change WF Mgt.";
    begin
        POSViewChangeWorkflowMgt.InvokeOnPaymentViewWorkflow();
        _FrontEnd.PaymentView(_Setup);
    end;

    procedure ChangeViewLocked()
    begin
        _FrontEnd.LockedView(_Setup);
    end;

    procedure ChangeViewBalancing()
    begin
        _FrontEnd.BalancingView(_Setup);
    end;

    procedure ChangeViewRestaurant()
    begin
        _FrontEnd.RestaurantView(_Setup);
    end;

    //#endregion

    [Obsolete('Use GetFrontEnd or just use session directly since it''s single instance now')]
    procedure IsActiveSession(var FrontEndOut: Codeunit "NPR POS Front End Management"): Boolean
    begin
        FrontEndOut := _FrontEnd;
        exit(_Initialized);
    end;

    [Obsolete('Use session directly since it''s single instance now')]
    procedure GetSession(var POSSessionOut: Codeunit "NPR POS Session"; WithError: Boolean): Boolean
    var
        SESSION_MISSING: Label 'POS Session object could not be retrieved. This is a programming bug, not a user error.';
    begin
        if not _Initialized then
            Error(SESSION_MISSING);
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

    //#region Event Publishers

    [IntegrationEvent(false, false)]
    local procedure OnInitialize(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnInitializationComplete(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitializeDataSource(DataStore: Codeunit "NPR Data Store")
    begin
    end;
    //#endregion
}

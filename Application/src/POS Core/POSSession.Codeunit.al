codeunit 6150700 "NPR POS Session"
{
    // This object is used to manage session state for a POS session.
    // 
    // Some very important information:
    // - It must never ever ever be set to SingleInstance=Yes. Never. Did I say never? Good. So - never.
    // - In Transcendence, there should be no single-instance codeunits at all. If you ever feel like creating one,
    //   please talk to me (Vjeko), and let's discuss.
    // - An instance of this codeunit is created by the POS page, and one (and only one) instance of this codeunit
    //   belongs to an instance of the POS page. Once the page closes, the codeunit instance dies.
    // - One of the primary goals of this codeunit is to contain the reference to the Framework control add-in and to
    //   allow other codeunits to talk to the JavaScript. Therefore, the variable of this codeunit type must be passed
    //   to all functions that may have anything to do with front end. This is no problem, because all events that are
    //   ever sent from the front end pass the instance to this codeunit as a part of the event signature, and then
    //   any event subscribers should make sure to pass this instance around.
    // - Never keep a global variable of this codeunit type. It should only be locals and parameters. No globals.
    // - No business logic belongs in here. This is infrastructure only.

    EventSubscriberInstance = Manual;

    var
        POSUnit: Record "NPR POS Unit";
        SessionActions: Record "NPR POS Action" temporary;
        FrontEnd: Codeunit "NPR POS Front End Management";
        FrontEndKeeper: Codeunit "NPR POS Front End Keeper";
        Sale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        This: Codeunit "NPR POS Session";
        Stargate: Codeunit "NPR POS Stargate Management";
        ActionState: DotNet NPRNetDictionary_Of_T_U;
        DataStore: Codeunit "NPR Data Store";
        CurrentView: Codeunit "NPR POS View";
        KeyboardBindings: List of [Text];
        ActionStateRecRef: array[1024] of RecordRef;
        ActionStateCurrentActionId: Guid;
        ActionStateCurrentAction: Text;
        HardwareId: Text;
        SessionName: Text;
        HostName: Text;
        ActionStateRecRefCounter: Integer;
        ActionStateInAction: Boolean;
        InAction: Boolean;
        SessionStarted: Boolean;
        Text001: Label 'You should not be seeing this message. The fact that you are seeing it, though, means there is a potential bug in the code, and we were smart enough to capture it.\\So, how do you proceed from here?\1. Take a screenshot of this message.\2. Contact support and tell them what you did to get this message.\\You can now proceed working as if nothing has happened because in all likelihood everything will work just fine. But, just in case, we recommend that you sign out and then sign in again.';
        Text003: Label 'Action %1 has attempted to store an object into action state, which failed due to following error:\\%2';
        Text004: Label 'Action %1 has been invoked while another action %2 with ID %3 is still running.';
        Text005: Label 'An attempt was made to finish action %1 with ID %2, while another action %3 with ID %4 is in progress.';
        DataRefreshRequested: Boolean;
        Initialized: Boolean;
        InitializedUI: Boolean;
        Text006: Label 'A keyboard handler subscribed to handling the [%1] key press event, but it did not respond when the key was pressed.';
        ActionsDiscovered: Boolean;
        DebugTrace: Text;
        ServerStopwatch: Text;
        Finalized: Boolean;
        SESSION_MISSING: Label 'POS Session object could not be retrieved. This is a programming bug, not a user error.';
        FRONTEND_MISSING: Label 'POS Front End object could not be retrieved. This is a programming bug, not a user error.';
        DragonglassSession: Boolean;
        Workflow20State: array[1000] of Codeunit "NPR POS WF 2.0: State";
        Workflow20StateIndex: DotNet NPRNetDictionary_Of_T_U;
        Workflow20Map: array[1000] of Boolean;

    //#region Initialization

    procedure Constructor(FrameworkIn: Interface "NPR Framework Interface"; FrontEndIn: Codeunit "NPR POS Front End Management"; SetupIn: Codeunit "NPR POS Setup"; SessionIn: Codeunit "NPR POS Session")
    var
        JavaScriptInterface: Codeunit "NPR POS JavaScript Interface";
        OldPOSSession: Codeunit "NPR POS Session";
        OldFrontEnd: Codeunit "NPR POS Front End Management";
    begin
        if not Initialized then begin
            if OldPOSSession.IsActiveSession(OldFrontEnd) then begin
                //Cleanup previous POS Session before initializing new one.
                OldFrontEnd.GetSession(OldPOSSession);
                OldPOSSession.Destructor();
            end;

            FrontEndIn.Initialize(FrameworkIn, SessionIn);
            FrontEnd := FrontEndIn;
            Setup := SetupIn;
            This := SessionIn;
            Clear(Stargate);

            JavaScriptInterface.Initialize(SessionIn, FrontEndIn);
            FrontEndKeeper.Initialize(FrameworkIn, FrontEnd, This);
            BindSubscription(FrontEndKeeper);

            OnInitialize(FrontEnd);
        end else
            Message(Text001);

        Initialized := true;
    end;

    procedure InitializeUI()
    var
        Salesperson: Record "Salesperson/Purchaser";
        UI: Codeunit "NPR POS UI Management";
    begin
        // This method is intended to be called only from the POS page during the initialization stage of the page.
        // Do not call this method from elsewhere!
        if InitializedUI then
            exit;

        DebugWithTimestamp('GetSalespersonRecord');
        Setup.GetSalespersonRecord(Salesperson);
        DebugWithTimestamp('GetPOSUnit');
        Setup.GetPOSUnit(POSUnit);
        DebugWithTimestamp('UI.Initialize');
        UI.Initialize(FrontEnd);
        DebugWithTimestamp('UI.SetOptions');
        UI.SetOptions(Setup);
        DebugWithTimestamp('UI.InitializeCaptions');
        UI.InitializeCaptions();
        DebugWithTimestamp('UI.InitializeNumberAndDateFormat');
        UI.InitializeNumberAndDateFormat(POSUnit);
        DebugWithTimestamp('UI.InitializeLogo');
        UI.InitializeLogo(POSUnit);
        DebugWithTimestamp('UI.ConfigureFonts');
        UI.ConfigureFonts();
        DebugWithTimestamp('UI.InitializeMenus');
        UI.InitializeMenus(POSUnit, Salesperson, This);
        DebugWithTimestamp('UI.ConfigureReusableWorkflow');
        UI.ConfigureReusableWorkflows(This, Setup);
        DebugWithTimestamp('AdvertiseStargatePackages');
        FrontEnd.AdvertiseStargatePackages();
        InitializeKeyboardBindings();
        DebugWithTimestamp('InitializeSecureMethods');
        FrontEnd.ConfigureSecureMethods();
        DebugWithTimestamp('ConfigureActionSequences');
        FrontEnd.ConfigureActionSequences(SessionActions);
        DebugWithTimestamp('InitializeTheme');
        UI.InitializeTheme(POSUnit);
        DebugWithTimestamp('InitializeAdminTemplates');
        UI.InitializeAdministrativeTemplates(POSUnit);
        InitializedUI := true;
    end;

    procedure InitializeSession(ResendMenus: Boolean)
    var
        Salesperson: Record "Salesperson/Purchaser";
        UI: Codeunit "NPR POS UI Management";
        PreviousRegisterNo: Code[10];
    begin
        PreviousRegisterNo := POSUnit."No.";
        Setup.GetPOSUnit(POSUnit);

        if (ResendMenus) then begin
            Setup.GetSalespersonRecord(Salesperson);

            UI.Initialize(FrontEnd);
            UI.InitializeMenus(POSUnit, Salesperson, This);

            if (PreviousRegisterNo <> POSUnit."No.") then
                UI.InitializeLogo(POSUnit);

        end;
        StartPOSSession();
    end;

    local procedure InitializeDataSources()
    var
        JS: Codeunit "NPR POS JavaScript Interface";
        DataSource: Codeunit "NPR Data Source";
        DataSources: JsonArray;
    begin
        Clear(DataStore);

        DataSources := CurrentView.GetDataSources();
        DataStore.Constructor(DataSources);

        OnInitializeDataSource(DataStore);

        if DataStore.DataSources.Count > 0 then begin
            RequestRefreshData();
            JS.RefreshData(This, FrontEnd);
        end;
    end;

    procedure InitializeSessionId(HardwareIdIn: Text; SessionNameIn: Text; HostNameIn: Text)
    var
        HardwareIdInErr: Label 'Hardware ID from front end is blank. This is a programming error.';
    begin
        if HardwareIdIn = '' then
            Error(HardwareIdInErr);
        HardwareId := HardwareIdIn;
        SessionName := SessionNameIn;
        HostName := HostNameIn;
        OnFrontEndId(HardwareId, SessionName, HostName, This, FrontEnd);
    end;

    local procedure InitializeKeyboardBindings()
    var
        POSKeyboardBindingMgt: Codeunit "NPR POS Keyboard Binding Mgt.";
    begin
        POSKeyboardBindingMgt.DiscoverKeyboardBindings(KeyboardBindings);
        if KeyboardBindings.Count > 0 then
            FrontEnd.ConfigureKeyboardBindings(KeyboardBindings);
    end;

    procedure StartPOSSession()
    var
        CultureInfo: DotNet NPRNetCultureInfo;
    begin
        InitializePOSSession();
        ChangeViewLogin();
        if not SessionStarted then
            OnInitializationComplete(FrontEnd);
        SessionStarted := true;
    end;

    local procedure InitializePOSSession()
    begin
        Clear(Sale);
        Setup.Initialize(UserId);
        Setup.GetPOSUnit(POSUnit);
        Sale.InitializeAtLogin(POSUnit, Setup);
    end;

    //#endregion

    //#region Finalization

    procedure Destructor()
    begin
        if not Finalized then begin
            OnFinalize(FrontEnd);
            UnbindSubscription(FrontEndKeeper);
            ClearAll;
            SessionActions.DeleteAll;
            Finalized := true;
        end;
    end;

    procedure IsFinalized(): Boolean
    begin
        exit(Finalized);
    end;

    //#endregion

    //#region Workflows 2.0 State

    procedure GetWorkflow20State(WorkflowId: Integer; ActionCode: Text; var State: Codeunit "NPR POS WF 2.0: State")
    var
        StateIndex: Integer;
    begin
        if (IsNull(Workflow20StateIndex)) then
            Workflow20StateIndex := Workflow20StateIndex.Dictionary();

        if (not Workflow20StateIndex.ContainsKey(WorkflowId)) then begin
            StateIndex := GetNextWorkflow20StateIndex();
            Workflow20StateIndex.Add(WorkflowId, StateIndex);
            Clear(Workflow20State[StateIndex]);
            Workflow20State[StateIndex].Constructor(FrontEnd, ActionCode);
        end else
            StateIndex := Workflow20StateIndex.Item(WorkflowId);

        State := Workflow20State[StateIndex];
    end;

    local procedure GetNextWorkflow20StateIndex(): Integer
    var
        i: Integer;
    begin
        for i := 1 to 1000 do begin
            if not Workflow20Map[i] then begin
                Workflow20Map[i] := true;
                exit(i);
            end;
        end;

        // TODO: Here either we should retry to recover an old ID, or we should throw an error
    end;

    procedure FreeWorkflow20State(WorkflowId: Integer)
    var
        StateIndex: Integer;
    begin
        if (not Workflow20StateIndex.ContainsKey(WorkflowId)) then
            exit;

        StateIndex := Workflow20StateIndex.Item(WorkflowId);
        Workflow20StateIndex.Remove(WorkflowId);
        Workflow20Map[StateIndex] := false;
        Clear(Workflow20State[StateIndex]);
    end;

    //#endregion

    //#region  Workflows Session Storage

    procedure StartTransaction()
    var
        TransactionNo: Text;
    begin
        Clear(Sale);
        Sale.InitializeNewSale(POSUnit, FrontEnd, Setup, Sale);
    end;

    procedure ResumeTransaction(SalePOS: Record "NPR Sale POS")
    begin
        Clear(Sale);
        Sale.ResumeExistingSale(SalePOS, POSUnit, FrontEnd, Setup, Sale);
    end;

    procedure BeginAction("Action": Text): Guid
    begin
        if ActionStateInAction then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text004, Action, ActionStateCurrentAction, ActionStateCurrentActionId));

        ActionStateInAction := true;
        ActionState := ActionState.Dictionary();
        Clear(ActionStateRecRef);
        ActionStateRecRefCounter := 1;
        ActionStateCurrentAction := Action;
        ActionStateCurrentActionId := CreateGuid();
        exit(ActionStateCurrentActionId);
    end;

    procedure StoreActionState("Key": Text; "Object": Variant)
    begin
        if Object.IsRecord then
            Object := StoreActionStateRecRef(Object);

        if not TryStoreActionState(Key, Object) then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text003, ActionStateCurrentAction, GetLastErrorText));
    end;

    procedure RetrieveActionState("Key": Text; var "Object": Variant)
    begin
        Object := ActionState.Item(Key);
    end;

    procedure RetrieveActionStateSafe("Key": Text; var "Object": Variant): Boolean
    begin
        if ActionState.ContainsKey(Key) then begin
            RetrieveActionState(Key, Object);
            exit(true);
        end;
    end;

    procedure RetrieveActionStateRecordRef("Key": Text; var RecRef: RecordRef)
    var
        Index: Integer;
    begin
        Index := ActionState.Item(Key);
        RecRef := ActionStateRecRef[Index];
    end;

    procedure EndAction("Action": Text; Id: Guid)
    begin
        if (Action <> ActionStateCurrentAction) or (Id <> ActionStateCurrentActionId) then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text005, Action, Id, ActionStateCurrentAction, ActionStateCurrentActionId));

        ClearActionState();
    end;

    procedure ClearActionState()
    begin
        Clear(ActionStateInAction);
        Clear(ActionState);
        Clear(ActionStateRecRefCounter);
        Clear(ActionStateCurrentAction);
        Clear(ActionStateCurrentActionId);
    end;

    local procedure StoreActionStateRecRef("Object": Variant) StoredIndex: Integer
    begin
        StoredIndex := ActionStateRecRefCounter;
        ActionStateRecRef[StoredIndex].GetTable(Object);
        ActionStateRecRefCounter += 1;
    end;

    [TryFunction]
    local procedure TryStoreActionState("Key": Text; "Object": Variant)
    begin
        if ActionState.ContainsKey(Key) then
            ActionState.Remove(Key);

        ActionState.Add(Key, Object);
    end;

    //#endregion

    //#region Session Action Methods

    // These methods are used to keep track of "known" actions inside of this session.
    // Primarily this is used to prevent invalid action setup.

    procedure DiscoverActionsOnce()
    var
        POSAction: Record "NPR POS Action";
    begin
        if ActionsDiscovered then
            exit;

        POSAction.DiscoverActions();
        ActionsDiscovered := true;
    end;

    procedure DiscoverSessionAction(var ActionIn: Record "NPR POS Action" temporary)
    begin
        SessionActions := ActionIn;
        if not SessionActions.Insert then begin
            ActionIn.CalcFields(Workflow);
            SessionActions.Workflow := ActionIn.Workflow;
            ActionIn.CalcFields("Custom JavaScript Logic");
            SessionActions."Custom JavaScript Logic" := ActionIn."Custom JavaScript Logic";
            SessionActions.Modify;
        end;
    end;

    procedure RetrieveSessionAction(ActionCode: Code[20]; var ActionOut: Record "NPR POS Action"): Boolean
    begin
        if not SessionActions.Get(ActionCode) then
            exit(false);

        ActionOut := SessionActions;
        SessionActions.CalcFields(Workflow);
        ActionOut.Workflow := SessionActions.Workflow;
        SessionActions.CalcFields("Custom JavaScript Logic");
        ActionOut."Custom JavaScript Logic" := SessionActions."Custom JavaScript Logic";
        exit(true);
    end;

    procedure IsSessionAction("Code": Code[20]): Boolean
    begin
        exit(SessionActions.Get(Code));
    end;

    //#endregion

    //#region General Methods

    procedure GetSetup(var SetupOut: Codeunit "NPR POS Setup")
    begin
        SetupOut := Setup;
    end;

    procedure GetCurrentView(var ViewOut: Codeunit "NPR POS View")
    begin
        ViewOut := CurrentView;
    end;

    procedure GetSaleContext(var SaleOut: Codeunit "NPR POS Sale"; var SaleLineOut: Codeunit "NPR POS Sale Line"; var PaymentLineOut: Codeunit "NPR POS Payment Line")
    begin
        SaleOut := Sale;
        Sale.GetContext(SaleLineOut, PaymentLineOut);
    end;

    procedure GetSale(var SaleOut: Codeunit "NPR POS Sale")
    begin
        SaleOut := Sale;
    end;

    procedure GetSaleLine(var SaleLineOut: Codeunit "NPR POS Sale Line")
    var
        PaymentLineOut: Codeunit "NPR POS Payment Line";
    begin
        Sale.GetContext(SaleLineOut, PaymentLineOut);
    end;

    procedure GetPaymentLine(var PaymentLineOut: Codeunit "NPR POS Payment Line")
    var
        SaleLineOut: Codeunit "NPR POS Sale Line";
    begin
        Sale.GetContext(SaleLineOut, PaymentLineOut);
    end;

    procedure GetDataStore(var DataStoreOut: Codeunit "NPR Data Store")
    begin
        DataStoreOut := DataStore;
    end;

    procedure GetStargate(var StargateOut: Codeunit "NPR POS Stargate Management")
    begin
        StargateOut := Stargate;
    end;

    procedure ProcessKeyPress(KeyPress: Text) Handled: Boolean
    begin
        if (KeyboardBindings.Count = 0) and (not KeyboardBindings.Contains(KeyPress)) then
            exit(false);

        OnKeyPress(KeyPress, This, Setup, FrontEnd, Handled);

        if not Handled then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text006, KeyPress));
    end;

    procedure IsInAction(): Boolean
    begin
        exit(InAction);
    end;

    procedure SetInAction(InActionNew: Boolean)
    begin
        InAction := InActionNew;
    end;

    procedure SetView(View: Codeunit "NPR POS View")
    begin
        CurrentView := View;
        InitializeDataSources();
    end;

    procedure GetSessionId(var HardwareIdOut: Text; var SessionNameOut: Text; var HostNameOut: Text)
    begin
        HardwareIdOut := HardwareId;
        SessionNameOut := SessionName;
        HostNameOut := HostName;
    end;

    procedure DebugWithTimestamp(Trace: Text)
    begin
        DebugTrace += Trace + ' at ' + Format(CurrentDateTime, 0, '<Hours24,2>:<Minutes,2>:<Seconds,2><Second dec>') + ';';
    end;

    procedure DebugFlush() Result: Text
    begin
        Result := DebugTrace;
        DebugTrace := '';
    end;

    procedure AddServerStopwatch(Keyword: Text; Duration: Duration)
    var
        Durationms: Integer;
    begin
        Durationms := Duration;
        ServerStopwatch += StrSubstNo('[%1:%2]', DelChr(Keyword, '=', '[:]'), Durationms);
    end;

    procedure ServerStopwatchFlush() Result: Text
    begin
        Result := ServerStopwatch;
        ServerStopwatch := '';
    end;

    procedure SetDragonglassSession()
    begin
        DragonglassSession := true;
    end;

    procedure IsDragonglassSession(): Boolean
    begin
        exit(DragonglassSession);
    end;

    //#endregion

    //#region Data Refresh

    procedure RequestRefreshData()
    begin
        DataRefreshRequested := true;
    end;

    procedure IsDataRefreshNeeded() IsNeeded: Boolean
    begin
        IsNeeded := DataRefreshRequested;
        DataRefreshRequested := false;
    end;

    //#endregion

    //#region View Changing Methods

    procedure ChangeViewLogin()
    begin
        FrontEnd.LoginView(Setup);
    end;

    procedure ChangeViewSale()
    begin
        FrontEnd.SaleView(Setup);
    end;

    procedure ChangeViewPayment()
    var
        POSViewChangeWorkflowMgt: Codeunit "NPR POS View Change WF Mgt.";
    begin
        POSViewChangeWorkflowMgt.InvokeOnPaymentViewWorkflow(This);
        FrontEnd.PaymentView(Setup);
    end;

    procedure ChangeViewLocked()
    begin
        FrontEnd.LockedView(Setup);
    end;

    procedure ChangeViewBalancing()
    begin
        FrontEnd.BalancingView(Setup);
    end;

    procedure ChangeViewRestaurant()
    var
        RestViewNotSupportedErr: Label 'Restaurant view is not supported in this version. Change the setup on the POS View Profile. The default view is selected.';
    begin
        if (IsDragonglassSession()) then begin
            FrontEnd.RestaurantView(Setup);
            exit;
        end;

        Message(RestViewNotSupportedErr);
        ChangeViewSale();
    end;

    //#endregion

    //#region Framework Auto-Detection

    procedure IsActiveSession(var FrontEndOut: Codeunit "NPR POS Front End Management"): Boolean
    var
        POSSessionCheck: Codeunit "NPR POS Session";
        Active: Boolean;
    begin
        OnDetectFramework(FrontEndOut, POSSessionCheck, Active);
        exit(Active);
    end;

    procedure GetSession(var POSSessionOut: Codeunit "NPR POS Session"; WithError: Boolean): Boolean
    var
        Active: Boolean;
        POSFrontEnd: Codeunit "NPR POS Front End Management";
    begin
        OnDetectFramework(POSFrontEnd, POSSessionOut, Active);
        if WithError and (not Active) then
            Error(SESSION_MISSING);
        exit(Active);
    end;

    procedure GetFrontEnd(var POSFrontEndOut: Codeunit "NPR POS Front End Management"; WithError: Boolean): Boolean
    begin
        if not Initialized then begin
            if WithError then
                Error(FRONTEND_MISSING)
            else
                exit(false);
        end;

        POSFrontEndOut := FrontEnd;
        exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDetectFramework(var FrontEndOut: Codeunit "NPR POS Front End Management"; var POSSessionOut: Codeunit "NPR POS Session"; var Active: Boolean)
    begin
    end;

    //#endregion

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
    local procedure OnAfterSetView(View: Codeunit "NPR POS View")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitializeDataSource(DataStore: Codeunit "NPR Data Store")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFrontEndId(HardwareId: Text; SessionName: Text; HostName: Text; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnKeyPress(KeyPress: Text; POSSession: Codeunit "NPR POS Session"; Setup: Codeunit "NPR POS Setup"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFinalize(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    //#endregion
}

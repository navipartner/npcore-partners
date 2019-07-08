codeunit 6150700 "POS Session"
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
    // 
    // NPR5.32.11/VB /20170621  CASE 281618 Added watermark initialization functionality.
    // NPR5.37/VB /20170929   CASE 291777 Short-term solution for just-in-time Stargate synchronization in Major Tom
    // NPR5.37/VB  /20171025  CASE 293905 Added support for locked view, fixing the issue with incorrect setup instance being used in some functions
    // NPR5.37/NPKNAV/20171030  CASE 283791-01 Transport NPR5.37 - 27 October 2017
    // NPR5.38/VB  /20171120  CASE 295800 Implemented support for front-end keyboard bindings
    // NPR5.40/VB  /20180213  CASE 306347 Performance improvement due to parameters in BLOB and physical-table action discovery; refactored event model for session initialization.
    // NPR5.40/VB  /20180327  CASE 304310 Refreshing the menu UI when switching register or reinitializing session.
    // NPR5.41/MMV /20180410  CASE 307453 Changed implementation of 304310 to prevent double POS menu parse on first initialization.
    // NPR5.43/MMV /20180531  CASE 315838 Added server stopwatch functionality
    // NPR5.43/MMV /20180606  CASE 318028 Refactored session initialization and finalization.
    // NPR5.43/VB  /20180611  CASE 314603 Implemented secure method behavior functionality.
    // NPR5.43/MHA /20180613  CASE 318395 Added POS Sales Workflow in ChangeViewPayment()
    // NPR5.44/VB  /20180705  CASE 286547 Fixed issue with custom javascript code not being properly passed to the front end.
    // NPR5.44/JDH /20180731  CASE 323499 Changed all functions to be External
    // NPR5.47/TSA /20181018  CASE 327471 Refactored InitializeSession(), initialize new logo on register change
    // NPR5.49/VB  /20181106  CASE 335141 Introducing the POS Theme functionality
    // NPR5.48/TJ  /20180806  CASE 323835 New discovery pattern for keybinds
    // NPR5.49/MMV /20190312 CASE 345188 Added helper function to minimize confusion & boilerplate.
    // NPR5.50/VB  /20181224  CASE 338666 Supporting Workflows 2.0 functionality

    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
    end;

    var
        Register: Record Register;
        SessionActions: Record "POS Action" temporary;
        FrontEnd: Codeunit "POS Front End Management";
        FrontEndKeeper: Codeunit "POS Front End Keeper";
        Sale: Codeunit "POS Sale";
        Setup: Codeunit "POS Setup";
        This: Codeunit "POS Session";
        Stargate: Codeunit "POS Stargate Management";
        ActionState: DotNet npNetDictionary_Of_T_U;
        DataStore: DotNet npNetDataStore;
        CurrentView: DotNet npNetView0;
        KeyboardBindings: DotNet npNetList_Of_T;
        ActionStateRecRef: array [1024] of RecordRef;
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
        "--- Workflow 2.0 state ---": Integer;
        Workflow20State: array [1000] of Codeunit "POS Workflows 2.0 - State";
        Workflow20StateIndex: DotNet npNetDictionary_Of_T_U;
        Workflow20Map: array [1000] of Boolean;

    local procedure "---Initialization---"()
    begin
    end;

    [Scope('Personalization')]
    procedure Constructor(FrameworkIn: DotNet npNetIFramework0;FrontEndIn: Codeunit "POS Front End Management";SetupIn: Codeunit "POS Setup";SessionIn: Codeunit "POS Session")
    var
        JavaScriptInterface: Codeunit "POS JavaScript Interface";
        OldPOSSession: Codeunit "POS Session";
        OldFrontEnd: Codeunit "POS Front End Management";
    begin
        if not Initialized then begin
          //-NPR5.43 [318028]
          if OldPOSSession.IsActiveSession(OldFrontEnd) then begin
            //Cleanup previous POS Session before initializing new one.
            OldFrontEnd.GetSession(OldPOSSession);
            OldPOSSession.Destructor();
          end;

          FrontEndIn.Initialize(FrameworkIn,SessionIn);
          //+NPR5.43 [318028]

          FrontEnd := FrontEndIn;
          Setup := SetupIn;
          This := SessionIn;
          Clear(Stargate);

          JavaScriptInterface.Initialize(SessionIn,FrontEndIn);

          //-NPR5.43 [318028]
          FrontEndKeeper.Initialize(FrameworkIn,FrontEnd,This);
          BindSubscription(FrontEndKeeper);
          //+NPR5.43 [318028]

          OnInitialize(FrontEnd);
        end else
          Message(Text001);

        Initialized := true;
    end;

    [Scope('Personalization')]
    procedure InitializeUI()
    var
        Salesperson: Record "Salesperson/Purchaser";
        UI: Codeunit "POS UI Management";
    begin
        // This method is intended to be called only from the POS page during the initialization stage of the page.
        // Do not call this method from elsewhere!

        if InitializedUI then
          exit;

        //-NPR5.40 [306347]
        DebugWithTimestamp('GetSalespersonRecord');
        //+NPR5.40 [306347]
        Setup.GetSalespersonRecord(Salesperson);
        //-NPR5.40 [306347]
        DebugWithTimestamp('GetRegisterRecord');
        //+NPR5.40 [306347]
        Setup.GetRegisterRecord (Register);

        //-NPR5.40 [306347]
        DebugWithTimestamp('UI.Initialize');
        //+NPR5.40 [306347]
        UI.Initialize(FrontEnd);
        //-NPR5.37 [293905]
        //UI.SetOptions();
        //-NPR5.40 [306347]
        DebugWithTimestamp('UI.SetOptions');
        //+NPR5.40 [306347]
        UI.SetOptions(Setup);
        //+NPR5.37 [293905]
        //-NPR5.40 [306347]
        DebugWithTimestamp('UI.InitializeCaptions');
        //+NPR5.40 [306347]
        UI.InitializeCaptions();
        //-NPR5.40 [306347]
        DebugWithTimestamp('UI.InitializeNumberAndDateFormat');
        //+NPR5.40 [306347]
        UI.InitializeNumberAndDateFormat(Register);
        //-NPR5.40 [306347]
        DebugWithTimestamp('UI.InitializeLogo');
        //+NPR5.40 [306347]
        UI.InitializeLogo(Register);
        //-NPR5.32.11 [281618]
        //-NPR5.40 [306347]
        DebugWithTimestamp('UI.InitializeWatermark');
        //+NPR5.40 [306347]
        UI.InitializeWatermark();
        //+NPR5.32.11 [281618]
        //-NPR5.40 [306347]
        DebugWithTimestamp('UI.ConfigureFonts');
        //+NPR5.40 [306347]
        UI.ConfigureFonts();
        //-NPR5.40 [306347]
        DebugWithTimestamp('UI.InitializeMenus');
        //+NPR5.40 [306347]
        UI.InitializeMenus(Register,Salesperson,This);
        //-NPR5.37 [293905]
        //UI.ConfigureReusableWorkflows(This);
        //-NPR5.40 [306347]
        DebugWithTimestamp('UI.ConfigureReusableWorkflow');
        //+NPR5.40 [306347]
        UI.ConfigureReusableWorkflows(This,Setup);
        //+NPR5.37 [293905]
        //-NPR5.37 [291777]
        //-NPR5.40 [306347]
        DebugWithTimestamp('AdvertiseStargatePackages');
        //+NPR5.40 [306347]
        FrontEnd.AdvertiseStargatePackages();
        //+NPR5.37 [291777]
        //-NPR5.38 [295800]
        InitializeKeyboardBindings();
        //+NPR5.38 [295800]
        //-NPR5.43 [314603]
        DebugWithTimestamp('InitializeSecureMethods');
        FrontEnd.ConfigureSecureMethods();
        //+NPR5.43 [314603]
        //-NPR5.49 [335141]
        DebugWithTimestamp('InitializeTheme');
        UI.InitializeTheme(Register);
        //+NPR5.49 [335141]

        InitializedUI := true;

        //-NPR5.41 [307453]
        //-NPR5.40 [304310]
        //SendMenus := TRUE;
        //+NPR5.40 [304310]
        //+NPR5.41 [307453]
    end;

    [Scope('Personalization')]
    procedure InitializeSession(ResendMenus: Boolean)
    var
        Salesperson: Record "Salesperson/Purchaser";
        UI: Codeunit "POS UI Management";
        PreviousRegisterNo: Code[10];
    begin

        //-NPR5.47 [327471]
        PreviousRegisterNo := Register."Register No.";
        Setup.GetRegisterRecord (Register);

        if (ResendMenus) then begin
          Setup.GetSalespersonRecord(Salesperson);

          UI.Initialize(FrontEnd);
          UI.InitializeMenus(Register,Salesperson,This);

          if (PreviousRegisterNo <> Register."Register No.") then
            UI.InitializeLogo (Register);

        end;
        StartPOSSession();
        //+NPR5.47 [327471]
    end;

    local procedure InitializeDataSources()
    var
        JS: Codeunit "POS JavaScript Interface";
    begin
        Clear(DataStore);

        DataStore := DataStore.DataStore(CurrentView.GetDataSources());
        OnInitializeDataSource(DataStore);

        if DataStore.DataSources.Count > 0 then begin
          RequestRefreshData();
          JS.RefreshData(This,FrontEnd);
        end;
    end;

    [Scope('Personalization')]
    procedure InitializeSessionId(HardwareIdIn: Text;SessionNameIn: Text;HostNameIn: Text)
    begin
        HardwareId := HardwareIdIn;
        SessionName := SessionNameIn;
        HostName := HostNameIn;
        OnFrontEndId(HardwareId,SessionName,HostName,This,FrontEnd);
    end;

    local procedure InitializeKeyboardBindings()
    var
        POSKeyboardBindingMgt: Codeunit "POS Keyboard Binding Mgt.";
    begin
        //-NPR5.38 [295800]
        KeyboardBindings := KeyboardBindings.List();
        //-NPR5.48 [323835]
        //OnDiscoverKeyboardBindings(KeyboardBindings);
        POSKeyboardBindingMgt.DiscoverKeyboardBindings(KeyboardBindings);
        //+NPR5.48 [323835]
        if KeyboardBindings.Count > 0 then
          FrontEnd.ConfigureKeyboardBindings(KeyboardBindings);
        //+NPR5.38 [295800]
    end;

    [Scope('Personalization')]
    procedure StartPOSSession()
    var
        RetailFormCode: Codeunit "Retail Form Code";
        CultureInfo: DotNet npNetCultureInfo;
    begin
        InitializePOSSession();

        ChangeViewLogin();

        //-NPR5.40 [306347]
        if not SessionStarted then
          OnInitializationComplete(FrontEnd);
        //+NPR5.40 [306347]

        SessionStarted := true;
    end;

    local procedure "---Finalization---"()
    begin
    end;

    [Scope('Personalization')]
    procedure Destructor()
    begin
        //-NPR5.43 [318028]
        if not Finalized then begin
          OnFinalize(FrontEnd);
          UnbindSubscription(FrontEndKeeper);
          ClearAll;
          SessionActions.DeleteAll;
          Finalized := true;
        end;
        //+NPR5.43 [318028]
    end;

    [Scope('Personalization')]
    procedure IsFinalized(): Boolean
    begin
        //-NPR5.43 [318028]
        exit(Finalized);
        //+NPR5.43 [318028]
    end;

    local procedure "---Workflow 2.0 State---"()
    begin
    end;

    procedure GetWorkflow20State(WorkflowId: Integer;ActionCode: Text;var State: Codeunit "POS Workflows 2.0 - State")
    var
        StateIndex: Integer;
    begin
        //-NPR5.50 [338666]
        if (IsNull(Workflow20StateIndex)) then
          Workflow20StateIndex := Workflow20StateIndex.Dictionary();

        if (not Workflow20StateIndex.ContainsKey(WorkflowId)) then begin
          StateIndex := GetNextWorkflow20StateIndex();
          Workflow20StateIndex.Add(WorkflowId,StateIndex);
          Clear(Workflow20State[StateIndex]);
          Workflow20State[StateIndex].Constructor(FrontEnd,ActionCode);
        end else
          StateIndex := Workflow20StateIndex.Item(WorkflowId);

        State := Workflow20State[StateIndex];
        //+NPR5.50 [338666]
    end;

    local procedure GetNextWorkflow20StateIndex(): Integer
    var
        i: Integer;
    begin
        //-NPR5.50 [338666]
        for i := 1 to 1000 do begin
          if not Workflow20Map[i] then begin
            Workflow20Map[i] := true;
            exit(i);
          end;
        end;

        // TODO: Here either we should retry to recover an old ID, or we should throw an error
        //+NPR5.50 [338666]
    end;

    procedure FreeWorkflow20State(WorkflowId: Integer)
    var
        StateIndex: Integer;
    begin
        //-NPR5.50 [338666]
        if (not Workflow20StateIndex.ContainsKey(WorkflowId)) then
          exit;

        StateIndex := Workflow20StateIndex.Item(WorkflowId);
        Workflow20StateIndex.Remove(WorkflowId);
        Workflow20Map[StateIndex] := false;
        Clear(Workflow20State[StateIndex]);
        //+NPR5.50 [338666]
    end;

    local procedure "---Workflow Session Storage---"()
    begin
    end;

    [Scope('Personalization')]
    procedure StartTransaction()
    var
        Request: DotNet npNetStartTransactionJsonRequest;
        TransactionNo: Text;
    begin
        Clear(Sale);
        Sale.InitializeNewSale(Register,FrontEnd,Setup,Sale);
    end;

    [Scope('Personalization')]
    procedure BeginAction("Action": Text): Guid
    begin
        if ActionStateInAction then
          FrontEnd.ReportBug(StrSubstNo(Text004,Action,ActionStateCurrentAction,ActionStateCurrentActionId));

        ActionStateInAction := true;
        ActionState := ActionState.Dictionary();
        Clear(ActionStateRecRef);
        ActionStateRecRefCounter := 1;
        ActionStateCurrentAction := Action;
        ActionStateCurrentActionId := CreateGuid();
        exit(ActionStateCurrentActionId);
    end;

    [Scope('Personalization')]
    procedure StoreActionState("Key": Text;"Object": Variant)
    begin
        if Object.IsRecord then
          Object := StoreActionStateRecRef(Object);

        if not TryStoreActionState(Key,Object) then
          FrontEnd.ReportBug(StrSubstNo(Text003,ActionStateCurrentAction,GetLastErrorText));
    end;

    [Scope('Personalization')]
    procedure RetrieveActionState("Key": Text;var "Object": Variant)
    begin
        Object := ActionState.Item(Key);
    end;

    [Scope('Personalization')]
    procedure RetrieveActionStateSafe("Key": Text;var "Object": Variant): Boolean
    begin
        if ActionState.ContainsKey(Key) then begin
          RetrieveActionState(Key,Object);
          exit(true);
        end;
    end;

    [Scope('Personalization')]
    procedure RetrieveActionStateRecordRef("Key": Text;var RecRef: RecordRef)
    var
        Index: Integer;
    begin
        Index := ActionState.Item(Key);
        RecRef := ActionStateRecRef[Index];
    end;

    [Scope('Personalization')]
    procedure EndAction("Action": Text;Id: Guid)
    begin
        if (Action <> ActionStateCurrentAction) or (Id <> ActionStateCurrentActionId) then
          FrontEnd.ReportBug(StrSubstNo(Text005,Action,Id,ActionStateCurrentAction,ActionStateCurrentActionId));

        ClearActionState();
    end;

    [Scope('Personalization')]
    procedure ClearActionState()
    begin
        Clear(ActionStateInAction);
        Clear(ActionState);
        Clear(ActionStateRecRefCounter);
        Clear(ActionStateCurrentAction);
        Clear(ActionStateCurrentActionId);
    end;

    local procedure "---Session Action Methods---"()
    begin
        // These methods are used to keep track of "known" actions inside of this session.
        // Primarily this is used to prevent invalid action setup.
    end;

    [Scope('Personalization')]
    procedure DiscoverActionsOnce()
    var
        POSAction: Record "POS Action";
    begin
        //-NPR5.40 [306347]
        if ActionsDiscovered then
          exit;

        POSAction.DiscoverActions();
        ActionsDiscovered := true;
        //+NPR5.40 [306347]
    end;

    [Scope('Personalization')]
    procedure DiscoverSessionAction(var ActionIn: Record "POS Action" temporary)
    begin
        //-NPR5.40 [306347]
        //SessionActions.Code := Code;
        //IF NOT SessionActions.FIND() THEN
        //  SessionActions.INSERT();
        SessionActions := ActionIn;
        if not SessionActions.Insert then begin
          ActionIn.CalcFields(Workflow);
          SessionActions.Workflow := ActionIn.Workflow;
          //-NPR5.44 [286547]
          ActionIn.CalcFields("Custom JavaScript Logic");
          SessionActions."Custom JavaScript Logic" := ActionIn."Custom JavaScript Logic";
          //+NPR5.44 [286547]
          SessionActions.Modify;
        end;
        //+NPR5.40 [306347]
    end;

    [Scope('Personalization')]
    procedure RetrieveSessionAction(ActionCode: Code[20];var ActionOut: Record "POS Action"): Boolean
    begin
        //-NPR5.40 [306347]
        if not SessionActions.Get(ActionCode) then
          exit(false);

        ActionOut := SessionActions;
        SessionActions.CalcFields(Workflow);
        ActionOut.Workflow := SessionActions.Workflow;
        //-NPR5.44 [286547]
        SessionActions.CalcFields("Custom JavaScript Logic");
        ActionOut."Custom JavaScript Logic" := SessionActions."Custom JavaScript Logic";
        //+NPR5.44 [286547]
        exit(true);
        //+NPR5.40 [306347]
    end;

    [Scope('Personalization')]
    procedure IsSessionAction("Code": Code[20]): Boolean
    begin
        exit(SessionActions.Get(Code));
    end;

    local procedure "---General Methods---"()
    begin
    end;

    [Scope('Personalization')]
    procedure GetSetup(var SetupOut: Codeunit "POS Setup")
    begin
        SetupOut := Setup;
    end;

    [Scope('Personalization')]
    procedure GetCurrentView(var ViewOut: DotNet npNetView0)
    begin
        ViewOut := CurrentView;
    end;

    [Scope('Personalization')]
    procedure GetSaleContext(var SaleOut: Codeunit "POS Sale";var SaleLineOut: Codeunit "POS Sale Line";var PaymentLineOut: Codeunit "POS Payment Line")
    begin
        SaleOut := Sale;
        Sale.GetContext(SaleLineOut,PaymentLineOut);
    end;

    [Scope('Personalization')]
    procedure GetSale(var SaleOut: Codeunit "POS Sale")
    begin
        SaleOut := Sale;
    end;

    [Scope('Personalization')]
    procedure GetSaleLine(var SaleLineOut: Codeunit "POS Sale Line")
    var
        PaymentLineOut: Codeunit "POS Payment Line";
    begin
        Sale.GetContext(SaleLineOut,PaymentLineOut);
    end;

    [Scope('Personalization')]
    procedure GetPaymentLine(var PaymentLineOut: Codeunit "POS Payment Line")
    var
        SaleLineOut: Codeunit "POS Sale Line";
    begin
        Sale.GetContext(SaleLineOut,PaymentLineOut);
    end;

    [Scope('Personalization')]
    procedure GetDataStore(var DataStoreOut: DotNet npNetDataStore)
    begin
        DataStoreOut := DataStore;
    end;

    [Scope('Personalization')]
    procedure GetStargate(var StargateOut: Codeunit "POS Stargate Management")
    begin
        StargateOut := Stargate;
    end;

    [Scope('Personalization')]
    procedure ProcessKeyPress(KeyPress: Text) Handled: Boolean
    begin
        //-NPR5.38 [295800]
        if IsNull(KeyboardBindings) then
          exit(false);

        if (KeyboardBindings.Count = 0) and (not KeyboardBindings.Contains(KeyPress)) then
          exit(false);

        OnKeyPress(KeyPress,This,Setup,FrontEnd,Handled);

        if not Handled then
          FrontEnd.ReportBug(StrSubstNo(Text006,KeyPress));
        //+NPR5.38 [295800]
    end;

    [Scope('Personalization')]
    procedure IsInAction(): Boolean
    begin
        exit(InAction);
    end;

    [Scope('Personalization')]
    procedure SetInAction(InActionNew: Boolean)
    begin
        InAction := InActionNew;
    end;

    [Scope('Personalization')]
    procedure SetView(View: DotNet npNetView0)
    begin
        CurrentView := View;
        InitializeDataSources();
    end;

    [Scope('Personalization')]
    procedure GetSessionId(var HardwareIdOut: Text;var SessionNameOut: Text;var HostNameOut: Text)
    begin
        HardwareIdOut := HardwareId;
        SessionNameOut := SessionName;
        HostNameOut := HostName;
    end;

    [Scope('Personalization')]
    procedure DebugWithTimestamp(Trace: Text)
    begin
        //-NPR5.40 [306347]
        DebugTrace += Trace + ' at ' + Format(CurrentDateTime,0,'<Hours24,2>:<Minutes,2>:<Seconds,2><Second dec>') + ';';
        //+NPR5.40 [306347]
    end;

    [Scope('Personalization')]
    procedure DebugFlush() Result: Text
    begin
        //-NPR5.40 [306347]
        Result := DebugTrace;
        DebugTrace := '';
        //+NPR5.40 [306347]
    end;

    [Scope('Personalization')]
    procedure AddServerStopwatch(Keyword: Text;Duration: Duration)
    var
        Durationms: Integer;
    begin
        //-NPR5.43 [315838]
        Durationms := Duration;
        ServerStopwatch += StrSubstNo('[%1:%2]', DelChr(Keyword,'=','[:]'), Durationms);
        //+NPR5.43 [315838]
    end;

    [Scope('Personalization')]
    procedure ServerStopwatchFlush() Result: Text
    begin
        //-NPR5.43 [315838]
        Result := ServerStopwatch;
        ServerStopwatch := '';
        //+NPR5.43 [315838]
    end;

    local procedure "---Data Refresh---"()
    begin
    end;

    [Scope('Personalization')]
    procedure RequestRefreshData()
    begin
        DataRefreshRequested := true;
    end;

    [Scope('Personalization')]
    procedure IsDataRefreshNeeded() IsNeeded: Boolean
    begin
        IsNeeded := DataRefreshRequested;
        DataRefreshRequested := false;
    end;

    local procedure "---Local Functions---"()
    begin
    end;

    local procedure InitializePOSSession()
    begin
        Clear(Sale);

        Setup.Initialize(UserId);
        Setup.GetRegisterRecord(Register);

        Sale.InitializeAtLogin(Register,Setup);
    end;

    local procedure StoreActionStateRecRef("Object": Variant) StoredIndex: Integer
    begin
        StoredIndex := ActionStateRecRefCounter;
        ActionStateRecRef[StoredIndex].GetTable(Object);
        ActionStateRecRefCounter += 1;
    end;

    [TryFunction]
    local procedure TryStoreActionState("Key": Text;"Object": Variant)
    begin
        if ActionState.ContainsKey(Key) then
          ActionState.Remove(Key);

        ActionState.Add(Key,Object);
    end;

    local procedure "---Process---"()
    begin
    end;

    local procedure InitSale()
    begin
    end;

    [Scope('Personalization')]
    procedure ChangeViewLogin()
    begin
        // TODO: any business logic goes here

        FrontEnd.LoginView(Setup);
    end;

    [Scope('Personalization')]
    procedure ChangeViewSale()
    begin
        // TODO: any business logic goes here

        FrontEnd.SaleView(Setup);
    end;

    [Scope('Personalization')]
    procedure ChangeViewPayment()
    var
        POSViewChangeWorkflowMgt: Codeunit "POS View Change Workflow Mgt.";
    begin
        //-NPR5.43 [318395]
        POSViewChangeWorkflowMgt.InvokeOnPaymentViewWorkflow(This);
        //+NPR5.43 [318395]

        FrontEnd.PaymentView(Setup);
    end;

    [Scope('Personalization')]
    procedure ChangeViewLocked()
    begin
        //-NPR5.37 [293905]
        FrontEnd.LockedView(Setup);
        //+NPR5.37 [293905]
    end;

    [Scope('Personalization')]
    procedure ChangeViewBalancing()
    begin
        // TODO: any business logic goes here

        FrontEnd.BalancingView(Setup);
    end;

    local procedure "---Framework auto-detection---"()
    begin
    end;

    [Scope('Personalization')]
    procedure IsActiveSession(var FrontEndOut: Codeunit "POS Front End Management"): Boolean
    var
        POSSessionCheck: Codeunit "POS Session";
        Active: Boolean;
    begin
        OnDetectFramework(FrontEndOut,POSSessionCheck,Active);
        exit(Active);
    end;

    procedure GetSession(var POSSessionOut: Codeunit "POS Session";WithError: Boolean): Boolean
    var
        Active: Boolean;
        POSFrontEnd: Codeunit "POS Front End Management";
    begin
        //-NPR5.49 [345188]
        OnDetectFramework(POSFrontEnd, POSSessionOut, Active);
        if WithError and (not Active) then
          Error(SESSION_MISSING);
        exit(Active);
        //+NPR5.49 [345188]
    end;

    procedure GetFrontEnd(var POSFrontEndOut: Codeunit "POS Front End Management";WithError: Boolean): Boolean
    begin
        //-NPR5.49 [345188]
        if not Initialized then begin
          if WithError then
            Error(FRONTEND_MISSING)
          else
            exit(false);
        end;

        POSFrontEndOut := FrontEnd;
        exit(true);
        //+NPR5.49 [345188]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDetectFramework(var FrontEndOut: Codeunit "POS Front End Management";var POSSessionOut: Codeunit "POS Session";var Active: Boolean)
    begin
    end;

    local procedure "---Events---"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitialize(FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnInitializationComplete(FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetView(View: DotNet npNetView0)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitializeDataSource(DataStore: DotNet npNetDataStore)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFrontEndId(HardwareId: Text;SessionName: Text;HostName: Text;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDiscoverKeyboardBindings(KeyboardBindings: DotNet npNetList_Of_T)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnKeyPress(KeyPress: Text;POSSession: Codeunit "POS Session";Setup: Codeunit "POS Setup";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFinalize(FrontEnd: Codeunit "POS Front End Management")
    begin
    end;
}


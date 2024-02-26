﻿codeunit 6150704 "NPR POS Front End Management"
{
    var
        _POSSession: Codeunit "NPR POS Session";
        _RegisteredWorkflows: List of [Text];//TODO: Delete when workflow v1/v2 are gone

        _WorkflowStack: Codeunit "NPR Stack of [Integer]";//TODO: Delete when workflow v1/v2 are gone

        _ActionStack: Codeunit "NPR Stack of [Integer]"; //TODO: Delete when workflow v1/v2 are gone
        _WorkflowResponseContent: Variant;
        _HasWorkflowResponse: Boolean;
        _Initialized: Boolean;
        _Pausing: Boolean;//TODO: Delete when workflow v1/v2 are gone

        _PausedWorkflowID: Integer;//TODO: Delete when workflow v1/v2 are gone

        _WorkflowID: Integer;
        _StepToContinueAt: Text;//TODO: Delete when workflow v1/v2 are gone

        _DragonglassResponseContextLbl: Label '_dragonglassResponseContext', Locked = true;
        _DragonglassInvocationRespondedLbl: Label '_dragonglassResponseContext', Locked = true;

    internal procedure Initialize()
    begin
        Clear(_RegisteredWorkflows);
        Clear(_WorkflowStack);
        Clear(_ActionStack);

        // The following variable is used only in debugging sessions to indicate whether this instance of the codeunit has actually
        // been initialized. There is no other purpose to this variable, but it is absolutely indispensable for debugging purposes.
        _Initialized := true;
    end;

    local procedure IsActiveSession(): Boolean
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        if POSSession.IsInitialized() then begin
            Initialize();
            exit(true);
        end else
            exit(false);
    end;

    procedure GetSession(var SessionOut: Codeunit "NPR POS Session")
    var
        Text005: Label 'You attempted to retrieve a POS session instance outside of an active POS session, with no POS user interface currently running.';
    begin
        if not _Initialized then
            Error(Text005);

        SessionOut := _POSSession;
    end;

    #region Workflows 1.0 Coordination

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    procedure WorkflowBackEndStepBegin(WorkflowId: Integer; ActionId: Integer)
    begin
        _WorkflowStack.Push(WorkflowId);
        _ActionStack.Push(ActionId);
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    procedure WorkflowBackEndStepEnd()
    begin
        if _StepToContinueAt <> '' then begin
            RequestWorkflowStep(_StepToContinueAt);
            _StepToContinueAt := '';
        end;

        if not _Pausing then begin
            if _WorkflowStack.Count() > 0 then
                _WorkflowStack.Pop()
        end else
            _Pausing := false;

        if _ActionStack.Count() > 0 then
            _ActionStack.Pop();
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    local procedure CurrentWorkflowID(): Integer
    begin
        if _WorkflowStack.Count() > 0 then
            exit(_WorkflowStack.Peek());
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    local procedure CurrentActionID(): Integer
    begin
        if _ActionStack.Count() > 0 then
            exit(_ActionStack.Peek());
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    procedure AbortWorkflow(WorkflowID: Integer)
    begin
        if WorkflowID = CurrentWorkflowID() then begin
            _WorkflowStack.Pop();
        end;

        if WorkflowID = _PausedWorkflowID then
            _PausedWorkflowID := 0;
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    procedure AbortWorkflows()
    begin
        _Pausing := false;
        _PausedWorkflowID := 0;
        Clear(_WorkflowStack);
        Clear(_ActionStack);
        _POSSession.ClearActionState();
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    procedure ContinueAtStep(Step: Text)
    var
        Text011: Label 'A request was made to continue current workflow at step %1, while no workflow is currently running.';
    begin
        if CurrentWorkflowID() = 0 then
            ReportBugAndThrowError(StrSubstNo(Text011, Step));

        _StepToContinueAt := Step;
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    procedure IsPaused(): Boolean
    begin
        exit(_PausedWorkflowID > 0);
    end;

    #endregion

    #region Workflows 2.0 Coordination

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    procedure CloneForWorkflow20(WorkflowIDIn: Integer; var FrontEndIn: Codeunit "NPR POS Front End Management")
    begin
        FrontEndIn.Initialize();
        FrontEndIn.SetWorkflowID(WorkflowIDIn);
    end;

    procedure SetWorkflowID(WorkflowIDIn: Integer)
    begin
        _WorkflowID := WorkflowIDIn;
    end;

    procedure ClearWorkflowID()
    begin
        Clear(_WorkflowID);
    end;

    #endregion

    local procedure MakeSureFrameworkIsAvailable(WithError: Boolean): Boolean
    var
        Text002: Label 'A function that requires a POS session to be running has been invoked outside of a POS session.';
    begin
        if not _Initialized then
            if IsActiveSession() then
                exit(true);

        if _Initialized then
            exit(true);

        if WithError then
            Error(GetBugErrorMessage(Text002))
        else
            exit(false);
    end;

    local procedure MakeSureFrameworkIsAvailableIn20(WithError: Boolean): Boolean
    var
        Text015: Label 'A function that requires Workflow 2.0/3.0 engine to be initialized has been invoked from a Workflow 1.0 action.';
    begin
        if _WorkflowID = 0 then begin
            if WithError then
                Error(GetBugErrorMessage(Text015))
            else
                exit(false);
        end;

        exit(MakeSureFrameworkIsAvailable(WithError));
    end;

    local procedure MakeSureFrameworkIsInitialized()
    var
        Text013: Label 'A method call was made on an uninitialized instance of the POS Front End Management codeunit, that requires an active and initialized instance to succeed.';
    begin
        if (not _Initialized) THEN
            ReportBugAndThrowError(Text013);
    end;

    local procedure GetBugErrorMessage(Text: Text): Text
    var
        Text001: Label '%1\\This is a programming bug, not a user error.';
    begin
        exit(StrSubstNo(Text001, Text));
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    local procedure RegisterWorkflowIfNecessary(Name: Code[20])
    var
        POSAction: Record "NPR POS Action";
        Button: Record "NPR POS Menu Button";
        WorkflowAction: Codeunit "NPR Workflow Action";
        Text006: Label 'An unknown workflow was invoked: %1.';
    begin
        if _RegisteredWorkflows.Contains(Name) then
            exit;

        if not _POSSession.RetrieveSessionAction(Name, POSAction) then
            if not POSAction.Get(Name) then
                ReportBugAndThrowError(StrSubstNo(Text006, Name));

        Button."Action Type" := Button."Action Type"::Action;
        Button."Action Code" := POSAction.Code;
        WorkflowAction.ConfigureFromMenuButton(Button, _POSSession, WorkflowAction);

        ConfigureReusableWorkflow(WorkflowAction);
    end;

    #region Setting View

    procedure LoginView(Setup: Codeunit "NPR POS Setup")
    var
        POSDefaultView: Record "NPR POS Default View";
    begin
        SetView(POSDefaultView.Type::Login, Setup);
    end;

    procedure SaleView(Setup: Codeunit "NPR POS Setup")
    var
        POSDefaultView: Record "NPR POS Default View";
    begin
        SetView(POSDefaultView.Type::Sale, Setup);
    end;

    procedure PaymentView(Setup: Codeunit "NPR POS Setup")
    var
        POSDefaultView: Record "NPR POS Default View";
    begin
        SetView(POSDefaultView.Type::Payment, Setup);
    end;

    procedure BalancingView(Setup: Codeunit "NPR POS Setup")
    var
        POSDefaultView: Record "NPR POS Default View";
    begin
        SetView(POSDefaultView.Type::Balance, Setup);
    end;

    procedure LockedView(Setup: Codeunit "NPR POS Setup")
    var
        POSDefaultView: Record "NPR POS Default View";
    begin
        SetView(POSDefaultView.Type::Locked, Setup);
    end;

    procedure RestaurantView(Setup: Codeunit "NPR POS Setup")
    var
        POSDefaultView: Record "NPR POS Default View";
    begin
        SetView(POSDefaultView.Type::Restaurant, Setup);
    end;

    procedure SetView(ViewType: Option; Setup: Codeunit "NPR POS Setup")
    var
        DefaultView: Record "NPR POS Default View";
        POSViewChangeWorkflowMgt: Codeunit "NPR POS View Change WF Mgt.";
        Request: Codeunit "NPR Front-End: SetView";
        CurrView: Codeunit "NPR POS View";
        CHANGE_VIEW_ERROR: Label 'There was a problem changing view and adding data drivers: %1';
        Text003: Label 'Unsupported view type requested: %1.';
    begin
        MakeSureFrameworkIsAvailable(true);
        case ViewType of
            DefaultView.Type::Login:
                begin
                    Request.InitializeAsLogin();
                    DefaultView.Type := DefaultView.Type::Login;
                end;
            DefaultView.Type::Sale:
                begin
                    Request.InitializeAsSale();
                    DefaultView.Type := DefaultView.Type::Sale;
                end;
            DefaultView.Type::Payment:
                begin
                    Request.InitializeAsPayment();
                    DefaultView.Type := DefaultView.Type::Payment;
                end;
            DefaultView.Type::Balance:
                begin
                    Request.InitializeAsBalanceRegister();
                    DefaultView.Type := DefaultView.Type::Balance;
                end;
            DefaultView.Type::Locked:
                begin
                    Request.InitializeAsLocked();
                    DefaultView.Type := DefaultView.Type::Locked;
                end;
            DefaultView.Type::Restaurant:
                begin
                    Request.InitializeAsRestaurant();
                    DefaultView.Type := DefaultView.Type::Restaurant;
                end;
            else
                ReportBugAndThrowError(StrSubstNo(Text003, ViewType));
        end;

        _POSSession.GetCurrentView(CurrView);
        case ViewType of
            DefaultView.Type::Login:
                OnBeforeChangeToLoginView(_POSSession);
            DefaultView.Type::Sale:
                begin
                    if CurrView.GetType() = CurrView.GetType() ::Login then
                        POSViewChangeWorkflowMgt.InvokeOnAfterLoginWorkflow(_POSSession);

                    OnBeforeChangeToSaleView(_POSSession);
                end;
            DefaultView.Type::Payment:
                OnBeforeChangeToPaymentView(_POSSession);
            DefaultView.Type::Balance:
                OnBeforeChangeToBalanceRegisterView(_POSSession);
            DefaultView.Type::Restaurant:
                OnBeforeChangeToRestaurantView(_POSSession);
        end;

        Commit();
        ClearLastError();
        if (not ChangeViewInitializeDataSources(Setup, DefaultView, Request)) then
            ReportBugAndThrowError(StrSubstNo(CHANGE_VIEW_ERROR, GetLastErrorCode()));
    end;

    [TryFunction]
    local procedure ChangeViewInitializeDataSources(var Setup: Codeunit "NPR POS Setup"; var DefaultView: Record "NPR POS Default View"; var Request: Codeunit "NPR Front-End: SetView")
    var
        POSView: Record "NPR POS View";
        RequestView: Codeunit "NPR POS View";
        DataMgt: Codeunit "NPR POS Data Mgmt. Internal";
        DataSource: Codeunit "NPR Data Source";
        DataSourceNames: List of [Text];
        Markup: Text;
        SourceId: Text;
    begin

        Request.GetView(RequestView);

        if POSView.FindViewByType(
          DefaultView.Type,
          Setup.Salesperson(),
          Setup.GetPOSUnitNo())
        then begin
            Markup := POSView.GetMarkup();
            if Markup <> '' then begin
                RequestView.ParseLayout(POSView.GetMarkup());
                Request.GetContent().Add('ViewCode', POSView.Code);
            end;
        end;

        RequestView.GetLayoutDataSourceNames(DataSourceNames);
        foreach SourceId in DataSourceNames do begin
            DataMgt.GetDataSource(SourceId, DataSource, Setup);
            RequestView.AddDataSource(DataSource);
        end;

        if RequestView.GetDataSources().Count() = 0 then
            DataMgt.SetupDefaultDataSourcesForView(RequestView, Setup);

        InvokeFrontEndAsync(Request);

        _POSSession.InitializeViewDataSources(RequestView);
    end;
    #endregion


    local procedure InvokeFrontEndAsync(Request: Interface "NPR Front-End Async Request")
    var
        DebugTrace: Text;
        ServerStopwatch: Text;
        POSSession: Codeunit "NPR POS Session";
        DragonglassResponseQueue: Codeunit "NPR Dragonglass Response Queue";
    begin
        DebugTrace := _POSSession.DebugFlush();
        if DebugTrace <> '' then
            Trace(Request, 'debug_trace', DebugTrace);

        ServerStopwatch := _POSSession.ServerStopwatchFlush();
        if ServerStopwatch <> '' then
            Trace(Request, 'server_stopwatch', ServerStopwatch);

        POSSession.GetResponseQueue(DragonglassResponseQueue);
        DragonglassResponseQueue.QueueInvokeFrontendRequest(Request.GetJson());
    end;

    internal procedure InvokeFrontEndMethod2(Request: Interface "NPR Front-End Async Request")
    begin
        MakeSureFrameworkIsAvailable(true);
        InvokeFrontEndAsync(Request);
    end;

    /// <summary>
    /// Reports a bug in AL code to the front-end, and then stops transaction with a runtime error.
    /// </summary>
    /// <param name="ErrorText"></param>
    procedure ReportBugAndThrowError(ErrorText: Text)
    var
        Request: Codeunit "NPR Front-End: ReportBug";
    begin

        EmitError(ErrorText);

        if MakeSureFrameworkIsAvailable(false) then begin
            _POSSession.SetInAction(false);
            Request.Initialize(ErrorText);
            InvokeFrontEndAsync(Request);
            Error(''); // Transaction must aborted and rolled back. It is mandatory.
        end else
            Error(GetBugErrorMessage(ErrorText));
    end;

    local procedure EmitError(ErrorText: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin

        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            Clear(ActiveSession);

        if (ErrorText = '') then
            ErrorText := 'Transaction must be aborted and rolled back. It is mandatory.';

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_ErrorText', ErrorText);
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");
        CustomDimensions.Add('NPR_CallStack', GetLastErrorCallStack());

        Session.LogMessage('NPR_ReportBugAndThrowError', ErrorText, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);

    end;

    procedure ReportWarning(ErrorText: Text; WithError: Boolean)
    var
        Request: Codeunit "NPR Front-End: ReportBug";
    begin
        if MakeSureFrameworkIsAvailable(false) then begin
            Request.InitializeWarning(ErrorText, WithError);
            InvokeFrontEndAsync(Request);
            if WithError then
                Error(ErrorText);
        end else begin
            if WithError then
                Error(ErrorText)
            else
                Message(ErrorText);
        end;
    end;

    procedure ReportInvalidCustomMethod(ErrorText: Text; Method: Text)
    var
        Request: Codeunit "NPR Front-End: ReportBug";
    begin
        if MakeSureFrameworkIsAvailable(false) then begin
            _POSSession.SetInAction(false);
            Request.Initialize(ErrorText);
            Request.SetInvalidCustomMethod(Method);
            InvokeFrontEndAsync(Request);

            // It is mandatory that error be thrown now, and transaction aborted and rolled back.
            // DO NOT change this behavior.
            Error('');
        end else
            Error(GetBugErrorMessage(ErrorText));
    end;

    procedure AppGatewayProtocolResponse(EventName: Text; EventData: Text)
    var
        Request: Codeunit "NPR Front-End: AppGWResp.";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(EventName, EventData);
        InvokeFrontEndAsync(Request);
    end;

    [Obsolete('Pending removal, not used', 'NPR23.0')]
    procedure ApplyAdministrativeTemplates(Templates: JsonArray)
    begin
    end;

    [Obsolete('Action sequences are no longer supported', 'NPR23.0')]
    procedure ConfigureActionSequences(var TempSessionAction: Record "NPR POS Action" temporary)
    begin
        Error('Action sequences are no longer supported');
    end;

    procedure ConfigureCaptions(Captions: JsonObject)
    var
        Request: Codeunit "NPR Front-End: SetCaptions";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.SetCaptions(Captions);
        InvokeFrontEndAsync(Request);
    end;

    procedure ConfigureNumberAndDateFormats(POSViewProfile: Record "NPR POS View Profile");
    var
        Request: Codeunit "NPR Front-End: SetFormat";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(POSViewProfile);
        InvokeFrontEndAsync(Request);
    end;

    procedure ConfigureLogo(LogoBase64: Text)
    var
        Request: Codeunit "NPR Front-End: SetImage";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.SetImage('logo', LogoBase64);
        InvokeFrontEndAsync(Request);
    end;

    procedure ConfigureMenu(Menus: JsonArray)
    var
        Request: Codeunit "NPR Front-End: Menu";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(Menus);
        InvokeFrontEndAsync(Request);
    end;

    internal procedure ConfigureFont(Font: Interface "NPR Font Definition")
    var
        Request: Codeunit "NPR Front-End: ConfigFont.";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.SetFont(Font);
        InvokeFrontEndAsync(Request);
    end;

    internal procedure ConfigureReusableWorkflow("Action": Codeunit "NPR Workflow Action")
    var
        Request: Codeunit "NPR Front-End: CfgReusableWkf.";
        Workflow: Codeunit "NPR Workflow";
    begin
        Action.GetWorkflow(Workflow);
        if not _RegisteredWorkflows.Contains(Workflow.Name()) then
            _RegisteredWorkflows.Add(Workflow.Name());

        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(Action);
        InvokeFrontEndAsync(Request);
    end;

    procedure ConfigureSecureMethods()
    var
        TempSecureMethod: Record "NPR POS Secure Method" temporary;
        Request: Codeunit "NPR Front-End: CfgSecureMeth.";
        Method: JsonObject;
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        MakeSureFrameworkIsAvailable(true);

        TempSecureMethod.RunDiscovery();
        POSSession.GetSetup(POSSetup);
        if POSSetup.UsesNewPOSFrontEnd() then
            TempSecureMethod.SetRange(Type, TempSecureMethod.Type::"Password Server");

        if TempSecureMethod.FindSet() then
            repeat
                Clear(Method);
                Method.Add('description', TempSecureMethod.Description);
                Method.Add('typeText', Format(TempSecureMethod.Type));
                Method.Add('type', TempSecureMethod.Type);
                if TempSecureMethod.Type = TempSecureMethod.Type::Custom then
                    Method.Add('handler', TempSecureMethod.GetCustomMethodCode());
                Request.AddMethod(TempSecureMethod.Code, Method);
            until TempSecureMethod.Next() = 0;
        InvokeFrontEndAsync(Request);
    end;

    procedure ConfigureSecureMethodsClientPasswords(Method: Text; CommaDelimitedPasswords: Text)
    var
        Request: Codeunit "NPR Front-End: ConfSMPasswords";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(Method, CommaDelimitedPasswords);
        InvokeFrontEndAsync(Request);
    end;

    procedure ConfigureTheme(Theme: JsonArray)
    var
        Request: Codeunit "NPR Front-End: ConfigureTheme";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.SetTheme(Theme);
        InvokeFrontEndAsync(Request);
    end;

    procedure ValidateSecureMethodPassword(RequestId: Integer; Success: Boolean; SkipUI: Boolean; Reason: Text; AuthorizedBy: Text)
    var
        Request: Codeunit "NPR Front-End: ValSecMethPasw.";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(RequestId, Success, SkipUI, Reason, AuthorizedBy);
        InvokeFrontEndAsync(Request);
    end;

    [Obsolete('Remove the need for this request in frontend and delete this. It is currently a dummy event in backend', 'NPR23.0')]
    procedure HardwareInitializationComplete()
    var
        Request: Codeunit "NPR Front-End: Generic";
    begin
        Request.SetMethod('HardwareInitializationCompleted');
        InvokeFrontEndAsync(Request);
    end;

    procedure InitializeTelemetricsMetadata()
    var
        Request: Codeunit "NPR Front-End: Generic";
    begin
        Request.SetMethod('InitializeTelemetricsMetadata');
        Request.GetContent().Add('tenantId', TenantId());
        Request.GetContent().Add('userId', UserId());
        Request.GetContent().Add('companyName', CompanyName());
        Request.GetContent().Add('appVersion', GetAppVersion());
        Request.GetContent().Add('environmentType', GetEnvType());
        InvokeFrontEndAsync(Request);
    end;

    local procedure GetAppVersion(): Text
    var
        ModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(ModuleInfo);
        exit(Format(ModuleInfo.AppVersion));
    end;

    local procedure GetEnvType(): Text
    var
        EnvInfo: Codeunit "Environment Information";
    begin
        if EnvInfo.IsOnPrem() then
            exit('OnPrem');

        if EnvInfo.IsProduction() then
            exit('Production');

        if EnvInfo.IsSandbox() then
            exit('Sandbox');
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    procedure InvokeWorkflow(var POSAction: Record "NPR POS Action")
    var
        Request: Codeunit "NPR Front-End: WorkflowRequest";
        WorkflowInvocationParameters: JsonObject;
        WorkflowInvocationContext: JsonObject;
    begin
        MakeSureFrameworkIsInitialized();
        RegisterWorkflowIfNecessary(POSAction.Code);

        Request.Initialize(CurrentWorkflowID(), POSAction.Code, '', CreateGuid());
        Request.SetExplicit(true);
        if _POSSession.IsInAction() and (CurrentWorkflowID() > 0) then
            Request.SetNested(true);

        POSAction.GetWorkflowInvocationContext(WorkflowInvocationParameters, WorkflowInvocationContext);
        Request.SetParameters(WorkflowInvocationParameters);
        Request.SetWorkflowContext(WorkflowInvocationContext);

        InvokeFrontEndAsync(Request);
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    procedure PauseWorkflow(): Integer
    var
        Request: Codeunit "NPR Front-End: PauseWorkflow";
        ErrorText: Text;
        Text008: Label 'A request was made to pause a workflow outside of a workflow context.';
        Text009: Label 'A request was made to pause workflow ID %1 while a workflow ID %2 is already paused. This is a critical back-end error which will reset the back-end state. You may be able to retry the same action again, and you may even be able to conitnue with the current transaction; however, the safest way to proceed would be to start a new sale transaction if possible.';
    begin
        if CurrentWorkflowID() = 0 then
            ReportBugAndThrowError(Text008);

        if _PausedWorkflowID > 0 then begin
            ErrorText := StrSubstNo(Text009, _PausedWorkflowID, CurrentWorkflowID());
            AbortWorkflows();
            ReportBugAndThrowError(ErrorText);
        end;

        _Pausing := true;
        _PausedWorkflowID := CurrentWorkflowID();

        MakeSureFrameworkIsInitialized();
        Request.Initialize(CurrentWorkflowID());
        InvokeFrontEndAsync(Request);

        exit(_PausedWorkflowID);
    end;

    procedure RefreshData(DataSets: JsonArray)
    var
        Request: Codeunit "NPR Front-End: RefreshData";
        DataSetLine: JsonToken;
    begin
        MakeSureFrameworkIsAvailable(true);
        if DataSets.Count() = 0 then
            exit;

        foreach DataSetLine in DataSets do
            Request.AddDataSet(DataSetLine.AsObject());
        InvokeFrontEndAsync(Request);
    end;

    internal procedure RefreshData(DataSets: JsonObject)
    var
        Request: Codeunit "NPR Front-End: RefreshData";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.SetDataSets(DataSets);
        InvokeFrontEndAsync(Request);
    end;

    procedure RequireResponse(ID: Integer; RequiredContent: Text)
    var
        Request: Codeunit "NPR Front-End: RequireResponse";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(ID);
        Request.SetValue(RequiredContent);
        InvokeFrontEndAsync(Request);
    end;

    procedure RequireResponse(ID: Integer; RequiredContent: JsonObject)
    var
        Request: Codeunit "NPR Front-End: RequireResponse";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(ID);
        Request.SetValue(RequiredContent);
        InvokeFrontEndAsync(Request);
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    local procedure RequestWorkflowStep(StepId: Text)
    var
        Request: Codeunit "NPR Front-End: WorkflowRequest";
    begin
        MakeSureFrameworkIsInitialized();
        Request.Initialize(CurrentWorkflowID(), '', StepId, CreateGuid());
        InvokeFrontEndAsync(Request);
    end;

    [Obsolete('Not supported in workflow v3', 'NPR23.0')]
    procedure ResumeWorkflow()
    var
        Request: Codeunit "NPR Front-End: ResumeWorkflow";
        ErrorText: Text;
        Text010: Label 'A request was made to resume a paused workflow (ID %1) from within the context of another workflow (ID %2). This is a critical back-end error which will reset the back-end state. You may be able to retry the same action again, and you may even be able to conitnue with the current transaction; however, the safest way to proceed would be to start a new sale transaction if possible.';
        Text012: Label 'A request was made to resume a workflow, while no workflow is currently in the paused state.';
    begin
        if _PausedWorkflowID = 0 then
            ReportBugAndThrowError(Text012);

        if (CurrentWorkflowID() <> _PausedWorkflowID) and (CurrentWorkflowID() <> 0) then begin
            ErrorText := StrSubstNo(Text010, _PausedWorkflowID, CurrentWorkflowID());
            AbortWorkflows();
            ReportBugAndThrowError(ErrorText);
        end;

        MakeSureFrameworkIsInitialized();
        Request.Initialize(_PausedWorkflowID, CurrentActionID());

        _Pausing := false;
        _PausedWorkflowID := 0;

        InvokeFrontEndAsync(Request);
    end;

    procedure SetOption(Option: Text; Value: Variant)
    var
        Request: Codeunit "NPR Front-End: SetOption";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(Option, Value);
        InvokeFrontEndAsync(Request);
    end;

    procedure SetOptions(Options: JsonObject)
    var
        Request: Codeunit "NPR Front-End: SetOptions";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.SetOptions(Options);
        InvokeFrontEndAsync(Request);
    end;

    procedure StartTransaction(Sale: Record "NPR POS Sale")
    var
        Request: Codeunit "NPR Front-End: StartTrans.";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(Sale);
        InvokeFrontEndAsync(Request);
    end;

    [Obsolete('Delete once all wf 1.0 are gone', 'NPR23.0')]
    procedure SetActionContext("Action": Text; Context: Codeunit "NPR POS JSON Management")
    var
        Request: Codeunit "NPR Front-End: ProvideContext";
        ErrorDoNotCallSetActionContext: Label 'You have invoked SetActionContext from within a Workflows 2.0 action. This is an invalid operation.\\If you want to pass context to front end from a Workflows 2.0 action, it is enough to write to the Context object. In Workflows 2.0, context is automatically synchronized between AL and JavaScript.';
    begin
        if _WorkflowID > 0 then
            Error(ErrorDoNotCallSetActionContext);

        Request.Initialize(CurrentWorkflowID(), Action);
        Request.StoreContext(Context.GetContextObject());
        InvokeFrontEndAsync(Request);
    end;

    internal procedure WorkflowCallCompleted(Request: Codeunit "NPR Front-End: WkfCallCompl.")
    begin
        MakeSureFrameworkIsInitialized();
        if _WorkflowID > 0 then begin
            if _HasWorkflowResponse then begin
                _HasWorkflowResponse := false;
                Request.SetWorkflowResponse(_WorkflowResponseContent);
            end;
        end;
        InvokeFrontEndAsync(Request);
    end;

    procedure WorkflowResponse(ResponseContent: Variant)
    begin
        MakeSureFrameworkIsAvailableIn20(true);
        _HasWorkflowResponse := true;
        _WorkflowResponseContent := ResponseContent;
    end;

    [Obsolete('Queue workflow is not supported anymore.', 'NPR23.0')]
    procedure QueueWorkflow(ActionCode: Text; Context: Text)
    begin
        Error('QueueWorkflow method in POSFrontEndManagement codeunit is no longer supported');
    end;

    #region Dragonglass Awaitable Methods Response Context

    /// <summary>
    /// Inspects the context objects to determine if it contains a Dragonglass back-end invocation response context. This context
    /// is present on those back-end custom methods that await a response from the back-end upon invocation.
    /// </summary>
    /// <param name="Context">Context object</param>
    /// <returns></returns>
    procedure HasDragonglassResponseContext(Context: JsonObject): Boolean
    begin
        exit(Context.Contains(_DragonglassResponseContextLbl));
    end;

    /// <summary>
    /// Responds to an awaitable Dragonglass back-end invocation. The method will first inspect context to confirm that it is
    /// being invoked inside a OnCustomMethod invocation stack made for an awaitable method. If this cannot be confirmed, then
    /// invoking this method has no effect. Then, the method will provide the response to the front end. Finally, the method will
    /// mark the response in the context object so that the infrastructure can validate if the response was sent to the front end.
    /// Awaitable methods must invoke `RespondToFrontEndMethod` before completing their call stack.
    /// </summary>
    /// <param name="Context">Original method invocation context</param>
    /// <param name="Response">Response object to send to the front end. Awaitable method invocation will receive this object as response.</param>
    /// <param name="This">Current instance of Front-end Management.</param>
    procedure RespondToFrontEndMethod(Context: JsonObject; Response: JsonObject; This: Codeunit "NPR POS Front End Management")
    var
        Request: Codeunit "NPR Front-End: Generic";
        JSON: Codeunit "NPR POS JSON Management";
        DragonglassContext: JsonObject;
        Id: Text;
        Method: Text;
        RetrievingMethodContextErr: Label 'reading Dragonglass method invocation context';
    begin
        if not HasDragonglassResponseContext(Context) then
            exit;

        JSON.InitializeJObjectParser(Context, This);
        JSON.SetScope(_DragonglassResponseContextLbl);
        Id := JSON.GetStringOrFail('invocationId', RetrievingMethodContextErr);
        Method := JSON.GetStringOrFail('method', RetrievingMethodContextErr);
        Request.SetMethod('BackEndMethodInvocationResult');
        Request.GetContent().Add('id', Id);
        Request.GetContent().Add('method', Method);
        Request.GetContent().Add('response', Response);

        InvokeFrontEndAsync(Request);

        JSON.SetScopeRoot();
        DragonglassContext := JSON.GetJsonObject(_DragonglassResponseContextLbl);
        DragonglassContext.Add(_DragonglassInvocationRespondedLbl, true);
    end;

    /// <summary>
    /// Checks if custom awaitable method has responded to Dragonglass. Awaitable methods must provide their
    /// response.
    /// </summary>
    /// <param name="Context">Original invocation context</param>
    /// <returns>Boolean value indicating whether the response was sent to Dragonglass</returns>
    procedure IsDragonglassInvocationResponded(Context: JsonObject): Boolean
    var
        Token: JsonToken;
        DragonglassContext: JsonObject;
    begin
        if not Context.Get(_DragonglassResponseContextLbl, Token) or not Token.IsObject() then
            exit(false);

        DragonglassContext := Token.AsObject();

        if not DragonglassContext.Get(_DragonglassInvocationRespondedLbl, Token) or not Token.IsValue() then
            exit(false);

        exit(Token.AsValue().AsBoolean());
    end;

    #endregion

    #region Tracing
    local procedure PrepareTraceObject(Request: Interface "NPR Front-End Async Request"; TraceKey: Text) TraceObject: JsonObject;
    var
        TraceToken: JsonToken;
        TraceID: Label '_trace', Locked = true;
    begin
        if Request.GetContent().Get(TraceID, TraceToken) then begin
            TraceObject := TraceToken.AsObject();
            if TraceObject.Contains(TraceKey) then
                TraceObject.Remove(TraceKey);
        end else
            Request.GetContent().Add(TraceID, TraceObject);
    end;

    internal procedure Trace(Request: Interface "NPR Front-End Async Request"; TraceKey: Text; TraceValue: Text)
    begin
        PrepareTraceObject(Request, TraceKey).Add(TraceKey, TraceValue);
    end;

    internal procedure Trace(Request: Interface "NPR Front-End Async Request"; TraceKey: Text; TraceValue: Integer)
    begin
        PrepareTraceObject(Request, TraceKey).Add(TraceKey, TraceValue);
    end;
    #endregion

    #region Event Publishers
    [IntegrationEvent(true, false)]
    local procedure OnBeforeChangeToLoginView(POSSession: Codeunit "NPR POS Session")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeChangeToSaleView(POSSession: Codeunit "NPR POS Session")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeChangeToPaymentView(POSSession: Codeunit "NPR POS Session")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeChangeToBalanceRegisterView(POSSession: Codeunit "NPR POS Session")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeChangeToRestaurantView(POSSession: Codeunit "NPR POS Session")
    begin
    end;

    [Obsolete('Only server password secure methods will be supported going forward', 'NPR23.0')]
    [BusinessEvent(true)]
    local procedure OnRequestSecureMethodsClientPasswordsRegistration()
    begin
    end;

    #endregion
}

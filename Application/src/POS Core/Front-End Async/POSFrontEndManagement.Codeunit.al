codeunit 6150704 "NPR POS Front End Management"
{
    var
        POSSession: Codeunit "NPR POS Session";
        Framework: Interface "NPR Framework Interface";
        Text001: Label '%1\\This is a programming bug, not a user error.';
        Text002: Label 'A function that requires a POS session to be running has been invoked outside of a POS session.';
        Text003: Label 'Unsupported view type requested: %1.';
        RegisteredWorkflows: List of [Text];
        WorkflowStack: Codeunit "NPR Stack of [Integer]";
        ActionStack: Codeunit "NPR Stack of [Integer]";
        QueuedWorkflows: JsonArray;
        WorkflowResponseContent: Variant;
        HasWorkflowResponse: Boolean;
        Initialized: Boolean;
        Text005: Label 'You attempted to retrieve a POS session instance outside of an active POS session, with no POS user interface currently running.';
        Text006: Label 'An unknown workflow was invoked: %1.';
        Pausing: Boolean;
        Text008: Label 'A request was made to pause a workflow outside of a workflow context.';
        PausedWorkflowID: Integer;
        Text009: Label 'A request was made to pause workflow ID %1 while a workflow ID %2 is already paused. This is a critical back-end error which will reset the back-end state. You may be able to retry the same action again, and you may even be able to conitnue with the current transaction; however, the safest way to proceed would be to start a new sale transaction if possible.';
        Text010: Label 'A request was made to resume a paused workflow (ID %1) from within the context of another workflow (ID %2). This is a critical back-end error which will reset the back-end state. You may be able to retry the same action again, and you may even be able to conitnue with the current transaction; however, the safest way to proceed would be to start a new sale transaction if possible.';
        Workflow20ID: Integer;
        StepToContinueAt: Text;
        Text011: Label 'A request was made to continue current workflow at step %1, while no workflow is currently running.';
        Text012: Label 'A request was made to resume a workflow, while no workflow is currently in the paused state.';
        Text013: Label 'A method call was made on an uninitialized instance of the POS Front End Management codeunit, that requires an active and initialized instance to succeed.';
        Text015: Label 'A function that requires Workflow 2.0 engine to be initialized has been invoked from a Workflow 1.0 action.';
        ErrorDoNotCallSetActionContext: Label 'You have invoked SetActionContext from within a Workflows 2.0 action. This is an invalid operation.\\If you want to pass context to front end from a Workflows 2.0 action, it is enough to write to the Context object. In Workflows 2.0, context is automatically synchronized between AL and JavaScript.';

    procedure Initialize(FrameworkIn: Interface "NPR Framework Interface"; SessionIn: Codeunit "NPR POS Session")
    begin
        Framework := FrameworkIn;
        POSSession := SessionIn;

        Clear(RegisteredWorkflows);
        Clear(WorkflowStack);
        Clear(ActionStack);
        Clear(QueuedWorkflows);

        // The following variable is used only in debugging sessions to indicate whether this instance of the codeunit has actually
        // been initialized. There is no other purpose to this variable, but it is absolutely indispensable for debugging purposes.
        Initialized := true;
    end;

    local procedure IsActiveSession(): Boolean
    var
        FrameworkCheck: Interface "NPR Framework Interface";
        POSSessionCheck: Codeunit "NPR POS Session";
        Handled: Boolean;
    begin
        OnDetectFramework(FrameworkCheck, POSSessionCheck, Handled);
        if Handled then begin
            Initialize(FrameworkCheck, POSSessionCheck);
            exit(true);
        end else
            exit(false);
    end;

    procedure GetSession(var SessionOut: Codeunit "NPR POS Session")
    begin
        if not Initialized then
            Error(Text005);

        SessionOut := POSSession;
    end;

    #region Workflows 1.0 Coordination

    procedure WorkflowBackEndStepBegin(WorkflowId: Integer; ActionId: Integer)
    begin
        WorkflowStack.Push(WorkflowId);
        ActionStack.Push(ActionId);
    end;

    procedure WorkflowBackEndStepEnd()
    begin
        if StepToContinueAt <> '' then begin
            RequestWorkflowStep(StepToContinueAt);
            StepToContinueAt := '';
        end;

        if not Pausing then begin
            if WorkflowStack.Count() > 0 then
                WorkflowStack.Pop()
        end else
            Pausing := false;

        if ActionStack.Count() > 0 then
            ActionStack.Pop();
    end;

    local procedure CurrentWorkflowID(): Integer
    begin
        if WorkflowStack.Count() > 0 then
            exit(WorkflowStack.Peek());
    end;

    local procedure CurrentActionID(): Integer
    begin
        if ActionStack.Count() > 0 then
            exit(ActionStack.Peek());
    end;

    procedure AbortWorkflow(WorkflowID: Integer)
    begin
        if WorkflowID = CurrentWorkflowID() then begin
            WorkflowStack.Pop();
        end;

        if WorkflowID = PausedWorkflowID then
            PausedWorkflowID := 0;
    end;

    procedure AbortWorkflows()
    begin
        Pausing := false;
        PausedWorkflowID := 0;
        Clear(WorkflowStack);
        Clear(ActionStack);
        POSSession.ClearActionState();
    end;

    procedure ContinueAtStep(Step: Text)
    begin
        if CurrentWorkflowID = 0 then
            ReportBugAndThrowError(StrSubstNo(Text011, Step));

        StepToContinueAt := Step;
    end;

    procedure IsPaused(): Boolean
    begin
        exit(PausedWorkflowID > 0);
    end;

    #endregion

    #region Workflows 2.0 Coordination

    procedure CloneForWorkflow20(WorkflowIDIn: Integer; var FrontEndIn: Codeunit "NPR POS Front End Management")
    begin
        FrontEndIn.Initialize(Framework, POSSession);
        FrontEndIn.SetWorkflowID(WorkflowIDIn);
    end;

    procedure SetWorkflowID(WorkflowIDIn: Integer)
    begin
        Workflow20ID := WorkflowIDIn;
    end;

    #endregion

    local procedure MakeSureFrameworkIsAvailable(WithError: Boolean): Boolean
    begin
        if not Initialized then
            if IsActiveSession() then
                exit(true);

        if Initialized then
            exit(true);

        if WithError then
            Error(GetBugErrorMessage(Text002))
        else
            exit(false);
    end;

    local procedure MakeSureFrameworkIsAvailableIn20(WithError: Boolean): Boolean
    begin
        if Workflow20ID = 0 then begin
            if WithError then
                Error(GetBugErrorMessage(Text015))
            else
                exit(false);
        end;

        exit(MakeSureFrameworkIsAvailable(WithError));
    end;

    local procedure MakeSureFrameworkIsInitialized()
    begin
        if (not Initialized) THEN
            ReportBugAndThrowError(Text013);
    end;

    local procedure GetBugErrorMessage(Text: Text): Text
    begin
        exit(StrSubstNo(Text001, Text));
    end;

    local procedure RegisterWorkflowIfNecessary(Name: Code[20])
    var
        POSAction: Record "NPR POS Action";
        Button: Record "NPR POS Menu Button";
        WorkflowAction: Codeunit "NPR Workflow Action";
    begin
        if RegisteredWorkflows.Contains(Name) then
            exit;

        if not POSSession.RetrieveSessionAction(Name, POSAction) then
            ReportBugAndThrowError(StrSubstNo(Text006, Name));

        Button."Action Type" := Button."Action Type"::Action;
        Button."Action Code" := POSAction.Code;
        WorkflowAction.ConfigureFromMenuButton(Button, POSSession, WorkflowAction);

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
        POSView: Record "NPR POS View";
        DefaultView: Record "NPR POS Default View";
        DataMgt: Codeunit "NPR POS Data Management";
        POSViewChangeWorkflowMgt: Codeunit "NPR POS View Change WF Mgt.";
        Request: Codeunit "NPR Front-End: SetView";
        DataSource: Codeunit "NPR Data Source";
        CurrView: Codeunit "NPR POS View";
        RequestView: Codeunit "NPR POS View";
        DataSourceNames: List of [Text];
        Markup: Text;
        SourceId: Text;
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
        end;

        Request.GetView(RequestView);

        if RequestView.Type = RequestView.Type::Uninitialized then
            ReportBugAndThrowError(StrSubstNo(Text003, ViewType));

        POSSession.GetCurrentView(CurrView);
        case ViewType of
            DefaultView.Type::Login:
                OnBeforeChangeToLoginView(POSSession);
            DefaultView.Type::Sale:
                begin
                    if CurrView.Type = CurrView.Type::Login then
                        POSViewChangeWorkflowMgt.InvokeOnAfterLoginWorkflow(POSSession);

                    OnBeforeChangeToSaleView(POSSession);
                end;
            DefaultView.Type::Payment:
                OnBeforeChangeToPaymentView(POSSession);
            DefaultView.Type::Balance:
                OnBeforeChangeToBalanceRegisterView(POSSession);
            DefaultView.Type::Restaurant:
                OnBeforeChangeToRestaurantView(POSSession);
        end;

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

        POSSession.SetView(RequestView);
    end;

    #endregion


    local procedure InvokeFrontEndAsync(Request: Interface "NPR Front-End Async Request")
    var
        DebugTrace: Text;
        ServerStopwatch: Text;
    begin
        DebugTrace := POSSession.DebugFlush();
        if DebugTrace <> '' then
            Trace(Request, 'debug_trace', DebugTrace);

        ServerStopwatch := POSSession.ServerStopwatchFlush();
        if ServerStopwatch <> '' then
            Trace(Request, 'server_stopwatch', ServerStopwatch);

        Framework.InvokeFrontEndAsync(Request.GetJson());
    end;

    procedure InvokeFrontEndMethod(Request: Interface "NPR Front-End Async Request")
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
        if MakeSureFrameworkIsAvailable(false) then begin
            POSSession.SetInAction(false);
            Request.Initialize(ErrorText);
            InvokeFrontEndAsync(Request);
            Error(''); // Transaction must aborted and rolled back. It is mandatory.
        end else
            Error(GetBugErrorMessage(ErrorText));
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
            POSSession.SetInAction(false);
            Request.Initialize(ErrorText);
            Request.SetInvalidCustomMethod(Method);
            InvokeFrontEndAsync(Request);

            // It is mandatory that rrror be thrown now, and transaction aborted and rolled back.
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

    procedure AdvertiseStargatePackages()
    var
        Package: Record "NPR POS Stargate Package";
        PackageMethod: Record "NPR POS Stargate Pckg. Method";
        Request: Codeunit "NPR Front-End: StargatePkg.";
        Methods: JsonArray;
        PackageDefinition: JsonObject;
    begin
        if Package.FindSet() then begin
            repeat
                PackageMethod.Reset();
                PackageMethod.SetRange("Package Name", Package.Name);
                if PackageMethod.FindSet() then begin
                    Clear(Methods);
                    repeat
                        Methods.Add(PackageMethod."Method Name");
                    until PackageMethod.Next() = 0;

                    Clear(PackageDefinition);
                    PackageDefinition.Add('Name', Package.Name);
                    PackageDefinition.Add('Version', Package.Version);
                    PackageDefinition.Add('Methods', Methods);
                end;
                Request.AddPackage(PackageDefinition);
            until Package.Next() = 0;

            InvokeFrontEndAsync(Request);
        end;
    end;

    procedure ApplyAdministrativeTemplates(Templates: JsonArray)
    var
        Request: Codeunit "NPR Front-End: ApplAdminTempl.";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.Initialize('1.0');
        Request.SetTemplates(Templates);
        InvokeFrontEndAsync(Request);
    end;

    procedure ConfigureActionSequences(var TempSessionAction: Record "NPR POS Action" temporary)
    var
        Sequence: Record "NPR POS Action Sequence";
        Request: Codeunit "NPR Front-End: ConfigActSeq.";
        SequenceContent: JsonArray;
        SequenceEntry: JsonObject;
    begin
        Sequence.SetActionsForValidation(TempSessionAction);
        Sequence.RunActionSequenceDiscovery();
        if not Sequence.FindSet() then
            exit;

        MakeSureFrameworkIsAvailable(true);

        repeat
            Clear(SequenceEntry);
            SequenceEntry.Add('referenceAction', Sequence."Reference POS Action Code");
            SequenceEntry.Add('referenceType', LowerCase(Format(Sequence."Reference Type")));
            SequenceEntry.Add('action', Sequence."POS Action Code");
            SequenceEntry.Add('priority', Sequence."Sequence No.");
            SequenceContent.Add(SequenceEntry);
        until Sequence.Next() = 0;
        Request.SetSequences(SequenceContent);
        InvokeFrontEndAsync(Request);
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

    procedure ConfigureFont(Font: Interface "NPR Font Definition")
    var
        Request: Codeunit "NPR Front-End: ConfigFont.";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.SetFont(Font);
        InvokeFrontEndAsync(Request);
    end;

    procedure ConfigureKeyboardBindings(KeyboardBindings: List of [Text])
    var
        Request: Codeunit "NPR Front-End: ConfigKeyBind.";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.SetBindings(KeyboardBindings);
        InvokeFrontEndAsync(Request);
    end;

    procedure ConfigureReusableWorkflow("Action": Codeunit "NPR Workflow Action")
    var
        Request: Codeunit "NPR Front-End: CfgReusableWkf.";
        Workflow: Codeunit "NPR Workflow";
    begin
        Action.GetWorkflow(Workflow);
        if not RegisteredWorkflows.Contains(Workflow.Name) then
            RegisteredWorkflows.Add(Workflow.Name);

        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(Action);
        InvokeFrontEndAsync(Request);
    end;

    procedure ConfigureWatermark(WatermarkBase64: Text; WatermarkText: Text)
    var
        Request: Codeunit "NPR Front-End: SetImage";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.SetImage('watermark', WatermarkBase64);
        if WatermarkText <> '' then
            Request.GetContent().Add('watermarkText', WatermarkText);
        InvokeFrontEndAsync(Request);
    end;

    procedure ConfigureSecureMethods()
    var
        SecureMethodTmp: Record "NPR POS Secure Method" temporary;
        Request: Codeunit "NPR Front-End: CfgSecureMeth.";
        Method: JsonObject;
    begin
        MakeSureFrameworkIsAvailable(true);

        SecureMethodTmp.RunDiscovery();
        if SecureMethodTmp.FindSet() then
            repeat
                Clear(Method);
                Method.Add('description', SecureMethodTmp.Description);
                Method.Add('typeText', Format(SecureMethodTmp.Type));
                Method.Add('type', SecureMethodTmp.Type);
                if SecureMethodTmp.Type = SecureMethodTmp.Type::Custom then
                    Method.Add('handler', SecureMethodTmp.GetCustomMethodCode());
                Request.AddMethod(SecureMethodTmp.Code, Method);
            until SecureMethodTmp.Next() = 0;
        InvokeFrontEndAsync(Request);

        SecureMethodTmp.SetRange(Type, SecureMethodTmp.Type::"Password Client");
        if not SecureMethodTmp.IsEmpty then
            OnRequestSecureMethodsClientPasswordsRegistration();
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

    procedure HardwareInitializationComplete()
    var
        Request: Codeunit "NPR Front-End: Generic";
    begin
        Request.SetMethod('HardwareInitializationCompleted');
        InvokeFrontEndAsync(Request);
    end;

    // TODO: Request must be of an interface type that describes all stargate requests
    procedure InvokeDevice(Request: DotNet NPRNetRequest0; ActionName: Text; Step: Text)
    var
        Stargate: Codeunit "NPR POS Stargate Management";
        DeviceRequest: Codeunit "NPR Front-End: InvokeDevice";
        Envelope: DotNet NPRNetRequestEnvelope0;
    begin
        MakeSureFrameworkIsAvailable(true);

        POSSession.GetStargate(Stargate);
        Stargate.ResetRequestState(ActionName);
        Stargate.StoreRequest(Request, ActionName, Step);

        Envelope := Envelope.RequestEnvelope(Request);
        DeviceRequest.Initialize(Request.Method, Envelope.ToString());
        DeviceRequest.SetAction(ActionName, Step);
        DeviceRequest.SetMethod(Request.Method, Request.TypeName);
        InvokeFrontEndAsync(DeviceRequest);
    end;

    procedure InvokeDeviceInternal(Request: DotNet NPRNetRequest0; ActionName: Text; Step: Text; Repeating: Boolean)
    var
        Stargate: Codeunit "NPR POS Stargate Management";
        DeviceRequest: Codeunit "NPR Front-End: InvokeDevice";
        Envelope: DotNet NPRNetRequestEnvelope0;
    begin
        // Do not invoke this function from action codeunits. This function is intended to be used only from Stargate infrastructure code.

        MakeSureFrameworkIsAvailable(true);

        if Repeating then begin
            POSSession.GetStargate(Stargate);
            Stargate.StoreRequest(Request, ActionName, Step);
        end;

        Envelope := Envelope.RequestEnvelope(Request);
        DeviceRequest.Initialize(Request.Method, Envelope.ToString());
        DeviceRequest.SetAction(ActionName, Step);
        DeviceRequest.SetMethod(Request.Method, Request.TypeName);
        InvokeFrontEndAsync(DeviceRequest);
    end;

    // TODO: This method is unused. If by now nobody has ever called it from anywhere, most likely we don't need it!
    procedure InvokeDeviceAsync(Request: DotNet NPRNetRequest0; ActionName: Text; Step: Text)
    var
        Stargate: Codeunit "NPR POS Stargate Management";
        DeviceRequest: Codeunit "NPR Front-End: InvokeDevice";
        Envelope: DotNet NPRNetRequestEnvelope0;
    begin
        MakeSureFrameworkIsAvailable(true);

        POSSession.GetStargate(Stargate);
        Stargate.ResetRequestState(ActionName);
        Stargate.StoreRequest(Request, ActionName, Step);

        Envelope := Envelope.RequestEnvelope(Request);

        DeviceRequest.Initialize(Request.Method, Envelope.ToString());
        DeviceRequest.SetAction(ActionName, Step);
        DeviceRequest.SetMethod(Request.Method, Request.TypeName);
        DeviceRequest.SetAsync();
        InvokeFrontEndAsync(DeviceRequest);
    end;

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
        if POSSession.IsInAction and (CurrentWorkflowID > 0) then
            Request.SetNested(true);

        POSAction.GetWorkflowInvocationContext(WorkflowInvocationParameters, WorkflowInvocationContext);
        Request.SetParameters(WorkflowInvocationParameters);
        Request.SetWorkflowContext(WorkflowInvocationContext);

        InvokeFrontEndAsync(Request);
    end;

    procedure PauseWorkflow(): Integer
    var
        Request: Codeunit "NPR Front-End: PauseWorkflow";
        ErrorText: Text;
    begin
        if CurrentWorkflowID = 0 then
            ReportBugAndThrowError(Text008);

        if PausedWorkflowID > 0 then begin
            ErrorText := StrSubstNo(Text009, PausedWorkflowID, CurrentWorkflowID);
            AbortWorkflows();
            ReportBugAndThrowError(ErrorText);
        end;

        Pausing := true;
        PausedWorkflowID := CurrentWorkflowID;

        MakeSureFrameworkIsInitialized();
        Request.Initialize(CurrentWorkflowID());
        InvokeFrontEndAsync(Request);

        exit(PausedWorkflowID);
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

    local procedure RequestWorkflowStep(StepId: Text)
    var
        Request: Codeunit "NPR Front-End: WorkflowRequest";
    begin
        MakeSureFrameworkIsInitialized();
        Request.Initialize(CurrentWorkflowID(), '', StepId, CreateGuid());
        InvokeFrontEndAsync(Request);
    end;

    procedure ResumeWorkflow()
    var
        Request: Codeunit "NPR Front-End: ResumeWorkflow";
        ErrorText: Text;
    begin
        if PausedWorkflowID = 0 then
            ReportBugAndThrowError(Text012);

        if (CurrentWorkflowID <> PausedWorkflowID) and (CurrentWorkflowID <> 0) then begin
            ErrorText := StrSubstNo(Text010, PausedWorkflowID, CurrentWorkflowID);
            AbortWorkflows();
            ReportBugAndThrowError(ErrorText);
        end;

        MakeSureFrameworkIsInitialized();
        Request.Initialize(PausedWorkflowID, CurrentActionID);

        Pausing := false;
        PausedWorkflowID := 0;

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

    #region Model UI - TODO: refactor into Dragonglass!

    procedure ShowModel(Model: DotNet NPRNetModel) ModelID: Guid
    var
        Request: Codeunit "NPR Front-End: Generic";
        Html: Text;
        Css: Text;
        Script: Text;
    begin
        ModelID := CreateGuid();
        Html := Model.ToString().Trim();
        Css := Model.GetStyles().Trim();
        Script := Model.GetScripts().Trim();
        if (Html = '') and (Css = '') and (Script = '') then
            exit;

        Request.SetMethod('ShowModel');
        Request.GetContent().Add('modelId', ModelID);
        Request.GetContent().Add('html', Html);
        Request.GetContent().Add('css', Css);
        Request.GetContent().Add('script', Script);
        InvokeFrontEndAsync(Request);
    end;

    procedure UpdateModel(Model: DotNet NPRNetModel; ModelID: Guid)
    var
        Request: Codeunit "NPR Front-End: Generic";
        Html: Text;
        Css: Text;
        Script: Text;
    begin
        Html := Model.ToString().Trim();
        Css := Model.GetStyles().Trim();
        Script := Model.GetScripts().Trim();
        if (Html = '') and (Css = '') and (Script = '') then
            exit;

        Request.SetMethod('UpdateModel');
        Request.GetContent().Add('modelId', ModelID);
        Request.GetContent().Add('html', Html);
        Request.GetContent().Add('css', Css);
        Request.GetContent().Add('script', Script);
        InvokeFrontEndAsync(Request);
    end;

    procedure CloseModel(ModelID: Guid)
    var
        Request: Codeunit "NPR Front-End: Generic";
    begin
        Request.SetMethod('CloseModel');
        Request.GetContent().Add('modelId', ModelID);
        InvokeFrontEndAsync(Request);
    end;

    #endregion

    procedure StartTransaction(Sale: Record "NPR POS Sale")
    var
        Request: Codeunit "NPR Front-End: StartTrans.";
    begin
        MakeSureFrameworkIsAvailable(true);
        Request.Initialize(Sale);
        InvokeFrontEndAsync(Request);
    end;

    procedure SetActionContext("Action": Text; Context: Codeunit "NPR POS JSON Management")
    var
        Request: Codeunit "NPR Front-End: ProvideContext";
    begin
        if Workflow20ID > 0 then
            Error(ErrorDoNotCallSetActionContext);

        Request.Initialize(CurrentWorkflowID(), Action);
        Request.StoreContext(Context.GetContextObject());
        InvokeFrontEndAsync(Request);
    end;

    procedure WorkflowCallCompleted(Request: Codeunit "NPR Front-End: WkfCallCompl.")
    begin
        MakeSureFrameworkIsInitialized();
        if Workflow20ID > 0 then begin
            if HasWorkflowResponse then begin
                HasWorkflowResponse := false;
                Request.SetWorkflowResponse(WorkflowResponseContent);
            end;
            if QueuedWorkflows.Count() > 0 then
                Request.SetQueuedWorkflows(QueuedWorkflows);
        end;
        InvokeFrontEndAsync(Request);
    end;

    procedure WorkflowResponse(ResponseContent: Variant)
    begin
        MakeSureFrameworkIsAvailableIn20(true);
        HasWorkflowResponse := true;
        WorkflowResponseContent := ResponseContent;
    end;

    procedure QueueWorkflow(ActionCode: Text; Context: Text)
    begin
        MakeSureFrameworkIsAvailableIn20(true);
        QueuedWorkflows.Add(StrSubstNo('%1;%2', ActionCode, Context));
    end;

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

    procedure Trace(Request: Interface "NPR Front-End Async Request"; TraceKey: Text; TraceValue: Text)
    begin
        PrepareTraceObject(Request, TraceKey).Add(TraceKey, TraceValue);
    end;

    procedure Trace(Request: Interface "NPR Front-End Async Request"; TraceKey: Text; TraceValue: Integer)
    begin
        PrepareTraceObject(Request, TraceKey).Add(TraceKey, TraceValue);
    end;

    #endregion

    #region Event Publishers

    [IntegrationEvent(false, false)]
    local procedure OnDetectFramework(var FrameworkOut: Interface "NPR Framework Interface"; var POSSessionOut: Codeunit "NPR POS Session"; var Handled: Boolean)
    begin
    end;

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

    [BusinessEvent(true)]
    local procedure OnRequestSecureMethodsClientPasswordsRegistration()
    begin
    end;

    #endregion
}

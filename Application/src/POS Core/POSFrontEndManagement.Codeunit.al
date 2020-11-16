codeunit 6150704 "NPR POS Front End Management"
{
    // NPR5.32.11/VB /20170621  CASE 281618 Added watermak request.
    // NPR5.33/VB /20170630  CASE 282239 Modified logic to properly handle Stargate errors and issues.
    // NPR5.37/VB /20170929  CASE 291777 Short-term solution for just-in-case synchronization of Stargate packages in Major Tom
    // NPR5.37/VB  /20171024 CASE 293905 Added support for locked view
    // NPR5.38/VB  /20171120 CASE 295800 Implemented support for front-end keyboard bindings
    // NPR5.38/VB  /20171130 CASE 266990 Stargate "2.0" Protocol UI infrastructure implemented.
    // NPR5.38/VB  /20171206 CASE 255773 Generic front-end method invocation implemented to allow future front-end methods to be supported without introducing breaking changes to Transcendence core.
    // NPR5.39/VB  /20180219 CASE 305029 Invoking Stargate asynchronously.
    // NPR5.40/VB  /20180213 CASE 306347 Debug tracing implemented, refactoring some code due to temporary action discovery.
    // NPR5.40/VB  /20180305 CASE 255773 WYSIWYG improvements.
    // NPR5.40/MMV /20180314 CASE 307453 Performance.
    // NPR5.40/BHR /20180322 CASE 308408 Rename variable dataset to datasetline
    // NPR5.42/MMV /20180508 CASE 314128 Re-added support for button parameters when type <> Action
    // NPR5.43/VB  /20180528 CASE 315972 Additional context for Stargate calls included in every message.
    // NPR5.43/MMV /20180531 CASE 315838 Added server stopwatch functionality
    // NPR5.43/VB  /20180611 CASE 314603 Implemented secure method behavior functionality.
    // NPR5.44/JDH /20180731 CASE 323499 Changed all functions to be External
    // NPR5.45/VB  /20180803 CASE 315838 Implemented tracing functionality.
    // NPR5.46/TSA /20180914 CASE 314603 Added the AuthorizedBy in Secure Method response
    // NPR5.49/VB  /20181106 CASE 335141 Introducing the POS Theme functionality
    // NPR5.50/MHA /20190206 CASE 343617 Added OnAfterLogin Workflow
    // NPR5.50/VB  /20181223 CASE 338666 Supporting Workflows 2.0
    // NPR5.51/VB  /20190719 CASE 352582 POS Administrative Templates feature
    // NPR5.53/VB  /20190917 CASE 362777 Support for workflow sequencing (configuring/registering "before" and "after" workflow sequences that execute before or after another workflow)
    // NPR5.54/MMV /20200305 CASE 364340 Added mock constructor.
    // #381848/VB  /20200522 CASE 381848 Added support for Restaurant view.
    //                                   Refactored function SetView to local, and to accept Option instead of DotNet


    var
        POSSession: Codeunit "NPR POS Session";
        Stargate: Codeunit "NPR POS Stargate Management";
        Framework: Interface "NPR Framework Interface";
        Text001: Label '%1\\This is a programming bug, not a user error.';
        Text002: Label 'A function that requires a POS session to be running has been invoked outside of a POS session.';
        Text003: Label 'Unsupported view type requested: %1.';
        Text004: Label 'View has not been properly initialized. This is a critical error.\\View type: %1';
        RegisteredWorkflows: DotNet NPRNetList_Of_T;
        WorkflowStack: DotNet NPRNetStack_Of_T;
        ActionStack: DotNet NPRNetStack_Of_T;
        QueuedWorkflows: DotNet NPRNetList_Of_T;
        WorkflowResponseContent: Variant;
        Initialized: Boolean;
        Text005: Label 'You attempted to retrieve a POS session instance outside of an active POS session, with no POS user interface currently running.';
        Text006: Label 'An unknown workflow was invoked: %1.';
        Text007: Label 'Explicitly requested workflow %1';
        Pausing: Boolean;
        Text008: Label 'A request was made to pause a workflow outside of a workflow context.';
        PausedWorkflowID: Integer;
        Text009: Label 'A request was made to pause workflow ID %1 while a workflow ID %2 is already paused. This is a critical back-end error which will reset the back-end state. You may be able to retry the same action again, and you may even be able to conitnue with the current transaction; however, the safest way to proceed would be to start a new sale transaction if possible.';
        Text010: Label 'A request was made to resume a paused workflow (ID %1) from within the context of another workflow (ID %2). This is a critical back-end error which will reset the back-end state. You may be able to retry the same action again, and you may even be able to conitnue with the current transaction; however, the safest way to proceed would be to start a new sale transaction if possible.';
        WorkflowID: Integer;
        StepToContinueAt: Text;
        Text011: Label 'A request was made to continue current workflow at step %1, while no workflow is currently running.';
        Text012: Label 'A request was made to resume a workflow, while no workflow is currently in the paused state.';
        Text013: Label 'A method call was made on an uninitialized instance of the POS Front End Management codeunit, that requires an active and initialized instance to succeed.';
        Text014: Label 'A generic front-end method call was made without method context.';
        Text015: Label 'A function that requires Workflow 2.0 engine to be initialized has been invoked from a Workflow 1.0 action.';
        IsMock: Boolean;

    procedure Initialize(FrameworkIn: Interface "NPR Framework Interface"; SessionIn: Codeunit "NPR POS Session")
    begin
        Framework := FrameworkIn;
        POSSession := SessionIn;

        RegisteredWorkflows := RegisteredWorkflows.List();
        WorkflowStack := WorkflowStack.Stack();
        ActionStack := ActionStack.Stack();

        //-NPR5.50 [338666]
        QueuedWorkflows := QueuedWorkflows.List;
        //+NPR5.50 [338666]

        // The following variable is used only in debugging sessions to indicate whether this instance of the codeunit has actually
        // been initialized. There is no other purpose to this variable, but it is absolutely indispensable for debugging purposes.
        Initialized := true;
    end;

    procedure MockInitialize(SessionIn: Codeunit "NPR POS Session")
    begin
        //-NPR5.54 [364340]
        POSSession := SessionIn;

        RegisteredWorkflows := RegisteredWorkflows.List();
        WorkflowStack := WorkflowStack.Stack();
        ActionStack := ActionStack.Stack();
        QueuedWorkflows := QueuedWorkflows.List;

        IsMock := true;
        Initialized := true;
        //+NPR5.54 [364340]
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

    local procedure "--- Workflow Coordination ---"()
    begin
    end;

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
            if WorkflowStack.Count > 0 then
                WorkflowStack.Pop()
        end else
            Pausing := false;

        if ActionStack.Count > 0 then
            ActionStack.Pop();
    end;

    local procedure CurrentWorkflowID(): Integer
    begin
        if WorkflowStack.Count > 0 then
            exit(WorkflowStack.Peek());
    end;

    local procedure CurrentActionID(): Integer
    begin
        if ActionStack.Count > 0 then
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
        WorkflowStack.Clear();
        ActionStack.Clear();
        POSSession.ClearActionState();
    end;

    procedure ContinueAtStep(Step: Text)
    begin
        if CurrentWorkflowID = 0 then
            ReportBug(StrSubstNo(Text011, Step));

        StepToContinueAt := Step;
    end;

    procedure IsPaused(): Boolean
    begin
        exit(PausedWorkflowID > 0);
    end;

    local procedure "--Workflow 2.0 Coordination--"()
    begin
    end;

    procedure CloneForWorkflow20(WorkflowIDIn: Integer; var FrontEndIn: Codeunit "NPR POS Front End Management")
    begin
        //-NPR5.50 [338666]
        FrontEndIn.Initialize(Framework, POSSession);
        FrontEndIn.SetWorkflowID(WorkflowIDIn);
        //+NPR5.50 [338666]
    end;

    procedure SetWorkflowID(WorkflowIDIn: Integer)
    begin
        //-NPR5.50 [338666]
        WorkflowID := WorkflowIDIn;
        //+NPR5.50 [338666]
    end;

    local procedure "---Locals---"()
    begin
    end;

    local procedure MakeSureFrameworkIsAvailable(WithError: Boolean): Boolean
    begin
        //-NPR5.54 [364340]
        if IsMock then
            exit(true);
        //+NPR5.54 [364340]

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
        //-NPR5.54 [364340]
        if IsMock then
            exit(true);
        //+NPR5.54 [364340]

        if WorkflowID = 0 then begin
            if WithError then
                Error(GetBugErrorMessage(Text015))
            else
                exit(false);
        end;

        exit(MakeSureFrameworkIsAvailable(WithError));
    end;

    local procedure MakeSureFrameworkfIsInitialized()
    begin
        if IsMock then
            exit;

        if (not Initialized) THEN
            ReportBug(Text013);
    end;

    local procedure GetBugErrorMessage(Text: Text): Text
    begin
        exit(StrSubstNo(Text001, Text));
    end;

    local procedure RegisterWorkflowIfNecessary(Name: Code[20])
    var
        POSAction: Record "NPR POS Action";
        Button: Record "NPR POS Menu Button";
        UI: Codeunit "NPR POS UI Management";
        WorkflowAction: DotNet NPRNetWorkflowAction;
        POSParameterValue: Record "NPR POS Parameter Value";
    begin
        if RegisteredWorkflows.Contains(Name) then
            exit;

        if not POSSession.RetrieveSessionAction(Name, POSAction) then
            ReportBug(StrSubstNo(Text006, Name));

        Button."Action Type" := Button."Action Type"::Action;
        Button."Action Code" := POSAction.Code;
        Button.GetAction(WorkflowAction, POSSession, StrSubstNo(Text007, Name), POSParameterValue);

        ConfigureReusableWorkflow(WorkflowAction);
    end;

    local procedure "---Front-End Shortcut Methods---"()
    begin
    end;

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

    local procedure "---Front-End Methods---"()
    begin
    end;

    local procedure InvokeFrontEndAsync(Request: DotNet NPRNetJsonRequest)
    var
        DebugTrace: Text;
        ServerStopwatch: Text;
        JRequest: JsonObject;
    begin
        //-NPR5.54 [364340]
        if IsMock then
            exit;
        //+NPR5.54 [364340]

        DebugTrace := POSSession.DebugFlush();
        if DebugTrace <> '' then
            Trace(Request, 'debug_trace', DebugTrace);

        ServerStopwatch := POSSession.ServerStopwatchFlush();
        if ServerStopwatch <> '' then
            Trace(Request, 'server_stopwatch', ServerStopwatch);

        JRequest.ReadFrom(Request.ToJsonString());
        Framework.InvokeFrontEndAsync(JRequest);
    end;

    procedure InvokeFrontEndMethod(Request: DotNet NPRNetJsonRequest)
    begin
        MakeSureFrameworkIsAvailable(true);

        if IsNull(Request) then
            ReportBug(Text014);

        InvokeFrontEndAsync(Request);
    end;

    procedure ReportBug(ErrorText: Text)
    var
        Request: DotNet NPRNetReportBugJsonRequest;
        ErrorObject: DotNet NPRNetObject;
    begin
        if MakeSureFrameworkIsAvailable(false) then begin
            POSSession.SetInAction(false);
            Request := Request.ReportBugJsonRequest(ErrorText);
            ErrorObject := GetLastErrorObject;
            if not IsNull(ErrorObject) then
                Request.StoreLastErrorObjectInfo(GetLastErrorObject);
            InvokeFrontEndAsync(Request);

            // Error must be thrown now, and transaction aborted and rolled back. It is mandatory.
            // DO NOT change this behavior.
            Error('');
        end else
            Error(GetBugErrorMessage(ErrorText));
    end;

    procedure ReportWarning(ErrorText: Text; WithError: Boolean)
    var
        Request: DotNet NPRNetReportBugJsonRequest;
        ErrorObject: DotNet NPRNetObject;
    begin
        if MakeSureFrameworkIsAvailable(false) then begin
            Request := Request.ReportBugJsonRequest(ErrorText);
            Request.Content.Add('warning', true);
            if WithError then
                Request.Content.Add('withError', true);

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
        Request: DotNet NPRNetReportBugJsonRequest;
        ErrorObject: DotNet NPRNetObject;
    begin
        //-NPR5.50 [338666]
        if MakeSureFrameworkIsAvailable(false) then begin
            POSSession.SetInAction(false);
            Request := Request.ReportBugJsonRequest(ErrorText);
            Request.Content.Add('InvalidCustomMethod', Method);
            ErrorObject := GetLastErrorObject;
            if not IsNull(ErrorObject) then
                Request.StoreLastErrorObjectInfo(GetLastErrorObject);
            InvokeFrontEndAsync(Request);

            // Error must be thrown now, and transaction aborted and rolled back. It is mandatory.
            // DO NOT change this behavior.
            Error('');
        end else
            Error(GetBugErrorMessage(ErrorText));
        //+NPR5.50 [338666]
    end;

    procedure AppGatewayProtocolResponse(EventName: Text; EventData: Text)
    var
        Request: DotNet NPRNetAppGatewayProtocolResponse;
    begin
        MakeSureFrameworkIsAvailable(true);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request.AppGatewayProtocolResponse(EventName,EventData));
        InvokeFrontEndAsync(Request.AppGatewayProtocolResponse(EventName, EventData));
        //+NPR5.40 [306347]
    end;

    procedure AdvertiseStargatePackages()
    var
        Package: Record "NPR POS Stargate Package";
        PackageMethod: Record "NPR POS Stargate Pckg. Method";
        Request: DotNet NPRNetJsonRequest;
        Packages: DotNet NPRNetList_Of_T;
        Methods: DotNet NPRNetList_Of_T;
        PackageDefinition: DotNet NPRNetDictionary_Of_T_U;
    begin
        //-NPR5.37 [291777]
        if Package.FindSet then begin
            Packages := Packages.List();

            repeat
                PackageMethod.Reset;
                PackageMethod.SetRange("Package Name", Package.Name);
                if PackageMethod.FindSet then begin
                    Methods := Methods.List();
                    repeat
                        Methods.Add(PackageMethod."Method Name");
                    until PackageMethod.Next = 0;

                    PackageDefinition := PackageDefinition.Dictionary();
                    PackageDefinition.Add('Name', Package.Name);
                    PackageDefinition.Add('Version', Package.Version);
                    PackageDefinition.Add('Methods', Methods);
                end;
                Packages.Add(PackageDefinition);
            until Package.Next = 0;

            Request := Request.JsonRequest();
            Request.Method := 'StargatePackages';
            Request.Content.Add('Packages', Packages);
            //-NPR5.40 [306347]
            //  Framework.InvokeFrontEndAsync(Request);
            InvokeFrontEndAsync(Request);
            //+NPR5.40 [306347]
        end;
        //+NPR5.37 [291777]
    end;

    procedure ApplyAdministrativeTemplates(Templates: DotNet NPRNetList_Of_T)
    var
        Request: DotNet NPRNetJsonRequest;
    begin
        //-NPR5.51 [352582]
        MakeSureFrameworkIsAvailable(true);
        Request := Request.JsonRequest();
        Request.Method := 'ApplyAdministrativeTemplates';
        Request.Content.Add('version', '1.0');
        Request.Content.Add('templates', Templates);
        InvokeFrontEndAsync(Request);
        //+NPR5.51 [352582]
    end;

    procedure ConfigureActionSequences(var TempSessionAction: Record "NPR POS Action" temporary)
    var
        Sequence: Record "NPR POS Action Sequence";
        Request: DotNet NPRNetJsonRequest;
        SequenceContent: DotNet NPRNetList_Of_T;
        SequenceEntry: DotNet NPRNetDictionary_Of_T_U;
    begin
        //-NPR5.53 [362777]
        Sequence.SetActionsForValidation(TempSessionAction);
        Sequence.RunActionSequenceDiscovery();
        if not Sequence.FindSet() then
            exit;

        MakeSureFrameworkIsAvailable(true);

        Request := Request.JsonRequest();
        Request.Method := 'ConfigureActionSequences';
        SequenceContent := SequenceContent.List();
        repeat
            SequenceEntry := SequenceEntry.Dictionary();
            SequenceEntry.Add('referenceAction', Sequence."Reference POS Action Code");
            SequenceEntry.Add('referenceType', LowerCase(Format(Sequence."Reference Type")));
            SequenceEntry.Add('action', Sequence."POS Action Code");
            SequenceEntry.Add('priority', Sequence."Sequence No.");
            SequenceContent.Add(SequenceEntry);
        until Sequence.Next = 0;
        Request.Content.Add('sequences', SequenceContent);
        InvokeFrontEndAsync(Request);
        //+NPR5.53 [362777]
    end;

    procedure ConfigureCaptions(Captions: DotNet NPRNetDictionary_Of_T_U)
    var
        Request: DotNet NPRNetSetCaptionsJsonRequest;
    begin
        MakeSureFrameworkIsAvailable(true);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request.SetCaptionsJsonRequest(Captions));
        InvokeFrontEndAsync(Request.SetCaptionsJsonRequest(Captions));
        //+NPR5.40 [306347]
    end;

    procedure ConfigureFormat(NumberFormat: DotNet NPRNetNumberFormatInfo; DateFormat: DotNet NPRNetDateTimeFormatInfo)
    var
        Request: DotNet NPRNetSetFormatJsonRequest;
    begin
        MakeSureFrameworkIsAvailable(true);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request.SetFormatJsonRequest(NumberFormat,DateFormat));
        InvokeFrontEndAsync(Request.SetFormatJsonRequest(NumberFormat, DateFormat));
        //+NPR5.40 [306347]
    end;

    procedure ConfigureLogo(LogoBase64: Text)
    var
        Request: DotNet NPRNetSetImageJsonRequest;
    begin
        MakeSureFrameworkIsAvailable(true);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request.SetImageJsonRequest('logo','data:image/png;base64,' + LogoBase64));
        InvokeFrontEndAsync(Request.SetImageJsonRequest('logo', 'data:image/png;base64,' + LogoBase64));
        //+NPR5.40 [306347]
    end;

    procedure ConfigureMenu(Menus: DotNet NPRNetList_Of_T)
    var
        Request: DotNet NPRNetMenuRequest;
        Menu: DotNet NPRNetMenu;
    begin
        MakeSureFrameworkIsAvailable(true);
        Request := Request.MenuRequest();
        foreach Menu in Menus do
            Request.Menus.Add(Menu);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
    end;

    procedure ConfigureFont(Font: DotNet NPRNetFont0)
    var
        Request: DotNet NPRNetConfigureFontJsonRequest;
    begin
        MakeSureFrameworkIsAvailable(true);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request.ConfigureFontJsonRequest(Font));
        InvokeFrontEndAsync(Request.ConfigureFontJsonRequest(Font));
        //+NPR5.40 [306347]
    end;

    procedure ConfigureKeyboardBindings(KeyboardBindings: DotNet NPRNetList_Of_T)
    var
        Request: DotNet NPRNetJsonRequest;
    begin
        //-NPR5.38 [295800]
        Request := Request.JsonRequest();
        Request.Method := 'ConfigureKeyboardBindings';
        Request.Content.Add('bindings', KeyboardBindings);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
        //-NPR5.38 [295800]
    end;

    procedure ConfigureReusableWorkflow("Action": DotNet NPRNetWorkflowAction)
    var
        Request: DotNet NPRNetConfigureReusableWorkflowRequest;
    begin
        if not RegisteredWorkflows.Contains(Action.Workflow.Name) then
            RegisteredWorkflows.Add(Action.Workflow.Name);

        MakeSureFrameworkIsAvailable(true);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request.ConfigureReusableWorkflowRequest(Action));
        InvokeFrontEndAsync(Request.ConfigureReusableWorkflowRequest(Action));
        //+NPR5.40 [306347]
    end;

    procedure ConfigureWatermark(WatermarkBase64: Text; WatermarkText: Text)
    var
        Request: DotNet NPRNetSetImageJsonRequest;
    begin
        //-NPR5.32.11 [281618]
        MakeSureFrameworkIsAvailable(true);
        Request := Request.SetImageJsonRequest('watermark', 'data:image/png;base64,' + WatermarkBase64);
        if WatermarkText <> '' then
            Request.Content.Add('watermarkText', WatermarkText);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
        //+NPR5.32.11 [281618]
    end;

    procedure ConfigureSecureMethods()
    var
        SecureMethodTmp: Record "NPR POS Secure Method" temporary;
        Request: DotNet NPRNetJsonRequest;
        Method: DotNet NPRNetDictionary_Of_T_U;
        Methods: DotNet NPRNetDictionary_Of_T_U;
    begin
        //-NPR5.43 [314603]
        MakeSureFrameworkIsAvailable(true);
        Request := Request.JsonRequest();
        Request.Method := 'ConfigureSecureMethods';

        SecureMethodTmp.RunDiscovery();
        Methods := Methods.Dictionary();
        if SecureMethodTmp.FindSet() then
            repeat
                Method := Method.Dictionary();
                Method.Add('description', SecureMethodTmp.Description);
                Method.Add('typeText', Format(SecureMethodTmp.Type));
                Method.Add('type', SecureMethodTmp.Type);
                if SecureMethodTmp.Type = SecureMethodTmp.Type::Custom then
                    Method.Add('handler', SecureMethodTmp.GetCustomMethodCode());
                Methods.Add(SecureMethodTmp.Code, Method);
            until SecureMethodTmp.Next = 0;
        Request.Content.Add('methods', Methods);
        InvokeFrontEndAsync(Request);

        SecureMethodTmp.SetRange(Type, SecureMethodTmp.Type::"Password Client");
        if not SecureMethodTmp.IsEmpty then
            OnRequestSecureMethodsClientPasswordsRegistration();
        //+NPR5.43 [314603]
    end;

    procedure ConfigureSecureMethodsClientPasswords(Method: Text; CommaDelimitedPasswords: Text)
    var
        Request: DotNet NPRNetJsonRequest;
    begin
        //-NPR5.43 [314603]
        MakeSureFrameworkIsAvailable(true);
        Request := Request.JsonRequest();
        Request.Method := 'ConfigureSecureMethodsClientPasswords';
        Request.Content.Add('method', Method);
        Request.Content.Add('passwords', CommaDelimitedPasswords); // TODO: for anyone interested in enhancing this, it can also be an array of passwords here, the function will accept arrays
        InvokeFrontEndAsync(Request);
        //+NPR5.43 [314603]
    end;

    procedure ConfigureTheme(Theme: DotNet NPRNetList_Of_T)
    var
        Request: DotNet NPRNetJsonRequest;
    begin
        //-NPR5.49 [335141]
        MakeSureFrameworkIsAvailable(true);
        Request := Request.JsonRequest();
        Request.Method := 'ConfigureTheme';
        Request.Content.Add('theme', Theme);
        InvokeFrontEndAsync(Request);
        //+NPR5.49 [335141]
    end;

    procedure ValidateSecureMethodPassword(RequestId: Integer; Success: Boolean; SkipUI: Boolean; Reason: Text; AuthorizedBy: Text)
    var
        Request: DotNet NPRNetJsonRequest;
    begin
        //-NPR5.43 [314603]
        MakeSureFrameworkIsAvailable(true);
        Request := Request.JsonRequest();
        Request.Method := 'ValidateSecureMethodPassword';
        Request.Content.Add('requestId', RequestId);
        Request.Content.Add('success', Success);
        //-NPR5.46 [314603]
        Request.Content.Add('authorizedBy', AuthorizedBy);
        //+NPR5.46 [314603]

        if (not Success) then begin
            Request.Content.Add('skipUi', SkipUI);
            Request.Content.Add('reason', Reason);
        end;
        InvokeFrontEndAsync(Request);
        //+NPR5.43 [314603]
    end;

    procedure HardwareInitializationComplete()
    var
        Request: DotNet NPRNetJsonRequest;
    begin
        Request := Request.JsonRequest();
        Request.Method := 'HardwareInitializationCompleted';
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
    end;

    procedure InvokeDevice(Request: DotNet NPRNetRequest0; ActionName: Text; Step: Text)
    var
        Stargate: Codeunit "NPR POS Stargate Management";
        DeviceRequest: DotNet NPRNetInvokeDeviceRequest;
        Envelope: DotNet NPRNetRequestEnvelope0;
        Exception: DotNet NPRNetException;
    begin
        MakeSureFrameworkIsAvailable(true);

        POSSession.GetStargate(Stargate);
        Stargate.ResetRequestState(ActionName);
        Stargate.StoreRequest(Request, ActionName, Step);

        Envelope := Envelope.RequestEnvelope(Request);

        DeviceRequest := DeviceRequest.InvokeDeviceRequest(Request.Method, Envelope.ToString());
        DeviceRequest.Content.Add('Action', ActionName);
        DeviceRequest.Content.Add('Step', Step);
        //-NPR5.43 [315972]
        DeviceRequest.Content.Add('Method', Request.Method);
        DeviceRequest.Content.Add('TypeName', Request.TypeName);
        //+NPR5.43 [315972]
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(DeviceRequest);
        InvokeFrontEndAsync(DeviceRequest);
        //+NPR5.40 [306347]
    end;

    procedure InvokeDeviceInternal(Request: DotNet NPRNetRequest0; ActionName: Text; Step: Text; Repeating: Boolean)
    var
        Stargate: Codeunit "NPR POS Stargate Management";
        DeviceRequest: DotNet NPRNetInvokeDeviceRequest;
        Envelope: DotNet NPRNetRequestEnvelope0;
        Exception: DotNet NPRNetException;
    begin
        // Do not invoke this function from action codeunits. This function is intended to be used only from Stargate infrastructure code.

        MakeSureFrameworkIsAvailable(true);

        if Repeating then begin
            POSSession.GetStargate(Stargate);
            Stargate.StoreRequest(Request, ActionName, Step);
        end;

        Envelope := Envelope.RequestEnvelope(Request);

        DeviceRequest := DeviceRequest.InvokeDeviceRequest(Request.Method, Envelope.ToString());
        DeviceRequest.Content.Add('Action', ActionName);
        DeviceRequest.Content.Add('Step', Step);
        //-NPR5.43 [315972]
        DeviceRequest.Content.Add('Method', Request.Method);
        DeviceRequest.Content.Add('TypeName', Request.TypeName);
        //+NPR5.43 [315972]
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(DeviceRequest);
        InvokeFrontEndAsync(DeviceRequest);
        //+NPR5.40 [306347]
    end;

    procedure InvokeDeviceAsync(Request: DotNet NPRNetRequest0; ActionName: Text; Step: Text)
    var
        Stargate: Codeunit "NPR POS Stargate Management";
        DeviceRequest: DotNet NPRNetInvokeDeviceRequest;
        Envelope: DotNet NPRNetRequestEnvelope0;
        Exception: DotNet NPRNetException;
    begin
        //-NPR5.39 [305029]
        MakeSureFrameworkIsAvailable(true);

        POSSession.GetStargate(Stargate);
        Stargate.ResetRequestState(ActionName);
        Stargate.StoreRequest(Request, ActionName, Step);

        Envelope := Envelope.RequestEnvelope(Request);

        DeviceRequest := DeviceRequest.InvokeDeviceRequest(Request.Method, Envelope.ToString());
        DeviceRequest.Content.Add('Action', ActionName);
        DeviceRequest.Content.Add('Step', Step);
        DeviceRequest.Content.Add('Async', true);
        //-NPR5.43 [315972]
        DeviceRequest.Content.Add('Method', Request.Method);
        DeviceRequest.Content.Add('TypeName', Request.TypeName);
        //+NPR5.43 [315972]
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(DeviceRequest);
        InvokeFrontEndAsync(DeviceRequest);
        //+NPR5.40 [306347]
        //+NPR5.39 [305029]
    end;

    procedure InvokeWorkflow(var POSAction: Record "NPR POS Action")
    var
        Request: DotNet NPRNetWorkflowRequest;
        WorkflowInvocationParameters: DotNet NPRNetDictionary_Of_T_U;
        WorkflowInvocationContext: DotNet NPRNetDictionary_Of_T_U;
    begin
        MakeSureFrameworkfIsInitialized();
        RegisterWorkflowIfNecessary(POSAction.Code);

        Request := Request.WorkflowRequest(CurrentWorkflowID(), POSAction.Code, '', CreateGuid); // TODO: must be real guid, or?
        Request.Content.Add('explicit', true);
        if POSSession.IsInAction and (CurrentWorkflowID > 0) then
            Request.Content.Add('nested', true);

        POSAction.GetWorkflowInvocationContext(WorkflowInvocationParameters, WorkflowInvocationContext);
        if not IsNull(WorkflowInvocationParameters) then
            Request.Content.Add('workflowParameters', WorkflowInvocationParameters);
        if not IsNull(WorkflowInvocationContext) then
            Request.Content.Add('workflowContext', WorkflowInvocationContext);

        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
    end;

    procedure PauseWorkflow(): Integer
    var
        Request: DotNet NPRNetPauseWorkflowJsonRequest;
        ErrorText: Text;
    begin
        if CurrentWorkflowID = 0 then
            ReportBug(Text008);

        if PausedWorkflowID > 0 then begin
            ErrorText := StrSubstNo(Text009, PausedWorkflowID, CurrentWorkflowID);
            AbortWorkflows();
            ReportBug(ErrorText);
        end;

        Pausing := true;
        PausedWorkflowID := CurrentWorkflowID;

        MakeSureFrameworkfIsInitialized();
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request.PauseWorkflowJsonRequest(CurrentWorkflowID()));
        InvokeFrontEndAsync(Request.PauseWorkflowJsonRequest(CurrentWorkflowID()));
        //+NPR5.40 [306347]

        exit(PausedWorkflowID);
    end;

    procedure RefreshData(DataSets: DotNet NPRNetIEnumerable_Of_T)
    var
        Request: DotNet NPRNetRefreshDataJsonRequest;
        DataSetLine: DotNet NPRNetDataSet;
    begin
        MakeSureFrameworkIsAvailable(true);

        Request := Request.RefreshDataJsonRequest();
        if not IsNull(DataSets) then

            //-NPR5.40 [308408]
            //FOREACH DataSet IN DataSets DO
            //    Request.AddDataSet(DataSet);
            foreach DataSetLine in DataSets do
                Request.AddDataSet(DataSetLine);
        //-NPR5.40 [308408]
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
    end;

    procedure RequireResponse(ID: Integer; RequiredContent: Text)
    var
        Request: DotNet NPRNetJsonRequest;
    begin
        //-NPR5.50 [338666]
        MakeSureFrameworkIsAvailable(true);
        Request := Request.JsonRequest();
        Request.Method := 'RequireResponse';
        Request.Content.Add('id', ID);
        Request.Content.Add('value', RequiredContent);
        InvokeFrontEndAsync(Request);
        //-NPR5.50 [338666]
    end;

    procedure RequireResponse(ID: Integer; RequiredContent: DotNet NPRNetWorkflowAction)
    var
        Request: DotNet NPRNetJsonRequest;
    begin
        //-NPR5.50 [338666]
        MakeSureFrameworkIsAvailable(true);
        Request := Request.JsonRequest();
        Request.Method := 'RequireResponse';
        Request.Content.Add('id', ID);
        Request.Content.Add('value', RequiredContent);
        InvokeFrontEndAsync(Request);
        //-NPR5.50 [338666]
    end;

    local procedure RequestWorkflowStep(StepId: Text)
    var
        Request: DotNet NPRNetWorkflowRequest;
        Item: DotNet NPRNetKeyValuePair_Of_T_U;
    begin
        MakeSureFrameworkfIsInitialized();
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request.WorkflowRequest(CurrentWorkflowID(),'',StepId,CREATEGUID)); // TODO - must be real guid, or?
        InvokeFrontEndAsync(Request.WorkflowRequest(CurrentWorkflowID(), '', StepId, CreateGuid)); // TODO - must be real guid, or?
        //+NPR5.40 [306347]
    end;

    procedure RequestCustomWorkflowStep(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        // TODO: Implement this method.

        FrontEnd.ReportBug('RequestCustomWorkflowStep: Method not implemented error.');
        // The idea behind this method is that you can invoke a custom workflow step containing custom JavaScript, custom parameters and everything
        // It would then execute as an in-between step, right after current step, and before the next step.
        // However, right now it's not implemented.
    end;

    procedure ResumeWorkflow()
    var
        Request: DotNet NPRNetResumeWorkflowJsonRequest;
        ErrorText: Text;
    begin
        if PausedWorkflowID = 0 then
            ReportBug(Text012);

        if (CurrentWorkflowID <> PausedWorkflowID) and (CurrentWorkflowID <> 0) then begin
            ErrorText := StrSubstNo(Text010, PausedWorkflowID, CurrentWorkflowID);
            AbortWorkflows();
            ReportBug(ErrorText);
        end;

        MakeSureFrameworkfIsInitialized();
        Request := Request.ResumeWorkflowJsonRequest(PausedWorkflowID);
        Request.Content.Add('actionId', CurrentActionID);

        Pausing := false;
        PausedWorkflowID := 0;

        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
    end;

    procedure SetOption(Option: Text; Value: Variant)
    var
        Request: DotNet NPRNetSetOptionJsonRequest;
    begin
        MakeSureFrameworkIsAvailable(true);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request.SetOptionJsonRequest(Option,Value));
        InvokeFrontEndAsync(Request.SetOptionJsonRequest(Option, Value));
        //+NPR5.40 [306347]
    end;

    procedure SetOptions(Options: DotNet NPRNetDictionary_Of_T_U)
    var
        Request: DotNet NPRNetJsonRequest;
    begin
        MakeSureFrameworkIsAvailable(true);
        Request := Request.JsonRequest();
        Request.Method := 'SetOptions';
        Request.Content := Options;
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
    end;

    procedure SetView(ViewType: Option; Setup: Codeunit "NPR POS Setup")
    var
        POSView: Record "NPR POS View";
        DefaultView: Record "NPR POS Default View";
        DataMgt: Codeunit "NPR POS Data Management";
        SessionEvent: Codeunit "NPR POS Session";
        POSViewChangeWorkflowMgt: Codeunit "NPR POS View Change WF Mgt.";
        Request: DotNet NPRNetSetViewJsonRequest;
        DataSource: DotNet NPRNetDataSource0;
        CurrView: DotNet NPRNetView0;
        CurrViewType: DotNet NPRNetViewType0;
        Markup: Text;
        SourceId: Text;
        KnownView: Boolean;
    begin
        MakeSureFrameworkIsAvailable(true);
        case ViewType of
            DefaultView.Type::Login:
                begin
                    Request := Request.Login();
                    DefaultView.Type := DefaultView.Type::Login;
                end;
            DefaultView.Type::Sale:
                begin
                    Request := Request.Sale();
                    DefaultView.Type := DefaultView.Type::Sale;
                end;
            DefaultView.Type::Payment:
                begin
                    Request := Request.Payment();
                    DefaultView.Type := DefaultView.Type::Payment;
                end;
            DefaultView.Type::Balance:
                begin
                    Request := Request.BalanceRegister();
                    DefaultView.Type := DefaultView.Type::Balance;
                end;
            DefaultView.Type::Locked:
                begin
                    Request := Request.Login();
                    Request.View.Type := 11;
                    DefaultView.Type := DefaultView.Type::Locked;
                end;
            DefaultView.Type::Restaurant:
                begin
                    Request := Request.Login();
                    Request.View.Type := 12;
                    DefaultView.Type := DefaultView.Type::Restaurant;
                end;
        end;

        if IsNull(Request) then
            ReportBug(StrSubstNo(Text003, ViewType));

        //-NPR5.49 [343617]
        POSSession.GetCurrentView(CurrView);
        //+NPR5.49 [343617]
        case ViewType of
            DefaultView.Type::Login:
                OnBeforeChangeToLoginView(POSSession);
            DefaultView.Type::Sale:
                begin
                    if CurrView.Type.Equals(CurrViewType.Login) then
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
          Setup.Register())
        then begin
            Markup := POSView.GetMarkup();
            if Markup <> '' then
              //-NPR5.40 [255773]
              begin
                //+NPR5.40 [255773]
                Request.View.ParseLayout(POSView.GetMarkup());
                //-NPR5.40 [255773]
                Request.Content.Add('ViewCode', POSView.Code);
            end;
            //+NPR5.40 [255773]
        end;

        foreach SourceId in Request.View.GetDataSourceNames() do begin
            DataMgt.GetDataSource(SourceId, DataSource, Setup);
            Request.View.AddDataSource(DataSource);
        end;

        if Request.View.DataSources.Count = 0 then
            DataMgt.SetupDefaultDataSourcesForView(Request.View, Setup);

        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]

        if IsNull(Request.View) then
            ReportBug(StrSubstNo(Text004, ViewType));

        POSSession.SetView(Request.View);
    end;

    procedure ShowModel(Model: DotNet NPRNetModel) ModelID: Guid
    var
        Request: DotNet NPRNetJsonRequest;
        Html: Text;
        Css: Text;
        Script: Text;
        String: DotNet NPRNetString;
    begin
        //-266990 [266990]
        ModelID := CreateGuid;
        Html := Model.ToString();
        Css := Model.GetStyles();
        Script := Model.GetScripts();
        if (String.IsNullOrWhiteSpace(Html) and String.IsNullOrWhiteSpace(Css) and String.IsNullOrWhiteSpace(Script)) then
            exit;

        Request := Request.JsonRequest();
        Request.Method := 'ShowModel';
        Request.Content.Add('modelId', ModelID);
        Request.Content.Add('html', Html);
        Request.Content.Add('css', Css);
        Request.Content.Add('script', Script);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
        //+266990 [266990]
    end;

    procedure UpdateModel(Model: DotNet NPRNetModel; ModelID: Guid)
    var
        Request: DotNet NPRNetJsonRequest;
        Html: Text;
        Css: Text;
        Script: Text;
        String: DotNet NPRNetString;
    begin
        //-266990 [266990]
        Html := Model.ToString();
        Css := Model.GetStyles();
        Script := Model.GetScripts();
        if (String.IsNullOrWhiteSpace(Html) and String.IsNullOrWhiteSpace(Css) and String.IsNullOrWhiteSpace(Script)) then
            exit;

        Request := Request.JsonRequest();
        Request.Method := 'UpdateModel';
        Request.Content.Add('modelId', ModelID);
        Request.Content.Add('html', Html);
        Request.Content.Add('css', Css);
        Request.Content.Add('script', Script);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
        //+266990 [266990]
    end;

    procedure CloseModel(ModelID: Guid)
    var
        Request: DotNet NPRNetJsonRequest;
    begin
        //-266990 [266990]
        Request := Request.JsonRequest();
        Request.Method := 'CloseModel';
        Request.Content.Add('modelId', ModelID);
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
        //+266990 [266990]
    end;

    procedure StartTransaction(Sale: Record "NPR Sale POS")
    var
        Request: DotNet NPRNetStartTransactionJsonRequest;
    begin
        MakeSureFrameworkIsAvailable(true);
        Request := Request.StartTransactionJsonRequest(Sale."Sales Ticket No.");
        Request.Content.Add('salesPerson', Sale."Salesperson Code");
        Request.Content.Add('register', Sale."Register No.");
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
    end;

    procedure SetActionContext("Action": Text; Context: Codeunit "NPR POS JSON Management")
    var
        Request: DotNet NPRNetProvideContextRequest;
        ContextObj: DotNet NPRNetDictionary_Of_T_U;
    begin
        Request := Request.ProvideContextRequest(CurrentWorkflowID());
        Context.GetContextObject(ContextObj);
        Request.StoreContext(ContextObj);
        Request.Content.Add('actionCode', Action);

        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
    end;

    procedure SetActionObject("Action": Text; ObjectName: Text; Context: Codeunit "NPR POS JSON Management")
    var
        Request: DotNet NPRNetProvideContextRequest;
        ContextObj: DotNet NPRNetDictionary_Of_T_U;
    begin
        Request := Request.ProvideContextRequest(CurrentWorkflowID());
        Context.GetContextObject(ContextObj);
        Request.StoreContext(ContextObj);
        Request.Content.Add('objectName', ObjectName);

        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
    end;

    procedure WorkflowCallCompleted(Request: DotNet NPRNetWorkflowCallCompletedRequest)
    begin
        MakeSureFrameworkfIsInitialized();
        //-NPR5.40 [306347]
        //FrontEnd.InvokeFrontEndAsync(Request);
        //-NPR5.50 [338666]
        if WorkflowID > 0 then begin
            Request.Content.Add('workflowResponse', WorkflowResponseContent);
            if not IsNull(QueuedWorkflows) then
                Request.Content.Add('queuedWorkflows', QueuedWorkflows);
        end;
        //+NPR5.50 [338666]
        InvokeFrontEndAsync(Request);
        //+NPR5.40 [306347]
    end;

    procedure WorkflowResponse(ResponseContent: Variant)
    var
        Request: DotNet NPRNetJsonRequest;
        "Object": DotNet NPRNetObject;
    begin
        //-NPR5.50 [338666]
        MakeSureFrameworkIsAvailableIn20(true);
        WorkflowResponseContent := ResponseContent;
        //-NPR5.50 [338666]
    end;

    procedure QueueWorkflow(ActionCode: Text; Context: Text)
    begin
        //-NPR5.50 [338666]
        MakeSureFrameworkIsAvailableIn20(true);
        QueuedWorkflows.Add(StrSubstNo('%1;%2', ActionCode, Context));
        //+NPR5.50 [338666]
    end;

    local procedure "---Trace Methods---"()
    begin
    end;

    local procedure MakeSureTraceExists(Request: DotNet NPRNetJsonRequest)
    var
        Dict: DotNet NPRNetDictionary_Of_T_U;
    begin
        //-NPR5.45 [315838]
        if Request.Content.ContainsKey('_trace') then
            exit;

        Dict := Dict.Dictionary;
        Request.Content.Add('_trace', Dict);
        //+NPR5.45 [315838]
    end;

    procedure Trace(Request: DotNet NPRNetJsonRequest; "Key": Text; Value: Variant)
    var
        TraceDict: DotNet NPRNetDictionary_Of_T_U;
    begin
        //-NPR5.45 [315838]
        MakeSureTraceExists(Request);

        TraceDict := Request.Content.Item('_trace');
        if TraceDict.ContainsKey(Key) then
            TraceDict.Remove(Key);

        TraceDict.Add(Key, Value);
        //+NPR5.45 [315838]
    end;

    local procedure "---Framework auto-detection---"()
    begin
    end;

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
}


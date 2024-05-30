codeunit 6150701 "NPR POS JavaScript Interface"
{
    var
        _Stopwatch: Codeunit "NPR Stopwatch";

    // The purpose of this function is to detect if there are action codeunits that respond to either OnBeforeWorkflow or OnAction not intended for them.

    [Obsolete('Replaced with workflow v3. Delete when last v1 workflow is gone', 'NPR23.0')]
    internal procedure Initialize(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAction: Record "NPR POS Action";
        Parameters: JsonObject;
        Handled: Boolean;
        Text005: Label 'One or more action codeunits have responded to %1 event during back-end workflow engine initialization. This is a critical condition, therefore your session cannot continue. You should immediately contact support.';
        POSSession: Codeunit "NPR POS Session";
    begin
        OnBeforeWorkflow(POSAction, Parameters, POSSession, FrontEnd, Handled);
        if Handled then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text005, 'OnBeforeWorkflow'));

        Handled := false;
        OnAction(POSAction, '', Parameters, POSSession, FrontEnd, Handled);
        if Handled then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text005, 'OnAction'));
    end;

    [Obsolete('Replaced with workflow v3. Delete when last v1 workflow is gone', 'NPR23.0')]
    internal procedure InvokeAction("Action": Text[20]; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAction: Record "NPR POS Action";
        Signal: Codeunit "NPR Front-End: WkfCallCompl.";
        Handled: Boolean;
        Success: Boolean;
        Text001: Label 'Action %1 does not seem to have a registered handler, or the registered handler failed to notify the framework about successful processing of the action.';
        JSInterfaceErrorHandler: Codeunit "NPR JS Interface Error Handler";
    begin
        _Stopwatch.ResetAll();
        POSSession.RetrieveSessionAction(Action, POSAction);
        _Stopwatch.Start('All');

        POSSession.SetCursor(Context);

        OnBeforeInvokeAction(POSAction, WorkflowStep, Context, POSSession, FrontEnd);

        POSSession.SetInAction(true);
        FrontEnd.WorkflowBackEndStepBegin(WorkflowId, ActionId);
        _Stopwatch.Start('Action');

        Success := JSInterfaceErrorHandler.InvokeOnActionThroughOnRun(POSAction, WorkflowStep, Context, POSSession, FrontEnd, JSInterfaceErrorHandler, Handled);

        _Stopwatch.Stop('Action');
        FrontEnd.WorkflowBackEndStepEnd();
        POSSession.SetInAction(false);

        if not Handled and Success then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text001, Action));

        if Success then begin
            OnAfterInvokeAction(POSAction, WorkflowStep, Context, POSSession, FrontEnd);
            _Stopwatch.Start('Data');
            _Stopwatch.Stop('Data');
            Signal.SignalSuccess(WorkflowId, ActionId);
        end else begin
            POSSession.RequestFullRefresh(); //In case an action committed before error
            Signal.SignalFailureAndThrowError(WorkflowId, ActionId, GetLastErrorText);
            FrontEnd.Trace(Signal, 'ErrorCallStack', GetLastErrorCallstack);
        end;

        _Stopwatch.Stop('All');
        FrontEnd.Trace(Signal, 'durationAll', _Stopwatch.ElapsedMilliseconds('All'));
        FrontEnd.Trace(Signal, 'durationAction', _Stopwatch.ElapsedMilliseconds('Action'));
        FrontEnd.Trace(Signal, 'durationData', _Stopwatch.ElapsedMilliseconds('Data'));
        FrontEnd.Trace(Signal, 'durationOverhead', _Stopwatch.ElapsedMilliseconds('All') - _Stopwatch.ElapsedMilliseconds('Action') - _Stopwatch.ElapsedMilliseconds('Data'));

        FrontEnd.WorkflowCallCompleted(Signal);
    end;

    internal procedure InvokeMethod(Method: Text; Context: JsonObject; Self: Codeunit "NPR POS JavaScript Interface")
    var
        POSSession: Codeunit "NPR POS Session";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSRefreshData: Codeunit "NPR POS Refresh Data";
    begin
        POSSession.GetFrontEnd(FrontEnd, false);

        POSRefreshData.StartDataCollection();
        POSSession.SetPOSRefreshData(POSRefreshData);

        case Method of
            'OnAction20':
                if not Method_RunActionV3(Context, FrontEnd) then //Action30 is using the same event as Action20 in frontend. We fall back to old 2.0 backend implementation if not detected as enum impl.
                    InvokeCustomMethod(Method, Context, FrontEnd);
            'OnAction':
                Method_RunActionV1(Context, FrontEnd);
            'AbortWorkflow':
                Method_AbortWorkflow(FrontEnd, Context);
            'AbortAllWorkflows':
                Method_AbortAllWorkflows(FrontEnd);
            'BeforeWorkflow':
                Method_BeforeWorkflow(POSSession, FrontEnd, Context, Self);
            'Login':
                Method_Login(POSSession, FrontEnd, Context);
            'TextEnter':
                Method_TextEnter(POSSession, FrontEnd, Context);
            'FrontEndId':
                FrontEnd.HardwareInitializationComplete();
            'Unlock':
                Method_Unlock(POSSession, FrontEnd, Context);
            'InitializationComplete':
                InitializationComplete(POSSession);
            else
                InvokeCustomMethod(Method, Context, FrontEnd);
        end;

        if not (Method in ['Require', 'SecureMethod']) then
            POSRefreshData.Refresh();
    end;

    local procedure InvokeCustomMethod(Method: Text; Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        FailedInvocationResponse: JsonObject;
        Handled: Boolean;
        ExpectsResponse: Boolean;
        Success: Boolean;
        ContextString: Text;
        CustomMethodWithoutResponseErr: Label 'Custom awaitable method %1 was invoked, but it did not provide a response. This is a bug in the custom method handler codeunit.';
        Text002: Label 'An unknown method was invoked by the front end (JavaScript).\\Method: %1\Context: %2';
        JSInterfaceErrorHandler: Codeunit "NPR JS Interface Error Handler";
    begin
        if (Context.Contains('_dragonglassResponseContext')) then begin
            ExpectsResponse := true;
        end;

        Success := JSInterfaceErrorHandler.InvokeCustomMethodThroughOnRun(Method, Context, FrontEnd, JSInterfaceErrorHandler, Handled);

        if ExpectsResponse then begin
            if not FrontEnd.IsDragonglassInvocationResponded(Context) then begin
                if not Success then begin
                    FailedInvocationResponse.Add('_dragonglassInvocationError', true);
                    FrontEnd.RespondToFrontEndMethod(Context, FailedInvocationResponse, FrontEnd);
                end else
                    FrontEnd.ReportBugAndThrowError(StrSubstNo(CustomMethodWithoutResponseErr, Method));
            end;
        end else begin
            if (not Success) then
                if (Method in ['BalancingGetState', 'BalancingSetState']) then
                    FrontEnd.ReportBugAndThrowError(GetLastErrorText());
        end;

        if not Handled then begin
            Context.WriteTo(ContextString);
            FrontEnd.ReportInvalidCustomMethod(StrSubstNo(Text002, Method, ContextString), Method);
        end;
    end;

    local procedure InitializationComplete(POSSession: Codeunit "NPR POS Session")
    var
        StartTime: DateTime;
        POSRefreshData: Codeunit "NPR POS Refresh Data";
    begin
        StartTime := CurrentDateTime();

        POSSession.DebugWithTimestamp('InitializeUI');
        POSSession.InitializeUI();
        POSSession.DebugWithTimestamp('InitializeSession');
        POSSession.InitializeSession(false);

        POSRefreshData.SetFullRefresh();
        POSRefreshData.Refresh();

        LogFinishTelem(StartTime);
    end;

    local procedure LogFinishTelem(StartTime: DateTime)
    var
        FinishEventIdTok: Label 'NPR_POSSessionInitialized', Locked = true;
        LogDict: Dictionary of [Text, Text];
        MsgTok: Label 'Company:%1, Tenant: %2, Instance: %3, Server: %4, Duration: %5';
        Msg: Text;
        ActiveSession: Record "Active Session";
        POSInitialized: Duration;
        DurationMs: Integer;
    begin
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);
        POSInitialized := CurrentDateTime() - StartTime;
        DurationMs := POSInitialized;

        LogDict.Add('NPR_Server', ActiveSession."Server Computer Name");
        LogDict.Add('NPR_Instance', ActiveSession."Server Instance Name");
        LogDict.Add('NPR_TenantId', Database.TenantId());
        LogDict.Add('NPR_CompanyName', CompanyName());
        LogDict.Add('NPR_UserID', ActiveSession."User ID");
        LogDict.Add('NPR_POSInitializationDuration', Format(DurationMs, 0, 9));

        Msg := StrSubstNo(MsgTok, CompanyName(), Database.TenantId(), ActiveSession."Server Instance Name", ActiveSession."Server Computer Name", Format(DurationMs, 0, 9));
        Session.LogMessage(FinishEventIdTok, 'POS Session Initialized: ' + Msg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, LogDict);
    end;

    internal procedure ApplyDataState(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        JObject: JsonObject;
        JValue: JsonValue;
        JToken: JsonToken;
        DataStore: Codeunit "NPR Data Store";
        DataSet: Codeunit "NPR Data Set";
        Position: Text;
        JsonKey: Text;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        if not JSON.SetScope('data') then
            exit;
        if not JSON.SetScope('positions') then
            exit;

        JSON.GetJObject(JObject);
        foreach JsonKey in JObject.Keys do begin
            if (JObject.Get(JsonKey, JToken)) then begin
                JValue := JToken.AsValue();
                if (not JValue.IsNull()) and (not JValue.IsUndefined()) then begin
                    Position := JValue.AsText();
                    POSSession.GetDataStore(DataStore);
                    DataStore.GetDataSet(JsonKey, DataSet);
                    if DataSet.CurrentPosition() <> Position then begin
                        DataSet.SetCurrentPosition(Position);
                        SetPosition(POSSession, DataSet, Position, FrontEnd);
                    end;
                end;
            end;
        end;
    end;

    local procedure SetPosition(POSSession: Codeunit "NPR POS Session"; DataSet: Codeunit "NPR Data Set"; Position: Text; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Data: Codeunit "NPR POS Data Management";
        Handled: Boolean;
        Text004: Label 'No data driver responded to %1 event for %2 data source.';
    begin
        Data.OnSetPosition(DataSet.DataSource(), Position, POSSession, Handled);
        if not Handled then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text004, 'OnSetPosition', DataSet.DataSource()));
    end;

    local procedure Method_RunActionV1(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JToken: JsonToken;
        ActionCode: Text;
        WorkflowStep: Text;
        WorkflowID: Integer;
        ActionID: Integer;
        ActionContext: JsonObject;
        POSSession: Codeunit "NPR POS Session";
    begin
        Context.SelectToken('action', JToken);
        ActionCode := JToken.AsValue().AsText();
        Context.SelectToken('workflowStep', JToken);
        WorkflowStep := JToken.AsValue().AsText();
        Context.SelectToken('workflowId', JToken);
        WorkflowID := JToken.AsValue().AsInteger();
        Context.SelectToken('actionId', JToken);
        ActionID := JToken.AsValue().AsInteger();
        Context.SelectToken('context', JToken);
        ActionContext := JToken.AsObject();

        InvokeAction(CopyStr(ActionCode, 1, 20), WorkflowStep, WorkflowId, actionId, ActionContext, POSSession, FrontEnd);
    end;

    local procedure Method_RunActionV3(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        Workflow30: Codeunit "NPR POS Workflow 3.0";
    begin
        exit(Workflow30.RunIfAction30(Context, FrontEnd));
    end;

    [Obsolete('Delete when workflow v1 is gone', 'NPR23.0')]
    local procedure Method_AbortWorkflow(FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        WorkflowID: Integer;
        ReadingWorkflowIdErr: Label 'reading workflow ID';
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        WorkflowID := JSON.GetIntegerOrFail('id', ReadingWorkflowIdErr);
        if WorkflowID > 0 then
            FrontEnd.AbortWorkflow(WorkflowID);
    end;

    [Obsolete('Delete when workflow v1 is gone', 'NPR23.0')]
    local procedure Method_AbortAllWorkflows(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        FrontEnd.AbortWorkflows();
    end;

    [Obsolete('Delete when workflow v1 is gone', 'NPR23.0')]
    local procedure Method_BeforeWorkflow(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject; Self: Codeunit "NPR POS JavaScript Interface")
    var
        POSAction: Record "NPR POS Action";
        JSON: Codeunit "NPR POS JSON Management";
        ParametersToken: JsonToken;
        Parameters: JsonObject;
        Signal: Codeunit "NPR Front-End: WkfCallCompl.";
        ActionName: Text[20];
        WorkflowId: Integer;
        Handled: Boolean;
        Success: Boolean;
        Text003: Label 'No handler has responded to the RequestContext stage for action %1, or the registered handler failed to notify the framework about successful processing of the request.';
        ReadingParametersFailedErr: Label 'accessing parameters for workflow %1';
        ReadingActionNameErr: Label 'reading action name';
        ReadingWorkflowIdErr: Label 'reading workflow ID';
        JSInterfaceErrorHandler: Codeunit "NPR JS Interface Error Handler";
    begin
        _Stopwatch.ResetAll();

        ApplyDataState(Context, POSSession, FrontEnd);

        JSON.InitializeJObjectParser(Context, FrontEnd);
        ActionName := CopyStr(JSON.GetStringOrFail('action', ReadingActionNameErr), 1, MaxStrLen(ActionName));
        WorkflowId := JSON.GetIntegerOrFail('workflowId', ReadingWorkflowIdErr);
        ParametersToken := JSON.GetJTokenOrFail('parameters', StrSubstNo(ReadingParametersFailedErr, ActionName));
        Parameters := ParametersToken.AsObject();

        POSSession.RetrieveSessionAction(ActionName, POSAction);
        FrontEnd.WorkflowBackEndStepBegin(WorkflowId, 0);
        _Stopwatch.Start('Before');

        Success := JSInterfaceErrorHandler.InvokeOnBeforeWorkflowThroughOnRun(POSAction, Parameters, POSSession, FrontEnd, JSInterfaceErrorHandler, Handled);

        _Stopwatch.Stop('Before');
        FrontEnd.WorkflowBackEndStepEnd();

        if (not Success) or (not Handled) then begin
            if Success then begin
                Signal.SignalFailure(WorkflowId, 0);
                FrontEnd.WorkflowCallCompleted(Signal);
                FrontEnd.ReportBugAndThrowError(StrSubstNo(Text003, ActionName));
            end else begin
                Signal.SignalFailureAndThrowError(WorkflowId, 0, GetLastErrorText);
                FrontEnd.WorkflowCallCompleted(Signal);
            end;
            exit;
        end;

        Signal.SignalSuccess(WorkflowId, 0);
        Signal.GetContent().Add('durationBefore', _Stopwatch.ElapsedMilliseconds('Before'));

        FrontEnd.WorkflowCallCompleted(Signal);
    end;

    local procedure Method_Login(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        "Action": Record "NPR POS Action";
        Setup: Codeunit "NPR POS Setup";
    begin
        Setup.Action_Login(Action, POSSession);
        InvokeAction(Action.Code, '', 0, 0, Context, POSSession, FrontEnd);
    end;

    local procedure Method_TextEnter(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        "Action": Record "NPR POS Action";
        Setup: Codeunit "NPR POS Setup";
    begin
        Setup.Action_TextEnter(Action, POSSession);
        InvokeAction(Action.Code, '', 0, 0, Context, POSSession, FrontEnd);
    end;

    local procedure Method_Unlock(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        "Action": Record "NPR POS Action";
        Setup: Codeunit "NPR POS Setup";
    begin
        if (Setup.Action_UnlockPOS(Action, POSSession)) then
            InvokeAction(Action.Code, '', 0, 0, Context, POSSession, FrontEnd)
        else
            POSSession.ChangeViewSale();
    end;

    [Obsolete('Use workflow v3 instead. Delete when last v1/v2 workflow is gone.', 'NPR23.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInvokeAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInvokeAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [Obsolete('Use workflow v3 instead. Delete when last v1/v2 workflow is gone.', 'NPR23.0')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [Obsolete('0 references in core and ZAL. We do not want "overrule everything" event publishers in our 99% scenario path', 'NPR24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeInvokeMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [Obsolete('0 references in core and ZAL. We do not want "overrule everything" event publishers in our 99% scenario path', 'NPR24.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterInvokeMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [Obsolete('Use workflow v3 instead. Delete when last v1/v2 workflow is gone.', 'NPR23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    begin
    end;

    [Obsolete('Use workflow v3 instead. Delete when last v1/v2 workflow is gone.', 'NPR23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnProtocolUITimer(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; var Handled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, true)]
    local procedure LogV1Actions(Action: Record "NPR POS Action"; var Handled: Boolean)
    var
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
        MessageTextLbl: Label '%1: (%2)', Locked = true;
    begin
        if Action.Code = '' then
            exit;

        // this will not be found if eg. Install of app was triggered via web client and session was closed
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_POSAction', Action.Code);
        CustomDimensions.Add('NPR_POSAction_version', Format(Action."Workflow Implementation"));
        CustomDimensions.Add('NPR_POSAction_Description', Action.Description);

        Session.LogMessage('NPR_POSAction_Legacy', StrSubstNo(MessageTextLbl, Action.Code, Format(Action."Workflow Implementation")), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;
}

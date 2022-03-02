codeunit 6150701 "NPR POS JavaScript Interface"
{
    var
        _LastView: Codeunit "NPR POS View";
        _Stopwatch: Codeunit "NPR Stopwatch";


    // The purpose of this function is to detect if there are action codeunits that respond to either OnBeforeWorkflow or OnAction not intended for them.

    [Obsolete('Replaced with workflow v3. Delete when last v1 workflow is gone')]
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

    [Obsolete('Replaced with workflow v3. Delete when last v1 workflow is gone')]
    internal procedure InvokeAction("Action": Text[20]; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS JavaScript Interface")
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
        ApplyDataState(Context, POSSession, FrontEnd);

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
            RefreshData(FrontEnd);
            _Stopwatch.Stop('Data');
            Signal.SignalSuccess(WorkflowId, ActionId);
        end else begin
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

    internal procedure InvokeMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS JavaScript Interface")
    begin
        OnBeforeInvokeMethod(Method, Context, POSSession, FrontEnd);

        case Method of
            'OnAction20':
                if not Method_RunAction30(Context, FrontEnd) then //Action30 is using the same event as Action20 in frontend. We fall back to old 2.0 backend implementation if not detected as enum impl.
                    InvokeCustomMethod(Method, Context, FrontEnd);
            'AbortWorkflow':
                Method_AbortWorkflow(FrontEnd, Context);
            'AbortAllWorkflows':
                Method_AbortAllWorkflows(FrontEnd);
            'BeforeWorkflow':
                Method_BeforeWorkflow(POSSession, FrontEnd, Context, Self);
            'Login':
                Method_Login(POSSession, FrontEnd, Context, Self);
            'TextEnter':
                Method_TextEnter(POSSession, FrontEnd, Context, Self);
#if not CLOUD
            'InvokeDeviceResponse':
                Method_InvokeDeviceResponse(POSSession, FrontEnd, Context);
            'Protocol':
                Method_Protocol(POSSession, FrontEnd, Context);
#endif
            'FrontEndId':
                FrontEnd.HardwareInitializationComplete();
            'Unlock':
                Method_Unlock(POSSession, FrontEnd, Context, Self);
            'ProtocolUIResponse':
                Method_ProtocolUIResponse(POSSession, FrontEnd, Context);
            'InitializationComplete':
                InitializationComplete(POSSession);
            else
                InvokeCustomMethod(Method, Context, FrontEnd);
        end;

        OnAfterInvokeMethod(Method, Context, POSSession, FrontEnd);
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
        end;

        if not Handled then begin
            Context.WriteTo(ContextString);
            FrontEnd.ReportInvalidCustomMethod(StrSubstNo(Text002, Method, ContextString), Method);
        end;
    end;

    local procedure InitializationComplete(POSSession: Codeunit "NPR POS Session")
    begin
        POSSession.DebugWithTimestamp('InitializeUI');
        POSSession.InitializeUI();
        POSSession.DebugWithTimestamp('InitializeSession');
        POSSession.InitializeSession(false);
    end;

    internal procedure RefreshData(FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DataMgt: Codeunit "NPR POS Data Management";
        DataSetsJson: JsonArray;
        DataSet: Codeunit "NPR Data Set";
        DataSetJson: JsonObject;
        DataSourceToken: JsonToken;
        DataSource: Codeunit "NPR Data Source";
        DataStore: Codeunit "NPR Data Store";
        View: Codeunit "NPR POS View";
        RefreshSource: Boolean;
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetCurrentView(View);
        POSSession.GetDataStore(DataStore);
        foreach DataSourceToken in View.GetDataSources() do begin
            Clear(DataSource);
            DataSource.Constructor(DataSourceToken.AsObject());
            RefreshSource := false;
            if (View.InstanceId() = _LastView.InstanceId()) and DataSource.PerSession() then
                DataMgt.OnIsDataSourceModified(POSSession, DataSource.Id(), RefreshSource)
            else
                RefreshSource := true;

            if RefreshSource then begin
                RefreshDataSet(POSSession, DataSource, DataSet, FrontEnd);
                DataSetJson := DataStore.StoreAndGetDelta(DataSet);
                DataSetsJson.Add(DataSetJson);
                DataSource.SetRetrievedInCurrentSession(true);
            end;
        end;

        FrontEnd.RefreshData(DataSetsJson);

        _LastView := View;
    end;

    local procedure RefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; var DataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DataMgt: Codeunit "NPR POS Data Management";
        Handled: Boolean;
        Text004: Label 'No data driver responded to %1 event for %2 data source.';
    begin
        DataMgt.OnRefreshDataSet(POSSession, DataSource, DataSet, FrontEnd, Handled);
        if not Handled then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text004, 'OnRefreshDataSet', DataSource.Id()));
        DataMgt.OnAfterRefreshDataSet(POSSession, DataSource, DataSet, FrontEnd);
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

    local procedure Method_RunAction30(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        Workflow30: Codeunit "NPR POS Workflow 3.0";
    begin
        exit(Workflow30.RunIfAction30(Context, FrontEnd));
    end;

    [Obsolete('Delete when workflow v1 is gone')]
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

    [Obsolete('Delete when workflow v1 is gone')]
    local procedure Method_AbortAllWorkflows(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        FrontEnd.AbortWorkflows();
    end;

    [Obsolete('Delete when workflow v1 is gone')]
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

    local procedure Method_Login(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject; Self: Codeunit "NPR POS JavaScript Interface")
    var
        "Action": Record "NPR POS Action";
        Setup: Codeunit "NPR POS Setup";
    begin
        Setup.Action_Login(Action, POSSession);
        InvokeAction(Action.Code, '', 0, 0, Context, POSSession, FrontEnd, Self);
    end;

    local procedure Method_TextEnter(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject; Self: Codeunit "NPR POS JavaScript Interface")
    var
        "Action": Record "NPR POS Action";
        Setup: Codeunit "NPR POS Setup";
    begin
        Setup.Action_TextEnter(Action, POSSession);
        InvokeAction(Action.Code, '', 0, 0, Context, POSSession, FrontEnd, Self);
    end;
#if not CLOUD

    [Obsolete('Delete when stargate is removed')]
    local procedure Method_InvokeDeviceResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Stargate: Codeunit "NPR POS Stargate Management";
        Method: Text;
        Response: Text;
        ActionName: Text;
        Step: Text;
        Success: Boolean;
        ReadingDeviceResponseErr: Label 'reading from device response';
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        Method := JSON.GetStringOrFail('id', ReadingDeviceResponseErr);
        Success := JSON.GetBooleanOrFail('success', ReadingDeviceResponseErr);
        Response := JSON.GetStringOrFail('response', ReadingDeviceResponseErr);
        ActionName := JSON.GetStringOrFail('action', ReadingDeviceResponseErr);
        Step := JSON.GetStringOrFail('step', ReadingDeviceResponseErr);

        if Success then
            Stargate.DeviceResponse(Method, Response, POSSession, FrontEnd, ActionName, Step)
        else
            Stargate.DeviceError(Method, Response, POSSession, FrontEnd);
    end;

    [Obsolete('Delete when stargate is removed')]
    local procedure Method_Protocol(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Stargate: Codeunit "NPR POS Stargate Management";
        EventName: Text;
        SerializedArguments: Text;
        ActionName: Text;
        Step: Text;
        Callback: Boolean;
        Forced: Boolean;
        ReadingFromProtocolMethodErr: Label 'reading from Protocol method context';
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        SerializedArguments := JSON.GetStringOrFail('arguments', ReadingFromProtocolMethodErr);
        ActionName := JSON.GetStringOrFail('action', ReadingFromProtocolMethodErr);
        Step := JSON.GetStringOrFail('step', ReadingFromProtocolMethodErr);

        if JSON.GetBoolean('closeProtocol') then begin
            Forced := JSON.GetBooleanOrFail('forced', ReadingFromProtocolMethodErr);
            Stargate.AppGatewayProtocolClosed(ActionName, Step, SerializedArguments, Forced, FrontEnd);
            exit;
        end;

        EventName := JSON.GetStringOrFail('event', ReadingFromProtocolMethodErr);
        Callback := JSON.GetBooleanOrFail('callback', ReadingFromProtocolMethodErr);
        Stargate.AppGatewayProtocol(ActionName, Step, EventName, SerializedArguments, Callback, FrontEnd);
    end;
#endif
    local procedure Method_Unlock(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject; Self: Codeunit "NPR POS JavaScript Interface")
    var
        "Action": Record "NPR POS Action";
        Setup: Codeunit "NPR POS Setup";
    begin
        if (Setup.Action_UnlockPOS(Action, POSSession)) then
            InvokeAction(Action.Code, '', 0, 0, Context, POSSession, FrontEnd, Self)
        else
            POSSession.ChangeViewSale();
    end;

    [Obsolete('Delete when workflow v1/v2 are gone')]
    local procedure Method_ProtocolUIResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ModelID: Guid;
        Sender: Text;
        EventName: Text;
        ErrorMessage: Text;
        Handled: Boolean;
        IsTimer: Boolean;
        ReadingFromProtocolUIResponseErr: Label 'reading from protocol UI response';
        Text006: Label 'No protocol codeunit responded to %1 method, sender ''%2'', event ''%3''. Protocol user interface %4 will now be aborted.';
        Text007: Label 'No protocol codeunit responded to Timer request. Protocol user interface %1 will now be aborted.';
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        Evaluate(ModelID, JSON.GetStringOrFail('modelId', ReadingFromProtocolUIResponseErr));
        Sender := JSON.GetStringOrFail('sender', ReadingFromProtocolUIResponseErr);
        EventName := JSON.GetStringOrFail('event', ReadingFromProtocolUIResponseErr);

        if (Sender = 'n$_timer') and (EventName = 'n$_timer') then begin
            IsTimer := true;
            OnProtocolUITimer(POSSession, FrontEnd, ModelID, Handled)
        end else
            OnProtocolUIResponse(POSSession, FrontEnd, ModelID, Sender, EventName, Handled);

        if not Handled then begin
            if IsTimer then
                ErrorMessage := StrSubstNo(Text007, ModelID)
            else
                ErrorMessage := StrSubstNo(Text006, 'ProtocolUIResponse', Sender, EventName, ModelID);

            FrontEnd.CloseModel(ModelID);
            FrontEnd.ReportBugAndThrowError(ErrorMessage);
        end;
    end;

    [Obsolete('Use workflow v3 instead. Delete when last v1/v2 workflow is gone.')]
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

    [Obsolete('Use workflow v3 instead. Delete when last v1/v2 workflow is gone.')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInvokeMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInvokeMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [Obsolete('Use workflow v3 instead. Delete when last v1/v2 workflow is gone.')]
    [IntegrationEvent(false, false)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    begin
    end;

    [Obsolete('Use workflow v3 instead. Delete when last v1/v2 workflow is gone.')]
    [IntegrationEvent(false, false)]
    local procedure OnProtocolUITimer(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; var Handled: Boolean)
    begin
    end;
}

codeunit 6150701 "NPR POS JavaScript Interface"
{
    var
        Text001: Label 'Action %1 does not seem to have a registered handler, or the registered handler failed to notify the framework about successful processing of the action.';
        Text002: Label 'An unknown method was invoked by the front end (JavaScript).\\Method: %1\Context: %2';
        Text003: Label 'No handler has responded to the RequestContext stage for action %1, or the registered handler failed to notify the framework about successful processing of the request.';
        Text004: Label 'No data driver responded to %1 event for %2 data source.';
        LastView: Codeunit "NPR POS View";
        Text005: Label 'One or more action codeunits have responded to %1 event during back-end workflow engine initialization. This is a critical condition, therefore your session cannot continue. You should immediately contact support.';
        Stopwatch: Codeunit "NPR Stopwatch";
        Text006: Label 'No protocol codeunit responded to %1 method, sender ''%2'', event ''%3''. Protocol user interface %4 will now be aborted.';
        Text007: Label 'No protocol codeunit responded to Timer request. Protocol user interface %1 will now be aborted.';
        TextErrorMustNotRunThisCodeunit: Label 'You must not run this codeunit directly. This codeunit is intended to be run only from within itself.', Locked = true; // This is development type of error, do not translate!
        ReadingParametersFailedErr: Label 'accessing parameters for workflow %1';
        ReadingWorkflowIdErr: Label 'reading workflow ID';
        ReadingActionNameErr: Label 'reading action name';

        OnRunType: Option InvokeAction,BeforeWorkflow,MethodInvocation;
        OnRunInitialized: Boolean;
        OnRunPOSAction: Record "NPR POS Action";
        OnRunWorkflowStep: Text;
        OnRunContext: JsonObject;
        OnRunParameters: JsonObject;
        OnRunPOSSession: Codeunit "NPR POS Session";
        OnRunFrontEnd: Codeunit "NPR POS Front End Management";
        OnRunHandled: Boolean;
        OnRunMethod: Text;

    trigger OnRun()
    begin
        if not OnRunInitialized then
            Error(TextErrorMustNotRunThisCodeunit);

        case OnRunType of
            OnRunType::InvokeAction:
                OnAction(OnRunPOSAction, OnRunWorkflowStep, OnRunContext, OnRunPOSSession, OnRunFrontEnd, OnRunHandled);
            OnRunType::BeforeWorkflow:
                OnBeforeWorkflow(OnRunPOSAction, OnRunParameters, OnRunPOSSession, OnRunFrontEnd, OnRunHandled);
            OnRunType::MethodInvocation:
                OnCustomMethod(OnRunMethod, OnRunContext, OnRunPOSSession, OnRunFrontEnd, OnRunHandled);
        end;
    end;

    local procedure InvokeOnActionThroughOnRun(POSActionIn: Record "NPR POS Action"; WorkflowStepIn: Text; ContextIn: JsonObject; POSSessionIn: Codeunit "NPR POS Session"; FrontEndIn: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS JavaScript Interface"; var Handled: Boolean) Success: Boolean
    begin
        OnRunHandled := false;
        OnRunInitialized := true;

        OnRunPOSAction := POSActionIn;
        OnRunWorkflowStep := WorkflowStepIn;
        OnRunContext := ContextIn;
        OnRunPOSSession := POSSessionIn;
        OnRunFrontEnd := FrontEndIn;
        OnRunType := OnRunType::InvokeAction;

        Success := Self.Run();
        Handled := OnRunHandled;

        OnRunInitialized := false;
    end;

    local procedure InvokeOnBeforeWorkflowThroughOnRun(POSActionIn: Record "NPR POS Action"; ParametersIn: JsonObject; POSSessionIn: Codeunit "NPR POS Session"; FrontEndIn: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS JavaScript Interface"; var Handled: Boolean) Success: Boolean
    begin
        OnRunHandled := false;
        OnRunInitialized := true;

        OnRunPOSAction := POSActionIn;
        OnRunParameters := ParametersIn;
        OnRunPOSSession := POSSessionIn;
        OnRunFrontEnd := FrontEndIn;
        OnRunType := OnRunType::BeforeWorkflow;

        Success := Self.Run();
        Handled := OnRunHandled;

        OnRunInitialized := false;
    end;

    local procedure InvokeCustomMethodThroughOnRun(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS JavaScript Interface"; var Handled: Boolean) Success: Boolean
    begin
        OnRunHandled := false;
        OnRunInitialized := true;

        OnRunMethod := Method;
        OnRunContext := Context;
        OnRunPOSSession := POSSession;
        OnRunFrontEnd := FrontEnd;
        OnRunType := OnRunType::MethodInvocation;

        Success := Self.Run();
        Handled := OnRunHandled;

        OnRunInitialized := false;
    end;

    // The purpose of this function is to detect if there are action codeunits that respond to either OnBeforeWorkflow or OnAction not intended for them.
    procedure Initialize(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAction: Record "NPR POS Action";
        Parameters: JsonObject;
        Handled: Boolean;
    begin
        OnBeforeWorkflow(POSAction, Parameters, POSSession, FrontEnd, Handled);
        if Handled then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text005, 'OnBeforeWorkflow'));

        Handled := false;
        OnAction(POSAction, '', Parameters, POSSession, FrontEnd, Handled);
        if Handled then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text005, 'OnAction'));
    end;

    procedure InvokeAction("Action": Text; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS JavaScript Interface")
    var
        POSAction: Record "NPR POS Action";
        Signal: Codeunit "NPR Front-End: WkfCallCompl.";
        Handled: Boolean;
        Success: Boolean;
    begin
        Stopwatch.ResetAll();
        POSSession.RetrieveSessionAction(Action, POSAction);
        Stopwatch.Start('All');
        ApplyDataState(Context, POSSession, FrontEnd);

        OnBeforeInvokeAction(POSAction, WorkflowStep, Context, POSSession, FrontEnd);

        POSSession.SetInAction(true);
        FrontEnd.WorkflowBackEndStepBegin(WorkflowId, ActionId);
        Stopwatch.Start('Action');

        Success := InvokeOnActionThroughOnRun(POSAction, WorkflowStep, Context, POSSession, FrontEnd, Self, Handled);

        Stopwatch.Stop('Action');
        FrontEnd.WorkflowBackEndStepEnd();
        POSSession.SetInAction(false);

        if not Handled and Success then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text001, Action));

        if Success then begin
            OnAfterInvokeAction(POSAction, WorkflowStep, Context, POSSession, FrontEnd);
            Stopwatch.Start('Data');
            RefreshData(POSSession, FrontEnd);
            Stopwatch.Stop('Data');
            Signal.SignalSuccess(WorkflowId, ActionId);
        end else begin
            Signal.SignalFailureAndThrowError(WorkflowId, ActionId, GetLastErrorText);
            FrontEnd.Trace(Signal, 'ErrorCallStack', GetLastErrorCallstack);
        end;

        Stopwatch.Stop('All');
        FrontEnd.Trace(Signal, 'durationAll', Stopwatch.ElapsedMilliseconds('All'));
        FrontEnd.Trace(Signal, 'durationAction', Stopwatch.ElapsedMilliseconds('Action'));
        FrontEnd.Trace(Signal, 'durationData', Stopwatch.ElapsedMilliseconds('Data'));
        FrontEnd.Trace(Signal, 'durationOverhead', Stopwatch.ElapsedMilliseconds('All') - Stopwatch.ElapsedMilliseconds('Action') - Stopwatch.ElapsedMilliseconds('Data'));

        FrontEnd.WorkflowCallCompleted(Signal);
    end;

    procedure InvokeMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS JavaScript Interface")
    begin
        // A method invoked from JavaScript logic that requests C/AL to execute specific non-business-logic processing (e.g. infrastructure, etc.)
        OnBeforeInvokeMethod(Method, Context, POSSession, FrontEnd);

        // TODO: All of these should be "custom" methods and run thorugh the InvokeCustomMethod codeunit
        case Method of
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
            'InvokeDeviceResponse':
                Method_InvokeDeviceResponse(POSSession, FrontEnd, Context);
            'Protocol':
                Method_Protocol(POSSession, FrontEnd, Context);
            'FrontEndId':
                FrontEnd.HardwareInitializationComplete(); //TODO: Delete when gone from addin
            'Unlock':
                Method_Unlock(POSSession, FrontEnd, Context, Self);
            'ProtocolUIResponse':
                Method_ProtocolUIResponse(POSSession, FrontEnd, Context);
            else
                InvokeCustomMethod(Method, Context, POSSession, FrontEnd, Self);
        end;

        OnAfterInvokeMethod(Method, Context, POSSession, FrontEnd);
    end;

    local procedure InvokeCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS JavaScript Interface")
    var
        FailedInvocationResponse: JsonObject;
        Handled: Boolean;
        ExpectsResponse: Boolean;
        Success: Boolean;
        ContextString: Text;
        CustomMethodWithoutResponseErr: Label 'Custom awaitable method %1 was invoked, but it did not provide a response. This is a bug in the custom method handler codeunit.';
    begin
        if (Context.Contains('_dragonglassResponseContext')) then begin
            ExpectsResponse := true;
        end;

        Success := InvokeCustomMethodThroughOnRun(Method, Context, POSSession, FrontEnd, Self, Handled);

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

    procedure RefreshData(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
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
    begin
        if not POSSession.IsDataRefreshNeeded() then
            exit;

        POSSession.GetCurrentView(View);
        POSSession.GetDataStore(DataStore);
        foreach DataSourceToken in View.GetDataSources() do begin
            Clear(DataSource);
            DataSource.Constructor(DataSourceToken.AsObject());
            RefreshSource := false;
            if (View.InstanceId() = LastView.InstanceId()) and DataSource.PerSession() then
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

        LastView := View;
    end;

    local procedure RefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: Codeunit "NPR Data Source"; var DataSet: Codeunit "NPR Data Set"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DataMgt: Codeunit "NPR POS Data Management";
        Handled: Boolean;
    begin
        DataMgt.OnRefreshDataSet(POSSession, DataSource, DataSet, FrontEnd, Handled);
        if not Handled then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text004, 'OnRefreshDataSet', DataSource.Id()));
        DataMgt.OnAfterRefreshDataSet(POSSession, DataSource, DataSet, FrontEnd);
    end;

    procedure ApplyDataState(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
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
    begin
        Data.OnSetPosition(DataSet.DataSource(), Position, POSSession, Handled);
        if not Handled then
            FrontEnd.ReportBugAndThrowError(StrSubstNo(Text004, 'OnSetPosition', DataSet.DataSource()));
    end;

    local procedure Method_AbortWorkflow(FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        WorkflowID: Integer;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        WorkflowID := JSON.GetIntegerOrFail('id', ReadingWorkflowIdErr);
        if WorkflowID > 0 then
            FrontEnd.AbortWorkflow(WorkflowID);
    end;

    local procedure Method_AbortAllWorkflows(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        FrontEnd.AbortWorkflows();
    end;

    local procedure Method_BeforeWorkflow(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject; Self: Codeunit "NPR POS JavaScript Interface")
    var
        POSAction: Record "NPR POS Action";
        JSON: Codeunit "NPR POS JSON Management";
        ParametersToken: JsonToken;
        Parameters: JsonObject;
        Signal: Codeunit "NPR Front-End: WkfCallCompl.";
        ActionName: Text;
        WorkflowId: Integer;
        Handled: Boolean;
        Success: Boolean;
    begin
        Stopwatch.ResetAll();

        ApplyDataState(Context, POSSession, FrontEnd);

        JSON.InitializeJObjectParser(Context, FrontEnd);
        ActionName := JSON.GetStringOrFail('action', ReadingActionNameErr);
        WorkflowId := JSON.GetIntegerOrFail('workflowId', ReadingWorkflowIdErr);
        ParametersToken := JSON.GetJTokenOrFail('parameters', StrSubstNo(ReadingParametersFailedErr, ActionName));
        Parameters := ParametersToken.AsObject();

        POSSession.RetrieveSessionAction(ActionName, POSAction);
        FrontEnd.WorkflowBackEndStepBegin(WorkflowId, 0);
        Stopwatch.Start('Before');

        Success := InvokeOnBeforeWorkflowThroughOnRun(POSAction, Parameters, POSSession, FrontEnd, Self, Handled);

        Stopwatch.Stop('Before');
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
        Signal.GetContent().Add('durationBefore', Stopwatch.ElapsedMilliseconds('Before'));

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

        POSSession.GetStargate(Stargate);
        if Success then
            Stargate.DeviceResponse(Method, Response, POSSession, FrontEnd, ActionName, Step)
        else
            Stargate.DeviceError(Method, Response, POSSession, FrontEnd);
    end;

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
        POSSession.GetStargate(Stargate);
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

    [IntegrationEvent(false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
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
    local procedure OnCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; Sender: Text; EventName: Text; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProtocolUITimer(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; ModelID: Guid; var Handled: Boolean)
    begin
    end;
}

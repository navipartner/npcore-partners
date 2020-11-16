codeunit 6150701 "NPR POS JavaScript Interface"
{
    var
        Text001: Label 'Action %1 does not seem to have a registered handler, or the registered handler failed to notify the framework about successful processing of the action.';
        Text002: Label 'An unknown method was invoked by the front end (JavaScript).\\Method: %1\Context: %2';
        Text003: Label 'No handler has responded to the RequestContext stage for action %1, or the registered handler failed to notify the framework about successful processing of the request.';
        Text004: Label 'No data driver responded to %1 event for %2 data source.';
        LastView: DotNet NPRNetView0;
        Text005: Label 'One or more action codeunits have responded to %1 event during back-end workflow engine initialization. This is a critical condition, therefore your session cannot continue. You should immediately contact support.';
        Stopwatches: DotNet NPRNetDictionary_Of_T_U;
        Text006: Label 'No protocol codeunit responded to %1 method, sender ''%2'', event ''%3''. Protocol user interface %4 will now be aborted.';
        Text007: Label 'No protocol codeunit responded to Timer request. Protocol user interface %1 will now be aborted.';
        TextErrorMustNotRunThisCodeunit: Label 'You must not run this codeunit directly. This codeunit is intended to be run only from within itself.', Locked = true; // This is development type of error, do not translate!

        OnRunType: Option InvokeAction,BeforeWorkflow;
        OnRunInitialized: Boolean;
        OnRunPOSAction: Record "NPR POS Action";
        OnRunWorkflowStep: Text;
        OnRunContext: JsonObject;
        OnRunParameters: JsonObject;
        OnRunPOSSession: Codeunit "NPR POS Session";
        OnRunFrontEnd: Codeunit "NPR POS Front End Management";
        OnRunHandled: Boolean;

    trigger OnRun()
    begin
        if not OnRunInitialized then
            Error(TextErrorMustNotRunThisCodeunit);

        case OnRunType of
            OnRunType::InvokeAction:
                OnAction(OnRunPOSAction, OnRunWorkflowStep, OnRunContext, OnRunPOSSession, OnRunFrontEnd, OnRunHandled);
            OnRunType::BeforeWorkflow:
                OnBeforeWorkflow(OnRunPOSAction, OnRunParameters, OnRunPOSSession, OnRunFrontEnd, OnRunHandled);
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

    // The purpose of this function is to detect if there are action codeunits that respond to either OnBeforeWorkflow or OnAction not intended for them.
    procedure Initialize(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAction: Record "NPR POS Action";
        Parameters: JsonObject;
        Handled: Boolean;
    begin
        OnBeforeWorkflow(POSAction, Parameters, POSSession, FrontEnd, Handled);
        if Handled then
            FrontEnd.ReportBug(StrSubstNo(Text005, 'OnBeforeWorkflow'));

        Handled := false;
        OnAction(POSAction, '', Parameters, POSSession, FrontEnd, Handled);
        if Handled then
            FrontEnd.ReportBug(StrSubstNo(Text005, 'OnAction'));
    end;

    procedure InvokeAction("Action": Text; WorkflowStep: Text; WorkflowId: Integer; ActionId: Integer; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS JavaScript Interface")
    var
        POSAction: Record "NPR POS Action";
        Signal: DotNet NPRNetWorkflowCallCompletedRequest;
        Handled: Boolean;
        Success: Boolean;
    begin
        StopwatchResetAll();

        POSSession.RetrieveSessionAction(Action, POSAction);

        StopwatchStart('All');
        ApplyDataState(Context, POSSession, FrontEnd);

        OnBeforeInvokeAction(POSAction, WorkflowStep, Context, POSSession, FrontEnd);

        POSSession.SetInAction(true);
        FrontEnd.WorkflowBackEndStepBegin(WorkflowId, ActionId);
        StopwatchStart('Action');

        Success := InvokeOnActionThroughOnRun(POSAction, WorkflowStep, Context, POSSession, FrontEnd, Self, Handled);

        StopwatchStop('Action');
        FrontEnd.WorkflowBackEndStepEnd();
        POSSession.SetInAction(false);

        if not Handled and Success then
            FrontEnd.ReportBug(StrSubstNo(Text001, Action));

        if Success then begin
            OnAfterInvokeAction(POSAction, WorkflowStep, Context, POSSession, FrontEnd);
            StopwatchStart('Data');
            RefreshData(POSSession, FrontEnd);
            StopwatchStop('Data');
            Signal := Signal.SignalSuccess(WorkflowId, ActionId);
        end else begin
            Signal := Signal.SignalFailreAndThrowError(WorkflowId, ActionId, GetLastErrorText);
            FrontEnd.Trace(Signal, 'ErrorCallStack', GetLastErrorCallstack);
        end;

        StopwatchStop('All');
        FrontEnd.Trace(Signal, 'durationAll', StopwatchGetDuration('All'));
        FrontEnd.Trace(Signal, 'durationAction', StopwatchGetDuration('Action'));
        FrontEnd.Trace(Signal, 'durationData', StopwatchGetDuration('Data'));
        FrontEnd.Trace(Signal, 'durationOverhead', StopwatchGetDuration('All') - StopwatchGetDuration('Action') - StopwatchGetDuration('Data'));

        FrontEnd.WorkflowCallCompleted(Signal);
    end;

    procedure InvokeMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS JavaScript Interface")
    begin
        OnBeforeInvokeMethod(Method, Context, POSSession, FrontEnd);

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
                Method_FrontEndId(POSSession, FrontEnd, Context);
            'Unlock':
                Method_Unlock(POSSession, FrontEnd, Context, Self);
            'MajorTomEvent':
                Method_MajorTomEvent(POSSession, FrontEnd, Context);
            'ProtocolUIResponse':
                Method_ProtocolUIResponse(POSSession, FrontEnd, Context);
            else begin
                    InvokeCustomMethod(Method, Context, POSSession, FrontEnd);
                end;
        end;

        OnAfterInvokeMethod(Method, Context, POSSession, FrontEnd);
    end;

    local procedure InvokeCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Handled: Boolean;
        ContextString: Text;
    begin
        OnCustomMethod(Method, Context, POSSession, FrontEnd, Handled);
        if not Handled then begin
            Context.WriteTo(ContextString);
            FrontEnd.ReportInvalidCustomMethod(StrSubstNo(Text002, Method, ContextString), Method);
        end;
    end;

    procedure RefreshData(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DataMgt: Codeunit "NPR POS Data Management";
        DataSets: DotNet NPRNetList_Of_T;
        DataSetList: DotNet NPRNetDataSet;
        DataSource: DotNet NPRNetDataSource0;
        DataStore: DotNet NPRNetDataStore;
        View: DotNet NPRNetView0;
        RefreshSource: Boolean;
    begin
        if not POSSession.IsDataRefreshNeeded() then
            exit;

        DataSets := DataSets.List();
        POSSession.GetCurrentView(View);
        POSSession.GetDataStore(DataStore);
        foreach DataSource in View.GetDataSources() do begin
            RefreshSource := false;
            if View.Equals(LastView) and DataSource.PerSession then
                DataMgt.OnIsDataSourceModified(POSSession, DataSource.Id, RefreshSource)
            else
                RefreshSource := true;

            if RefreshSource then begin
                RefreshDataSet(POSSession, DataSource, DataSetList, FrontEnd);
                DataSetList := DataStore.StoreAndGetDelta(DataSetList);
                DataSets.Add(DataSetList);
                DataSource.RetrievedInCurrentSession := true;
            end;
        end;

        FrontEnd.RefreshData(DataSets);

        LastView := View;
    end;

    local procedure RefreshDataSet(POSSession: Codeunit "NPR POS Session"; DataSource: DotNet NPRNetDataSource0; var DataSetList: DotNet NPRNetDataSet; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        DataMgt: Codeunit "NPR POS Data Management";
        Handled: Boolean;
    begin
        DataMgt.OnRefreshDataSet(POSSession, DataSource, DataSetList, FrontEnd, Handled);
        if not Handled then
            FrontEnd.ReportBug(StrSubstNo(Text004, 'OnRefreshDataSet', DataSource.Id));
        DataMgt.OnAfterRefreshDataSet(POSSession, DataSource, DataSetList, FrontEnd);
    end;

    procedure ApplyDataState(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        JObject: JsonObject;
        JValue: JsonValue;
        JToken: JsonToken;
        DataStore: DotNet NPRNetDataStore;
        DataSetList: DotNet NPRNetDataSet;
        Position: Text;
        JsonKey: Text;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        if not JSON.SetScope('data', false) then
            exit;
        if not JSON.SetScope('positions', false) then
            exit;

        JSON.GetJObject(JObject);
        foreach JsonKey in JObject.Keys do begin
            if (JObject.Get(JsonKey, JToken)) then begin
                JValue := JToken.AsValue();
                if (not JValue.IsNull()) and (not JValue.IsUndefined()) then begin
                    Position := JValue.AsText();
                    POSSession.GetDataStore(DataStore);
                    DataSetList := DataStore.GetDataSet(JsonKey);
                    if DataSetList.CurrentPosition <> Position then begin
                        DataSetList.CurrentPosition := Position;
                        SetPosition(POSSession, DataSetList, Position, FrontEnd);
                    end;
                end;
            end;
        end;
    end;

    local procedure SetPosition(POSSession: Codeunit "NPR POS Session"; DataSetList: DotNet NPRNetDataSet; Position: Text; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        Data: Codeunit "NPR POS Data Management";
        Handled: Boolean;
    begin
        Data.OnSetPosition(DataSetList.DataSource, Position, POSSession, Handled);
        if not Handled then
            FrontEnd.ReportBug(StrSubstNo(Text004, 'OnSetPosition', DataSetList.DataSource));
    end;

    local procedure Method_AbortWorkflow(FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        WorkflowID: Integer;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        WorkflowID := JSON.GetInteger('id', true);
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
        Signal: DotNet NPRNetWorkflowCallCompletedRequest;
        "Action": Text;
        WorkflowId: Integer;
        Handled: Boolean;
        Success: Boolean;
    begin
        StopwatchResetAll();

        ApplyDataState(Context, POSSession, FrontEnd);

        JSON.InitializeJObjectParser(Context, FrontEnd);
        Action := JSON.GetString('action', true);
        WorkflowId := JSON.GetInteger('workflowId', true);
        JSON.GetJToken(ParametersToken, 'parameters', true);
        Parameters := ParametersToken.AsObject();

        POSSession.RetrieveSessionAction(Action, POSAction);
        FrontEnd.WorkflowBackEndStepBegin(WorkflowId, 0);
        StopwatchStart('Before');

        Success := InvokeOnBeforeWorkflowThroughOnRun(POSAction, Parameters, POSSession, FrontEnd, Self, Handled);

        StopwatchStop('Before');
        FrontEnd.WorkflowBackEndStepEnd();

        if (not Success) or (not Handled) then begin
            if Success then begin
                FrontEnd.WorkflowCallCompleted(Signal.SignalFailure(WorkflowId, 0));
                FrontEnd.ReportBug(StrSubstNo(Text003, Action));
            end else
                FrontEnd.WorkflowCallCompleted(Signal.SignalFailreAndThrowError(WorkflowId, 0, GetLastErrorText));
            exit;
        end;

        Signal := Signal.SignalSuccess(WorkflowId, 0);
        Signal.Content.Add('durationBefore', StopwatchGetDuration('Before'));

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
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        Method := JSON.GetString('id', true);
        Success := JSON.GetBoolean('success', true);
        Response := JSON.GetString('response', true);
        ActionName := JSON.GetString('action', true);
        Step := JSON.GetString('step', true);

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
    begin
        POSSession.GetStargate(Stargate);
        JSON.InitializeJObjectParser(Context, FrontEnd);

        SerializedArguments := JSON.GetString('arguments', true);
        ActionName := JSON.GetString('action', true);
        Step := JSON.GetString('step', true);

        if JSON.GetBoolean('closeProtocol', false) then begin
            Forced := JSON.GetBoolean('forced', true);
            Stargate.AppGatewayProtocolClosed(ActionName, Step, SerializedArguments, Forced, FrontEnd);
            exit;
        end;

        EventName := JSON.GetString('event', true);
        Callback := JSON.GetBoolean('callback', true);
        Stargate.AppGatewayProtocol(ActionName, Step, EventName, SerializedArguments, Callback, FrontEnd);
    end;

    local procedure Method_FrontEndId(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        HardwareId: Text;
        SessionName: Text;
        HostName: Text;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        HardwareId := JSON.GetString('hardware', true);
        SessionName := JSON.GetString('session', false);
        HostName := JSON.GetString('host', false);
        POSSession.InitializeSessionId(HardwareId, SessionName, HostName);
        FrontEnd.HardwareInitializationComplete();
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

    local procedure Method_MajorTomEvent(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Source: Text;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        Source := JSON.GetString('source', true);
        // TODO: handle the event here, source can be:
        // 'exitingMajorTom': Major Tom is closing, and it will close. The user was asked whether they want to close, and they confirmed, so this is the last thing that will happen in this Major Tom session.
        // 'newSale':         New Sale button was clicked in Major Tom
        // 'navRoleCenter':   RoleCenter button was clicked in Major Tom
        // 'navigatingAway':  Navigating away from the sale view into a generic browser URL (such as http://navipartner.dk/)
    end;

    local procedure Method_KeyPress(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: JsonObject)
    var
        JSON: Codeunit "NPR POS JSON Management";
        KeyPressed: Text;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        KeyPressed := JSON.GetString('key', true);

        POSSession.ProcessKeyPress(KeyPressed);
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
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);
        Evaluate(ModelID, JSON.GetString('modelId', true));
        Sender := JSON.GetString('sender', true);
        EventName := JSON.GetString('event', true);

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
            FrontEnd.ReportBug(ErrorMessage);
        end;
    end;

    local procedure StopwatchResetAll()
    begin
        Stopwatches := Stopwatches.Dictionary();
    end;

    local procedure StopwatchStart(Id: Text)
    var
        Stopwatch: DotNet NPRNetStopwatch;
    begin
        if IsNull(Stopwatches) then
            Stopwatches := Stopwatches.Dictionary();

        if not Stopwatches.ContainsKey(Id) then begin
            Stopwatch := Stopwatch.Stopwatch();
            Stopwatches.Add(Id, Stopwatch);
        end else
            Stopwatch := Stopwatches.Item(Id);

        Stopwatch.Start();
    end;

    local procedure StopwatchStop(Id: Text): Integer
    var
        Stopwatch: DotNet NPRNetStopwatch;
    begin
        Stopwatch := Stopwatches.Item(Id);
        Stopwatch.Stop();
        exit(Stopwatch.ElapsedMilliseconds);
    end;

    local procedure StopwatchGetDuration(Id: Text): Integer
    var
        Stopwatch: DotNet NPRNetStopwatch;
    begin
        if Stopwatches.ContainsKey(Id) then begin
            Stopwatch := Stopwatches.Item(Id);
            exit(Stopwatch.ElapsedMilliseconds);
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

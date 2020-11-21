codeunit 6150733 "NPR POS Workflows 2.0"
{
    var
        Text001: Label 'Action %1 does not seem to have a registered handler, or the registered handler failed to notify the framework about successful processing of the action.';
        Stopwatch: Codeunit "NPR Stopwatch";
        TextErrorMustNotRunThisCodeunit: Label 'You must not run this codeunit directly. This codeunit is intended to be run only from within itself.', Locked = true; // This is development type of error, do not translate!
        OnRunInitialized: Boolean;
        OnRunPOSAction: Record "NPR POS Action";
        OnRunWorkflowStep: Text;
        OnRunContext: Codeunit "NPR POS JSON Management";
        OnRunWorkflows20State: Codeunit "NPR POS WF 2.0: State";
        OnRunPOSSession: Codeunit "NPR POS Session";
        OnRunFrontEnd: Codeunit "NPR POS Front End Management";
        OnRunHandled: Boolean;

    trigger OnRun()
    begin
        if not OnRunInitialized then
            Error(TextErrorMustNotRunThisCodeunit);
        OnAction(OnRunPOSAction, OnRunWorkflowStep, OnRunContext, OnRunPOSSession, OnRunWorkflows20State, OnRunFrontEnd, OnRunHandled);
        if not OnRunHandled then
            Error(Text001, OnRunPOSAction);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', false, false)]
    local procedure OnAction20(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        ActionCode: Text;
        WorkflowId: Integer;
        Workflowstep: Text;
        ActionId: Integer;
        ActionContext: JsonObject;
        POSWorkflows20: Codeunit "NPR POS Workflows 2.0";
    begin
        if Method <> 'OnAction20' then
            exit;

        Handled := true;

        RetrieveActionContext(Context, ActionCode, WorkflowId, Workflowstep, ActionId, ActionContext);
        POSWorkflows20.InvokeAction20(ActionCode, WorkflowId, Workflowstep, ActionId, ActionContext, POSSession, FrontEnd, POSWorkflows20);
    end;

    local procedure RetrieveActionContext(Context: JsonObject; var ActionCode: Text; var WorkflowId: Integer; var WorkflowStep: Text; var ActionId: Integer; var ActionContext: JsonObject)
    var
        JToken: JsonToken;
        JValue: JsonValue;
    begin
        Context.Get('name', JToken);
        JValue := JToken.AsValue();
        ActionCode := JValue.AsText();

        Context.Get('step', JToken);
        JValue := JToken.AsValue();
        WorkflowStep := JValue.AsText();

        Context.Get('id', JToken);
        JValue := JToken.AsValue();
        WorkflowId := JValue.AsInteger();

        Context.Get('actionId', JToken);
        JValue := JToken.AsValue();
        ActionId := JValue.AsInteger();

        Context.Get('context', JToken);
        ActionContext := JToken.AsObject();
    end;

    local procedure InvokeOnActionThroughOnRun(POSActionIn: Record "NPR POS Action"; WorkflowStepIn: Text; ContextIn: Codeunit "NPR POS JSON Management"; POSSessionIn: Codeunit "NPR POS Session"; FrontEndIn: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS Workflows 2.0"; var Handled: Boolean) Success: Boolean
    begin
        OnRunHandled := false;
        OnRunInitialized := true;
        OnRunPOSAction := POSActionIn;
        OnRunWorkflowStep := WorkflowStepIn;
        OnRunContext := ContextIn;
        OnRunPOSSession := POSSessionIn;
        OnRunFrontEnd := FrontEndIn;

        Success := Self.Run();
        Handled := OnRunHandled;

        OnRunInitialized := false;
    end;

    procedure InvokeAction20("Action": Text; WorkflowId: Integer; WorkflowStep: Text; ActionId: Integer; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS Workflows 2.0")
    var
        POSAction: Record "NPR POS Action";
        JavaScriptInterface: Codeunit "NPR POS JavaScript Interface";
        JSON: Codeunit "NPR POS JSON Management";
        State: Codeunit "NPR POS WF 2.0: State";
        FrontEnd20: Codeunit "NPR POS Front End Management";
        Signal: Codeunit "NPR Front-End: WkfCallCompl.";
        Success: Boolean;
        Handled: Boolean;
    begin
        Stopwatch.ResetAll();

        POSSession.RetrieveSessionAction(Action, POSAction);
        FrontEnd.CloneForWorkflow20(WorkflowId, FrontEnd20);

        Stopwatch.Start('All');
        JavaScriptInterface.ApplyDataState(Context, POSSession, FrontEnd20);
        JSON.InitializeJObjectParser(Context, FrontEnd20);
        POSSession.GetWorkflow20State(WorkflowId, Action, State);

        OnBeforeInvokeAction(POSAction, WorkflowStep, Context, POSSession, FrontEnd20);

        POSSession.SetInAction(true);
        Stopwatch.Start('Action');

        Success := InvokeOnActionThroughOnRun(POSAction, WorkflowStep, JSON, POSSession, FrontEnd20, Self, Handled);

        Stopwatch.Stop('Action');
        POSSession.SetInAction(false);

        if not Handled then
            FrontEnd20.ReportBug(StrSubstNo(Text001, Action));

        if Success then begin
            OnAfterInvokeAction(POSAction, WorkflowStep, Context, POSSession, FrontEnd20);
            Stopwatch.Start('Data');
            JavaScriptInterface.RefreshData(POSSession, FrontEnd20);
            Stopwatch.Stop('Data');
            Signal.SignalSuccess(WorkflowId, ActionId);
        end else begin
            Signal.SignalFailureAndThrowError(WorkflowId, ActionId, GetLastErrorText);
            FrontEnd20.Trace(Signal, 'ErrorCallStack', GetLastErrorCallstack);
        end;

        Stopwatch.Stop('All');
        FrontEnd20.Trace(Signal, 'durationAll', Stopwatch.ElapsedMilliseconds('All'));
        FrontEnd20.Trace(Signal, 'durationAction', Stopwatch.ElapsedMilliseconds('Action'));
        FrontEnd20.Trace(Signal, 'durationData', Stopwatch.ElapsedMilliseconds('Data'));
        FrontEnd20.Trace(Signal, 'durationOverhead', Stopwatch.ElapsedMilliseconds('All') - Stopwatch.ElapsedMilliseconds('Action') - Stopwatch.ElapsedMilliseconds('Data'));

        Signal.SetEngine20(JSON.GetContextObject());

        FrontEnd20.WorkflowCallCompleted(Signal);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
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
}

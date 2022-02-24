codeunit 6014665 "NPR POS Workflow 3.0"
{
    Access = Internal;

    var
        _Stopwatch: Codeunit "NPR Stopwatch";
        _OnRunActionCode: Text;
        _OnRunWorkflowStep: Text;
        _OnRunContext: Codeunit "NPR POS JSON Helper";
        _OnRunFrontEnd: Codeunit "NPR POS Front End Management";

    trigger OnRun()
    var
        Workflow: Interface "NPR IPOS Workflow";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSetup: Codeunit "NPR POS Setup";
        POSSession: Codeunit "NPR POS Session";

    begin
        //todo run interface impl.
        Workflow := Enum::"NPR POS Workflow".FromInteger(Enum::"NPR POS Workflow".Ordinals().Get(Enum::"NPR POS Workflow".Names().IndexOf(_OnRunActionCode)));
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetPaymentLine(POSPaymentLine);
        POSSession.GetSetup(POSSetup);
        Workflow.RunWorkflow(_OnRunWorkflowStep, _OnRunContext, _OnRunFrontEnd, POSSale, POSSaleLine, POSPaymentLine, POSSetup);
    end;

    procedure RunIfAction30(Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"): Boolean
    var
        ActionCode: Text;
        WorkflowId: Integer;
        Workflowstep: Text;
        ActionId: Integer;
        ActionContext: JsonObject;
        POSWorkflows30: Codeunit "NPR POS Workflow 3.0";
    begin
        RetrieveActionContext(Context, ActionCode, WorkflowId, Workflowstep, ActionId, ActionContext);
        if not Enum::"NPR POS Workflow".Names().Contains(ActionCode) then
            exit(false);

        POSWorkflows30.InvokeAction30(ActionCode, WorkflowId, Workflowstep, ActionId, ActionContext, FrontEnd, POSWorkflows30);
        exit(true);
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

    local procedure InvokeOnActionThroughOnRun(ActionCode: Text; WorkflowStepIn: Text; ContextIn: Codeunit "NPR POS JSON Helper"; FrontEndIn: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS Workflow 3.0") Success: Boolean
    begin
        _OnRunActionCode := ActionCode;
        _OnRunWorkflowStep := WorkflowStepIn;
        _OnRunContext := ContextIn;
        _OnRunFrontEnd := FrontEndIn;

        Success := Self.Run();
    end;

    internal procedure InvokeAction30(ActionCode: Text; WorkflowId: Integer; WorkflowStep: Text; ActionId: Integer; Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR POS Workflow 3.0")
    var
        JavaScriptInterface: Codeunit "NPR POS JavaScript Interface";
        JSON: Codeunit "NPR POS JSON Helper";
        Signal: Codeunit "NPR Front-End: WkfCallCompl.";
        Success: Boolean;
        POSSession: Codeunit "NPR POS Session";
    begin
        _Stopwatch.ResetAll();

        FrontEnd.SetWorkflowID(WorkflowId);

        _Stopwatch.Start('All');
        JavaScriptInterface.ApplyDataState(Context, POSSession, FrontEnd);
        JSON.InitializeJObjectParser(Context);

        _Stopwatch.Start('Action');

        Success := InvokeOnActionThroughOnRun(ActionCode, WorkflowStep, JSON, FrontEnd, Self);

        _Stopwatch.Stop('Action');

        if Success then begin
            _Stopwatch.Start('Data');
            JavaScriptInterface.RefreshData(FrontEnd);
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

        Signal.SetEngine20(JSON.GetContextObject());

        FrontEnd.WorkflowCallCompleted(Signal);
        FrontEnd.ClearWorkflowID();
    end;
}

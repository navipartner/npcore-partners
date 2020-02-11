codeunit 6150733 "POS Workflows 2.0"
{
    // NPR5.50/JAKUBV/20190603  CASE 338666 Transport NPR5.50 - 3 June 2019
    // NPR5.51/MMV /20190731  CASE 363458 Added log of callstack when errors happen.
    // NPR5.53/VB  /20190917  CASE 362777 Support for workflow sequencing (configuring/registering "before" and "after" workflow sequences that execute before or after another workflow)


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Action %1 does not seem to have a registered handler, or the registered handler failed to notify the framework about successful processing of the action.';
        Stopwatches: DotNet npNetDictionary_Of_T_U;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnCustomMethod', '', false, false)]
    local procedure OnAction20(Method: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        ActionCode: Text;
        WorkflowId: Integer;
        Workflowstep: Text;
        ActionId: Integer;
        ActionContext: DotNet npNetJObject;
    begin
        if Method <> 'OnAction20' then
          exit;

        Handled := true;

        RetrieveActionContext(Context,ActionCode,WorkflowId,Workflowstep,ActionId,ActionContext);
        InvokeAction20(ActionCode,WorkflowId,Workflowstep,ActionId,ActionContext,POSSession,FrontEnd);
    end;

    local procedure RetrieveActionContext(Context: DotNet npNetJObject;var ActionCode: Text;var WorkflowId: Integer;var WorkflowStep: Text;var ActionId: Integer;var ActionContext: DotNet npNetJObject)
    var
        ContextArray: DotNet npNetJArray;
        JToken: DotNet npNetJToken;
    begin
        ContextArray := Context;

        JToken := ContextArray.Item(0);
        ActionCode := JToken.ToString();

        JToken := ContextArray.Item(1);
        WorkflowStep := JToken.ToString();

        JToken := ContextArray.Item(2);
        WorkflowId := JToken.ToObject(GetDotNetType(WorkflowId));

        JToken := ContextArray.Item(3);
        ActionId := JToken.ToObject(GetDotNetType(WorkflowId));

        JToken := ContextArray.Item(4);
        ActionContext := JToken;
    end;

    local procedure InvokeAction20("Action": Text;WorkflowId: Integer;WorkflowStep: Text;ActionId: Integer;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        POSAction: Record "POS Action";
        JavaScriptInterface: Codeunit "POS JavaScript Interface";
        JSON: Codeunit "POS JSON Management";
        State: Codeunit "POS Workflows 2.0 - State";
        FrontEnd20: Codeunit "POS Front End Management";
        Signal: DotNet npNetWorkflowCallCompletedRequest;
        ActionContext: DotNet npNetDictionary_Of_T_U;
        Handled: Boolean;
        Executing: Boolean;
    begin
        StopwatchResetAll();

        POSSession.RetrieveSessionAction(Action,POSAction);
        FrontEnd.CloneForWorkflow20(WorkflowId,FrontEnd20);

        StopwatchStart('All');
        JavaScriptInterface.ApplyDataState(Context,POSSession,FrontEnd20);
        JSON.InitializeJObjectParser(Context,FrontEnd20);
        POSSession.GetWorkflow20State(WorkflowId,Action,State);

        OnBeforeInvokeAction(POSAction,WorkflowStep,Context,POSSession,FrontEnd20);

        POSSession.SetInAction(true);
        StopwatchStart('Action');
        asserterror begin
          Executing := true;
          OnAction(POSAction,WorkflowStep,JSON,POSSession,State,FrontEnd20,Handled);
        //-NPR5.53 [362777]
          if Handled then begin
        //+NPR5.53 [362777]
            Executing := false;
            Commit;
            Error('');
        //-NPR5.53 [362777]
          end else
            Error(Text001,Action);
        //+NPR5.53 [362777]
        end;
        StopwatchStop('Action');
        POSSession.SetInAction(false);

        if not Handled and not Executing then
          FrontEnd20.ReportBug(StrSubstNo(Text001,Action));

        if not Executing then begin
          OnAfterInvokeAction(POSAction,WorkflowStep,Context,POSSession,FrontEnd20);
          StopwatchStart('Data');
          JavaScriptInterface.RefreshData(POSSession,FrontEnd20);
          StopwatchStop('Data');
          Signal := Signal.SignalSuccess(WorkflowId,ActionId);
        end else begin
          Signal := Signal.SignalFailreAndThrowError(WorkflowId,ActionId,GetLastErrorText);
        //-NPR5.51 [363458]
          FrontEnd20.Trace(Signal, 'ErrorCallStack', GetLastErrorCallstack);
        //+NPR5.51 [363458]
        end;

        StopwatchStop('All');
        FrontEnd20.Trace(Signal,'durationAll',StopwatchGetDuration('All'));
        FrontEnd20.Trace(Signal,'durationAction',StopwatchGetDuration('Action'));
        FrontEnd20.Trace(Signal,'durationData',StopwatchGetDuration('Data'));
        FrontEnd20.Trace(Signal,'durationOverhead',StopwatchGetDuration('All') - StopwatchGetDuration('Action') - StopwatchGetDuration('Data'));

        JSON.GetContextObject(ActionContext);

        Signal.Content.Add('workflowEngine','2.0');
        Signal.Content.Add('context',ActionContext);

        FrontEnd20.WorkflowCallCompleted(Signal);
    end;

    local procedure StopwatchResetAll()
    begin
        Stopwatches := Stopwatches.Dictionary();
    end;

    local procedure StopwatchStart(Id: Text)
    var
        Stopwatch: DotNet npNetStopwatch;
    begin
        if IsNull(Stopwatches) then
          Stopwatches := Stopwatches.Dictionary();

        if not Stopwatches.ContainsKey(Id) then begin
          Stopwatch := Stopwatch.Stopwatch();
          Stopwatches.Add(Id,Stopwatch);
        end else
          Stopwatch := Stopwatches.Item(Id);

        Stopwatch.Start();
    end;

    local procedure StopwatchStop(Id: Text): Integer
    var
        Stopwatch: DotNet npNetStopwatch;
    begin
        Stopwatch := Stopwatches.Item(Id);
        Stopwatch.Stop();
        exit(Stopwatch.ElapsedMilliseconds);
    end;

    local procedure StopwatchGetDuration(Id: Text): Integer
    var
        Stopwatch: DotNet npNetStopwatch;
    begin
        if Stopwatches.ContainsKey(Id) then begin
          Stopwatch := Stopwatches.Item(Id);
          exit(Stopwatch.ElapsedMilliseconds);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";State: Codeunit "POS Workflows 2.0 - State";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInvokeAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInvokeAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;
}


codeunit 6150701 "POS JavaScript Interface"
{
    // Some hints about this codeunit:
    // - This codeunit serves as an interface between JavaScript and C/AL.
    // - Anything that comes from JavaScript first ends up in this codeunit, which then does necessary pre- and post- processing.
    // - This codeunit contains specific logic for "methods" invoked by JavaScript.
    // - There are two kinds of features that can be invoked from JavaScript:
    //   - Methods: "known" functions of the back end, that perform some "hardcoded" logic that typically belongs to architectural
    //              and infrastructure things, rather than business logic. Methods can be custom, meaning that when an unknown method
    //              is invoked, this codeunit invokes the OnCustomMethod event allowing simple extension of custom functionality.
    //   - Actions: business logic. Actions are invoked as a part of workflows executing on the front end. Actions fire the OnAction
    //              event and invoke subscribers which then provide necessary business logic.
    // 
    // NPR5.33/VB  /20170630  CASE 282239 Modified logic to properly handle abort request.
    // NPR5.37/VB  /20171024  CASE 293905 Added support for locked view and for Major Tom events
    // NPR5.38/VB  /20171120  CASE 295800 Implemented the keypress method to allow C/AL to respond to individual key presses in front end
    // NPR5.38/VB  /20171130  CASE 266990 Stargate "2.0" Protocol UI infrastructure implemented.
    // NPR5.40/VB  /20180213  CASE 306347 Performance improvement due to parameters in BLOB and physical-table action discovery
    // NPR5.40/BHR /20180322  CASE 308408 Rename variable dataset to datasetlist
    // NPR5.45/VB  /20180803  CASE 315838 Implemented tracing functionality.
    // NPR5.48/TJ  /20180806  CASE 323835 Using custom method function for key press
    // NPR5.48/MHA /20190213  CASE 341077 Added function OnActionV2() to support POS Actions from Nav .app
    // NPR5.50/VB  /20181205  CASE 338666 Supporting Workflows 2.0 (changed signature on ApplyDataState function)


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Action %1 does not seem to have a registered handler, or the registered handler failed to notify the framework about successful processing of the action.';
        Text002: Label 'An unknown method was invoked by the front end (JavaScript).\\Method: %1\Context: %2';
        Text003: Label 'No handler has responded to the RequestContext stage for action %1, or the registered handler failed to notify the framework about successful processing of the request.';
        Text004: Label 'No data driver responded to %1 event for %2 data source.';
        LastView: DotNet npNetView0;
        Text005: Label 'One or more action codeunits have responded to %1 event during back-end workflow engine initialization. This is a critical condition, therefore your session cannot continue. You should immediately contact support.';
        Stopwatches: DotNet npNetDictionary_Of_T_U;
        Text006: Label 'No protocol codeunit responded to %1 method, sender ''%2'', event ''%3''. Protocol user interface %4 will now be aborted.';
        Text007: Label 'No protocol codeunit responded to Timer request. Protocol user interface %1 will now be aborted.';

    procedure Initialize(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        POSAction: Record "POS Action";
        Parameters: DotNet npNetJObject;
        Handled: Boolean;
        ParametersString: Text;
    begin
        // The purpose of this function is to detect if there are action codeunits that respond to either OnBeforeWorkflow or OnAction not intended for them.

        OnBeforeWorkflow(POSAction,Parameters,POSSession,FrontEnd,Handled);
        if Handled then
          FrontEnd.ReportBug(StrSubstNo(Text005,'OnBeforeWorkflow'));

        Handled := false;
        OnAction(POSAction,'',Parameters,POSSession,FrontEnd,Handled);
        //-NPR5.48 [341077]
        if not Handled then begin
          if not IsNull(Parameters) then
            ParametersString := Parameters.ToString();
          OnActionV2(POSAction,'',ParametersString,POSSession,FrontEnd,Handled);
        end;
        //+NPR5.48 [341077]
        if Handled then
          FrontEnd.ReportBug(StrSubstNo(Text005,'OnAction'));
    end;

    procedure InvokeAction("Action": Text;WorkflowStep: Text;WorkflowId: Integer;ActionId: Integer;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        POSAction: Record "POS Action";
        Signal: DotNet npNetWorkflowCallCompletedRequest;
        Handled: Boolean;
        Executing: Boolean;
        ContextString: Text;
    begin
        StopwatchResetAll();

        //-NPR5.40 [306347]
        //POSAction.Code := Action;
        POSSession.RetrieveSessionAction(Action,POSAction);
        //+NPR5.40 [306347]

        StopwatchStart('All');
        ApplyDataState(Context,POSSession,FrontEnd);

        OnBeforeInvokeAction(POSAction,WorkflowStep,Context,POSSession,FrontEnd);

        POSSession.SetInAction(true);
        FrontEnd.WorkflowBackEndStepBegin(WorkflowId,ActionId);
        StopwatchStart('Action');
        asserterror begin
          Executing := true;
          OnAction(POSAction,WorkflowStep,Context,POSSession,FrontEnd,Handled);
          //-NPR5.48 [341077]
          if not Handled then begin
            if not IsNull(Context) then
              ContextString := Context.ToString();
            OnActionV2(POSAction,WorkflowStep,ContextString,POSSession,FrontEnd,Handled);
          end;
          //+NPR5.48 [341077]
          Executing := false;
          Commit;
          Error('');
        end;
        StopwatchStop('Action');
        FrontEnd.WorkflowBackEndStepEnd();
        POSSession.SetInAction(false);

        if not Handled and not Executing then
          FrontEnd.ReportBug(StrSubstNo(Text001,Action));

        if not Executing then begin
          OnAfterInvokeAction(POSAction,WorkflowStep,Context,POSSession,FrontEnd);
          StopwatchStart('Data');
          RefreshData(POSSession,FrontEnd);
          StopwatchStop('Data');
          Signal := Signal.SignalSuccess(WorkflowId,ActionId);
        end else
          Signal := Signal.SignalFailreAndThrowError(WorkflowId,ActionId,GetLastErrorText);

        StopwatchStop('All');
        //-NPR5.45 [315838]
        //Signal.Content.Add('durationAll',StopwatchGetDuration('All'));
        //Signal.Content.Add('durationAction',StopwatchGetDuration('Action'));
        //Signal.Content.Add('durationData',StopwatchGetDuration('Data'));
        //Signal.Content.Add('durationOverhead',StopwatchGetDuration('All') - StopwatchGetDuration('Action') - StopwatchGetDuration('Data'));
        FrontEnd.Trace(Signal,'durationAll',StopwatchGetDuration('All'));
        FrontEnd.Trace(Signal,'durationAction',StopwatchGetDuration('Action'));
        FrontEnd.Trace(Signal,'durationData',StopwatchGetDuration('Data'));
        FrontEnd.Trace(Signal,'durationOverhead',StopwatchGetDuration('All') - StopwatchGetDuration('Action') - StopwatchGetDuration('Data'));
        //+NPR5.45 [315838]

        FrontEnd.WorkflowCallCompleted(Signal);
    end;

    procedure InvokeMethod(Method: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
        // A method invoked from JavaScript logic that requests C/AL to execute specific non-business-logic processing (e.g. infrastructure, etc.)
        OnBeforeInvokeMethod(Method,Context,POSSession,FrontEnd);
        
        case Method of
          'AbortWorkflow': Method_AbortWorkflow(FrontEnd,Context);
          'AbortAllWorkflows': Method_AbortAllWorkflows(FrontEnd);
          'BeforeWorkflow': Method_BeforeWorkflow(POSSession,FrontEnd,Context);
          'Login': Method_Login(POSSession,FrontEnd,Context);
          'TextEnter': Method_TextEnter(POSSession,FrontEnd,Context);
          'InvokeDeviceResponse': Method_InvokeDeviceResponse(POSSession,FrontEnd,Context);
          'Protocol': Method_Protocol(POSSession,FrontEnd,Context);
          'FrontEndId': Method_FrontEndId(POSSession,FrontEnd,Context);
          //-NPR5.37 [293905]
          'Unlock': Method_Unlock(POSSession,FrontEnd,Context);
          'MajorTomEvent': Method_MajorTomEvent(POSSession,FrontEnd,Context);
          //+NPR5.37 [293905]
          //-NPR5.48 [323835]
          /*
          //-NPR5.38 [295800]
          'KeyPress': Method_KeyPress(POSSession,FrontEnd,Context);
          //+NPR5.38 [295800]
          */
          //+NPR5.48 [323835]
          //-NPR5.38 [266990]
          'ProtocolUIResponse': Method_ProtocolUIResponse(POSSession,FrontEnd,Context);
          //+NPR5.38 [266990]
          else begin
            InvokeCustomMethod(Method,Context,POSSession,FrontEnd);
          end;
        end;
        
        OnAfterInvokeMethod(Method,Context,POSSession,FrontEnd);

    end;

    local procedure InvokeCustomMethod(Method: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        Handled: Boolean;
    begin
        OnCustomMethod(Method,Context,POSSession,FrontEnd,Handled);
        if not Handled then
        //-NPR5.50 [338666]
        //  FrontEnd.ReportBug(STRSUBSTNO(Text002,Method,Context.ToString()));
          FrontEnd.ReportInvalidCustomMethod(StrSubstNo(Text002,Method,Context.ToString()),Method);
        //+NPR5.50 [338666]
    end;

    procedure RefreshData(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        DataMgt: Codeunit "POS Data Management";
        DataSets: DotNet npNetList_Of_T;
        DataSetList: DotNet npNetDataSet;
        DataSource: DotNet npNetDataSource0;
        DataStore: DotNet npNetDataStore;
        View: DotNet npNetView0;
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
            DataMgt.OnIsDataSourceModified(POSSession,DataSource.Id,RefreshSource)
          else
            RefreshSource := true;

          if RefreshSource then begin
            //-NPR5.40 [308408]
            //RefreshDataSet(POSSession,DataSource,DataSet,FrontEnd);
            //DataSet := DataStore.StoreAndGetDelta(DataSet);
            //DataSets.Add(DataSet);
            RefreshDataSet(POSSession,DataSource,DataSetList,FrontEnd);
            DataSetList := DataStore.StoreAndGetDelta(DataSetList);
            DataSets.Add(DataSetList);
            //-NPR5.40 [308408]
            DataSource.RetrievedInCurrentSession := true;
          end;
        end;

        FrontEnd.RefreshData(DataSets);

        LastView := View;
    end;

    local procedure RefreshDataSet(POSSession: Codeunit "POS Session";DataSource: DotNet npNetDataSource0;var DataSetList: DotNet npNetDataSet;FrontEnd: Codeunit "POS Front End Management")
    var
        DataMgt: Codeunit "POS Data Management";
        Handled: Boolean;
    begin
        //-NPR5.40 [308408]
        //DataMgt.OnRefreshDataSet(POSSession,DataSource,DataSet,FrontEnd,Handled)
        DataMgt.OnRefreshDataSet(POSSession,DataSource,DataSetList,FrontEnd,Handled);
        //+NPR5.40 [308408]
        if not Handled then
          FrontEnd.ReportBug(StrSubstNo(Text004,'OnRefreshDataSet',DataSource.Id));
        //-NPR5.40 [308408]
        //DataMgt.OnAfterRefreshDataSet(POSSession,DataSource,DataSet,FrontEnd);
        DataMgt.OnAfterRefreshDataSet(POSSession,DataSource,DataSetList,FrontEnd);
        //+NPR5.40 [308408]
    end;

    procedure ApplyDataState(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        JObject: DotNet npNetJObject;
        JValue: DotNet npNetJValue;
        Pair: DotNet npNetKeyValuePair_Of_T_U;
        DataStore: DotNet npNetDataStore;
        DataSetList: DotNet npNetDataSet;
        Position: Text;
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);
        if not JSON.SetScope('data',false) then
          exit;
        if not JSON.SetScope('positions',false) then
          exit;

        JSON.GetJObject(JObject);
        foreach Pair in JObject do begin
          JValue := Pair.Value;
          if not IsNull(JValue.Value) then begin
            Position := JValue.Value;
            POSSession.GetDataStore(DataStore);
        //-NPR5.40 [308408]
        //    DataSet := DataStore.GetDataSet(Pair.Key);
        //    IF DataSet.CurrentPosition <> Position THEN BEGIN
        //      DataSet.CurrentPosition := Position;
        //      SetPosition(POSSession,DataSet,Position,FrontEnd);
            DataSetList := DataStore.GetDataSet(Pair.Key);
            if DataSetList.CurrentPosition <> Position then begin
              DataSetList.CurrentPosition := Position;
              SetPosition(POSSession,DataSetList,Position,FrontEnd);
        //+NPR5.40 [308408]
            end;
          end;
        end;
    end;

    local procedure SetPosition(POSSession: Codeunit "POS Session";DataSetList: DotNet npNetDataSet;Position: Text;FrontEnd: Codeunit "POS Front End Management")
    var
        Data: Codeunit "POS Data Management";
        Handled: Boolean;
    begin
        //-NPR5.40 [308408]
        // Data.OnSetPosition(DataSet.DataSource,Position,POSSession,Handled);
        // IF NOT Handled THEN
        //  FrontEnd.ReportBug(STRSUBSTNO(Text004,'OnSetPosition',DataSet.DataSource));
        Data.OnSetPosition(DataSetList.DataSource,Position,POSSession,Handled);
        if not Handled then
          FrontEnd.ReportBug(StrSubstNo(Text004,'OnSetPosition',DataSetList.DataSource));
        //+NPR5.40 [308408]
    end;

    local procedure Method_AbortWorkflow(FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        WorkflowID: Integer;
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);
        WorkflowID := JSON.GetInteger('id',true);
        if WorkflowID > 0 then
          FrontEnd.AbortWorkflow(WorkflowID);
    end;

    local procedure Method_AbortAllWorkflows(FrontEnd: Codeunit "POS Front End Management")
    begin
        FrontEnd.AbortWorkflows();
    end;

    local procedure Method_BeforeWorkflow(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        POSAction: Record "POS Action";
        JSON: Codeunit "POS JSON Management";
        Parameters: DotNet npNetJObject;
        Signal: DotNet npNetWorkflowCallCompletedRequest;
        "Action": Text;
        WorkflowId: Integer;
        Handled: Boolean;
        Executing: Boolean;
    begin
        StopwatchResetAll();

        ApplyDataState(Context,POSSession,FrontEnd);

        JSON.InitializeJObjectParser(Context,FrontEnd);
        Action := JSON.GetString('action',true);
        WorkflowId := JSON.GetInteger('workflowId',true);
        JSON.GetJToken(Parameters,'parameters',true);

        //-NPR5.40 [306347]
        //POSAction.Code := Action;
        POSSession.RetrieveSessionAction(Action,POSAction);
        //+NPR5.40 [306347]
        FrontEnd.WorkflowBackEndStepBegin(WorkflowId,0);
        StopwatchStart('Before');
        asserterror begin
          Executing := true;
          OnBeforeWorkflow(POSAction,Parameters,POSSession,FrontEnd,Handled);
          Executing := false;
          Commit;
          Error('');
        end;
        StopwatchStop('Before');
        FrontEnd.WorkflowBackEndStepEnd();

        if Executing or not Handled then begin
          if not Executing then begin
            FrontEnd.WorkflowCallCompleted(Signal.SignalFailure(WorkflowId,0));
            FrontEnd.ReportBug(StrSubstNo(Text003,Action));
          end else
            FrontEnd.WorkflowCallCompleted(Signal.SignalFailreAndThrowError(WorkflowId,0,GetLastErrorText));
          exit;
        end;

        Signal := Signal.SignalSuccess(WorkflowId,0);
        Signal.Content.Add('durationBefore',StopwatchGetDuration('Before'));

        FrontEnd.WorkflowCallCompleted(Signal);
    end;

    local procedure Method_Login(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        "Action": Record "POS Action";
        Setup: Codeunit "POS Setup";
    begin
        //-NPR5.40 [306347]
        //Setup.Action_Login(Action);
        Setup.Action_Login(Action,POSSession);
        //-NPR5.40 [306347]
        InvokeAction(Action.Code,'',0,0,Context,POSSession,FrontEnd);
    end;

    local procedure Method_TextEnter(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        "Action": Record "POS Action";
        Setup: Codeunit "POS Setup";
    begin
        //-NPR5.40 [306347]
        //Setup.Action_TextEnter(Action);
        Setup.Action_TextEnter(Action,POSSession);
        //+NPR5.40 [306347]
        // TODO: extract workflow/action information from the front-end context or solve this some other way, but it cannot be 0,0 at this point
        InvokeAction(Action.Code,'',0,0,Context,POSSession,FrontEnd);
    end;

    local procedure Method_InvokeDeviceResponse(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        Stargate: Codeunit "POS Stargate Management";
        Method: Text;
        Response: Text;
        ActionName: Text;
        Step: Text;
        Success: Boolean;
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);
        Method := JSON.GetString('id',true);
        Success := JSON.GetBoolean('success',true);
        Response := JSON.GetString('response',true);
        ActionName := JSON.GetString('action',true);
        Step := JSON.GetString('step',true);

        POSSession.GetStargate(Stargate);
        if Success then
          Stargate.DeviceResponse(Method,Response,POSSession,FrontEnd,ActionName,Step)
        else
          Stargate.DeviceError(Method,Response,POSSession,FrontEnd);
    end;

    local procedure Method_Protocol(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        Stargate: Codeunit "POS Stargate Management";
        EventName: Text;
        SerializedArguments: Text;
        ActionName: Text;
        Step: Text;
        Callback: Boolean;
        Forced: Boolean;
    begin
        POSSession.GetStargate(Stargate);
        JSON.InitializeJObjectParser(Context,FrontEnd);

        SerializedArguments := JSON.GetString('arguments',true);
        ActionName := JSON.GetString('action',true);
        Step := JSON.GetString('step',true);

        if JSON.GetBoolean('closeProtocol',false) then begin
          Forced := JSON.GetBoolean('forced',true);
          Stargate.AppGatewayProtocolClosed(ActionName,Step,SerializedArguments,Forced,FrontEnd);
          exit;
        end;

        EventName := JSON.GetString('event',true);
        Callback := JSON.GetBoolean('callback',true);
        Stargate.AppGatewayProtocol(ActionName,Step,EventName,SerializedArguments,Callback,FrontEnd);
    end;

    local procedure Method_FrontEndId(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        HardwareId: Text;
        SessionName: Text;
        HostName: Text;
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);
        HardwareId := JSON.GetString('hardware',true);
        SessionName := JSON.GetString('session',false);
        HostName := JSON.GetString('host',false);
        POSSession.InitializeSessionId(HardwareId,SessionName,HostName);
        FrontEnd.HardwareInitializationComplete();
    end;

    local procedure Method_Unlock(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        "Action": Record "POS Action";
        Setup: Codeunit "POS Setup";
    begin
        //-NPR5.37 [293905]
        //-NPR5.40 [306347]
        //IF (Setup.Action_UnlockPOS(Action)) THEN
        if (Setup.Action_UnlockPOS(Action,POSSession)) then
        //+NPR5.40 [306347]
          InvokeAction(Action.Code,'',0,0,Context,POSSession,FrontEnd)
        else
          POSSession.ChangeViewSale();
        //+NPR5.37 [293905]
    end;

    local procedure Method_MajorTomEvent(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        Source: Text;
    begin
        //-NPR5.37 [293905]
        JSON.InitializeJObjectParser(Context,FrontEnd);
        Source := JSON.GetString('source',true);
        // TODO: handle the event here, source can be:
        // 'exitingMajorTom': Major Tom is closing, and it will close. The user was asked whether they want to close, and they confirmed, so this is the last thing that will happen in this Major Tom session.
        // 'newSale':         New Sale button was clicked in Major Tom
        // 'navRoleCenter':   RoleCenter button was clicked in Major Tom
        // 'navigatingAway':  Navigating away from the sale view into a generic browser URL (such as http://navipartner.dk/)
        //+NPR5.37 [293905]
    end;

    local procedure Method_KeyPress(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        KeyPressed: Text;
    begin
        //-NPR5.38 [295800]
        JSON.InitializeJObjectParser(Context,FrontEnd);
        KeyPressed := JSON.GetString('key',true);

        POSSession.ProcessKeyPress(KeyPressed);
        //+NPR5.38 [295800]
    end;

    local procedure Method_ProtocolUIResponse(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";Context: DotNet npNetJObject)
    var
        JSON: Codeunit "POS JSON Management";
        ModelID: Guid;
        Sender: Text;
        EventName: Text;
        ErrorMessage: Text;
        Handled: Boolean;
        IsTimer: Boolean;
    begin
        //-NPR5.38 [266990]
        JSON.InitializeJObjectParser(Context,FrontEnd);
        Evaluate(ModelID,JSON.GetString('modelId',true));
        Sender := JSON.GetString('sender',true);
        EventName := JSON.GetString('event',true);

        if (Sender = 'n$_timer') and (EventName = 'n$_timer') then begin
          IsTimer := true;
          OnProtocolUITimer(POSSession,FrontEnd,ModelID,Handled)
        end else
          OnProtocolUIResponse(POSSession,FrontEnd,ModelID,Sender,EventName,Handled);

        if not Handled then begin
          if IsTimer then
            ErrorMessage := StrSubstNo(Text007,ModelID)
          else
            ErrorMessage := StrSubstNo(Text006,'ProtocolUIResponse',Sender,EventName,ModelID);

          FrontEnd.CloseModel(ModelID);
          FrontEnd.ReportBug(ErrorMessage);
        end;
        //+NPR5.38 [266990]
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
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnActionV2("Action": Record "POS Action";WorkflowStep: Text;Context: Text;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        //-NPR5.48 [341077]
        //+NPR5.48 [341077]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInvokeAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInvokeAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInvokeMethod(Method: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInvokeMethod(Method: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCustomMethod(Method: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProtocolUIResponse(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";ModelID: Guid;Sender: Text;EventName: Text;var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnProtocolUITimer(POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";ModelID: Guid;var Handled: Boolean)
    begin
    end;
}


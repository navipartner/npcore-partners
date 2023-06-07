﻿codeunit 6014665 "NPR POS Workflow 3.0"
{
    Access = Internal;

    var
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
        POSSession: Codeunit "NPR POS Session";
    begin
        RetrieveActionContext(Context, ActionCode, WorkflowId, Workflowstep, ActionId, ActionContext);
        if not Enum::"NPR POS Workflow".Names().Contains(ActionCode) then
            exit(false);

        POSSession.ErrorIfNotInitialized();
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
        SentryScope: Codeunit "NPR Sentry Scope";
        SentryTransaction: Codeunit "NPR Sentry Transaction";
        SentrySpan: Codeunit "NPR Sentry Span";
        SentryTraceId: Text;
        SentryTraceSpanId: Text;
    begin
        FrontEnd.SetWorkflowID(WorkflowId);

        JavaScriptInterface.ApplyDataState(Context, POSSession, FrontEnd);
        JSON.InitializeJObjectParser(Context);

        SentryScope.TryGetActiveTransaction(SentryTransaction);
        if JSON.GetString('sentryTraceId', SentryTraceId) and JSON.GetString('sentrySpanId', SentryTraceSpanId) then begin
            SentryTransaction.SetExternalTraceValues(SentryTraceId, SentryTraceSpanId);
        end;
        SentryTransaction.StartChildSpan('bc.workflow.invoke:' + ActionCode + ',' + WorkflowStep, 'bc.workflow.invoke', SentrySpan);
        SentryScope.SetActiveSpan(SentrySpan);

        Success := InvokeOnActionThroughOnRun(ActionCode, WorkflowStep, JSON, FrontEnd, Self);

        SentrySpan.Finish();

        if Success then begin
            JavaScriptInterface.RefreshData(FrontEnd);
            Signal.SignalSuccess(WorkflowId, ActionId);
        end else begin
            EmitError(ActionCode, WorkflowStep, JSON, GetLastErrorText());
            Signal.SignalFailureAndThrowError(WorkflowId, ActionId, GetLastErrorText);
        end;

        Signal.SetEngine20(JSON.GetContextObject());

        FrontEnd.WorkflowCallCompleted(Signal);
        FrontEnd.ClearWorkflowID();
    end;

    local procedure EmitError(ActionCode: Text; WorkflowStep: Text; JSON: Codeunit "NPR POS Json Helper"; ErrorText: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin

        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_ActionCode', ActionCode);
        CustomDimensions.Add('NPR_WorkflowStep', WorkflowStep);
        CustomDimensions.Add('NPR_ActionContext', JSON.ToString());
        CustomDimensions.Add('NPR_ErrorText', ErrorText);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");

        CustomDimensions.Add('NPR_CallStack', GetLastErrorCallStack());

        Session.LogMessage('NPR_InvokeAction30_Error', ErrorText, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;
}

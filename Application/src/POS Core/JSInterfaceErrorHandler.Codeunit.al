codeunit 6014666 "NPR JS Interface Error Handler"
{
    Access = Internal;

    var
        _OnRunType: Option InvokeAction,BeforeWorkflow,MethodInvocation;
        _OnRunInitialized: Boolean;
        _OnRunPOSAction: Record "NPR POS Action";
        _OnRunWorkflowStep: Text;
        _OnRunContext: JsonObject;
        _OnRunParameters: JsonObject;
        _OnRunFrontEnd: Codeunit "NPR POS Front End Management";
        _OnRunHandled: Boolean;
        _OnRunMethod: Text;

    trigger OnRun()
    var
        POSJavascriptInterface: Codeunit "NPR POS JavaScript Interface";
        TextErrorMustNotRunThisCodeunit: Label 'You must not run this codeunit directly. This codeunit is intended to be run only from within itself.', Locked = true; // This is development type of error, do not translate!
        ActionBlockedErr: Label 'Action %1 is blocked and cannot be invoked. Please contact system manager if you think this should be changed.';
        POSSession: Codeunit "NPR POS Session";
    begin
        if not _OnRunInitialized then
            Error(TextErrorMustNotRunThisCodeunit);

        if (_OnRunType in [_OnRunType::InvokeAction, _OnRunType::BeforeWorkflow]) and _OnRunPOSAction.Blocked then
            Error(ActionBlockedErr, _OnRunPOSAction.Code);

        case _OnRunType of
            _OnRunType::InvokeAction:
                POSJavascriptInterface.OnAction(_OnRunPOSAction, _OnRunWorkflowStep, _OnRunContext, POSSession, _OnRunFrontEnd, _OnRunHandled);
            _OnRunType::BeforeWorkflow:
                POSJavascriptInterface.OnBeforeWorkflow(_OnRunPOSAction, _OnRunParameters, POSSession, _OnRunFrontEnd, _OnRunHandled);
            _OnRunType::MethodInvocation:
                POSJavascriptInterface.OnCustomMethod(_OnRunMethod, _OnRunContext, POSSession, _OnRunFrontEnd, _OnRunHandled);
        end;
    end;

    internal procedure InvokeOnActionThroughOnRun(POSActionIn: Record "NPR POS Action"; WorkflowStepIn: Text; ContextIn: JsonObject; POSSessionIn: Codeunit "NPR POS Session"; FrontEndIn: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR JS Interface Error Handler"; var Handled: Boolean) Success: Boolean
    begin
        _OnRunHandled := false;
        _OnRunInitialized := true;

        _OnRunPOSAction := POSActionIn;
        _OnRunWorkflowStep := WorkflowStepIn;
        _OnRunContext := ContextIn;
        _OnRunFrontEnd := FrontEndIn;
        _OnRunType := _OnRunType::InvokeAction;
        ClearLastError();

        Success := Self.Run();
        Handled := _OnRunHandled;
        EmitResult(Success, Handled);

        _OnRunInitialized := false;
    end;

    internal procedure InvokeOnBeforeWorkflowThroughOnRun(POSActionIn: Record "NPR POS Action"; ParametersIn: JsonObject; POSSessionIn: Codeunit "NPR POS Session"; FrontEndIn: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR JS Interface Error Handler"; var Handled: Boolean) Success: Boolean
    begin
        _OnRunHandled := false;
        _OnRunInitialized := true;

        _OnRunPOSAction := POSActionIn;
        _OnRunParameters := ParametersIn;
        _OnRunFrontEnd := FrontEndIn;
        _OnRunType := _OnRunType::BeforeWorkflow;

        Success := Self.Run();
        Handled := _OnRunHandled;
        EmitResult(Success, Handled);

        _OnRunInitialized := false;
    end;

    internal procedure InvokeCustomMethodThroughOnRun(Method: Text; Context: JsonObject; FrontEnd: Codeunit "NPR POS Front End Management"; Self: Codeunit "NPR JS Interface Error Handler"; var Handled: Boolean) Success: Boolean
    begin
        _OnRunHandled := false;
        _OnRunInitialized := true;

        _OnRunMethod := Method;
        _OnRunContext := Context;
        _OnRunFrontEnd := FrontEnd;
        _OnRunType := _OnRunType::MethodInvocation;

        Success := Self.Run();
        Handled := _OnRunHandled;
        EmitResult(Success, Handled);

        _OnRunInitialized := false;
    end;

    local procedure EmitResult(Success: Boolean; Handled: Boolean)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
        VerbosityLevel: Verbosity;
        TempText: Text;
        MessageText: Text;
        TempActionCode: Code[20];
        Text001: Label 'Action %1 does not seem to have a registered handler, or the registered handler failed to notify the framework about successful processing of the action.';
    begin

        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");
        CustomDimensions.Add('NPR_RunType', Format(_OnRunType, 0, 9));

        TempActionCode := _OnRunPOSAction.Code;
        if (TempActionCode = '') then
            TempActionCode := '<BLANK>';

        VerbosityLevel := Verbosity::Normal;
        if ((not Success) or (not Handled)) then begin
            TempText := GetLastErrorText();
            VerbosityLevel := Verbosity::Error;

            if ((not Success) and (TempText = '')) then // This is probably a "rollback event" or a framework error.
                VerbosityLevel := Verbosity::Warning;

            if (not Handled) and (_OnRunPOSAction.Code = '') then
                TempText := StrSubstNo(Text001, '<blank>');

            CustomDimensions.Add('NPR_ErrorText', TempText);
            CustomDimensions.Add('NPR_CallStack', GetLastErrorCallStack());
        end;

        if (_OnRunType = _OnRunType::BeforeWorkflow) then begin
            CustomDimensions.Add('NPR_Action', TempActionCode);
            _OnRunParameters.WriteTo(TempText);
            CustomDimensions.Add('NPR_Parameters', TempText); // Could contain sensitive data
            MessageText := StrSubstNo('OnBeforeWorkflow => %1', TempActionCode);
        end;

        if (_OnRunType = _OnRunType::InvokeAction) then begin
            CustomDimensions.Add('NPR_Action', TempActionCode);
            CustomDimensions.Add('NPR_WorkflowStep', _OnRunWorkflowStep);
            _OnRunContext.WriteTo(TempText);
            CustomDimensions.Add('NPR_Context', TempText); // Could contain sensitive data
            MessageText := StrSubstNo('InvokeAction => %1, %2', TempActionCode, _OnRunWorkflowStep);
        end;

        if (_OnRunType = _OnRunType::MethodInvocation) then begin
            _OnRunContext.WriteTo(TempText);
            CustomDimensions.Add('NPR_Context', TempText); // Could contain sensitive data
            CustomDimensions.Add('NPR_Method', _OnRunMethod);
            MessageText := StrSubstNo('InvokeMethod => %1 (%2)', GetValueAsText(_OnRunContext, 'name'), _OnRunMethod);
        end;

        Session.LogMessage('NPR_PosAction', MessageText, VerbosityLevel, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    local procedure GetValueAsText(JObject: JsonObject; KeyName: Text): Text
    var
        JToken: JsonToken;
    begin
        if (not JObject.Contains(KeyName)) then
            exit('');

        if (not JObject.SelectToken(KeyName, JToken)) then
            exit('');

        if (JToken.AsValue().IsNull()) then
            exit('');

        exit(JToken.AsValue().AsText());
    end;
}
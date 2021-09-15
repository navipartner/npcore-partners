codeunit 6150882 "NPR Workflow Action" implements "NPR IAction", "NPR IJsonSerializable"
{
    var
        _workflow: Codeunit "NPR Workflow";
        _state: JsonObject;
        _base: Codeunit "NPR Base Action";
        TextActionDoesNotExist: Label 'Action %1 does not exist.';
        TextUndefinedParameter: Label '%2 specifies a value for a parameter %3, that is not defined for action %1.';
        TextParameterNotDefined: Label 'Action %1 defines parameter %3, but the value for this parameter is not specified in %2.';
        TextParameterValueInvalid: Label '%2 specifies value [%5] for parameter %3, which is not a valid %4 as required by action %1.';

    procedure GetWorkflow(var WorkflowOut: Codeunit "NPR Workflow");
    begin
        WorkflowOut := _workflow;
    end;

    procedure Type() ActionType: Enum "NPR Action Type";
    begin
        exit(ActionType::Action);
    end;

    procedure Content(): JsonObject;
    begin
        exit(_base.Content());
    end;

    procedure Parameters(): JsonObject;
    begin
        exit(_base.Parameters());
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Json := _base.GetJson();
        Json.Add('Type', 'Workflow');
        Json.Add('Workflow', _workflow.GetJson());
        Json.Add('State', _state);
    end;

    procedure CheckConfiguration(POSSession: Codeunit "NPR POS Session"; Source: Text; var ActionMoniker: Text; var ErrorText: Text; var Severity: Integer): Boolean;
    var
        Parameter: Record "NPR POS Action Parameter";
        Param: Text;
        Token: JsonToken;
        Value: Text;
    begin
        ActionMoniker := _workflow.Name();

        // Action does not exist
        if not POSSession.IsSessionAction(CopyStr(_workflow.Name(), 1, 20)) then begin
            Severity := 100;
            ErrorText := StrSubstNo(TextActionDoesNotExist, _workflow.Name());
            exit(false);
        end;

        // Specifies an undefined parameter
        foreach Param in _base.Parameters().Keys() do begin
            if not Parameter.Get(_workflow.Name(), Param) and not (CopyStr(Param, 1, 8) = '_option_') then begin
                Severity := 10;
                ErrorText := StrSubstNo(TextUndefinedParameter, _workflow.Name(), Source, Param);
                exit(false);
            end;
        end;

        Parameter.SetRange("POS Action Code", _workflow.Name());
        if Parameter.FindSet() then
            repeat
                // Parameter not specified
                if not _base.Parameters().Contains(Parameter.Name) then begin
                    Severity := 5;
                    ErrorText := StrSubstNo(TextParameterNotDefined, _workflow.Name(), Source, Parameter.Name);
                    exit(false);
                end;

                // Parameter of incorrect type
                _base.Parameters().Get(Parameter.Name, Token);
                Value := Token.AsValue().AsText();
                if not IsCorrectParameterValueType(Parameter, Value) then begin
                    Severity := 3;
                    if Parameter."Data Type" = Parameter."Data Type"::Option then begin
                        _base.Content().Get('param_option_' + Parameter.Name + 'originalValue', Token);
                        Value := Token.AsValue().AsText();
                        Severity := 1;
                    end;
                    ErrorText := StrSubstNo(TextParameterValueInvalid, _workflow.Name(), Source, Parameter.Name, Parameter."Data Type", Value);
                    exit(false);
                end;
            until Parameter.Next() = 0;

        exit(true);
    end;

    [TryFunction]
    local procedure IsCorrectParameterValueType(Parameter: Record "NPR POS Action Parameter"; Value: Text)
    begin
        Parameter.Validate("Default Value", Value);
        if (Parameter."Data Type" = Parameter."Data Type"::Option) and (Value = '-1') then
            Parameter.FieldError("Default Value");
    end;

    procedure ConfigureFromMenuButton(MenuButton: Record "NPR POS Menu Button"; POSSession: Codeunit "NPR POS Session"; var ActionOut: interface "NPR IAction");
    var
        Instance: Codeunit "NPR Workflow Action";
    begin
        ConfigureFromMenuButton(MenuButton, POSSession, Instance);
        ActionOut := Instance;
    end;

    procedure ConfigureFromMenuButton(MenuButton: Record "NPR POS Menu Button"; POSSession: Codeunit "NPR POS Session"; var Instance: Codeunit "NPR Workflow Action");
    var
        TempPOSAction: Record "NPR POS Action" temporary;
        InStr: InStream;
        Calculated: Boolean;
        Workflow: Codeunit "NPR Workflow";
    begin
        Instance.GetWorkflow(Workflow);

        if POSSession.RetrieveSessionAction(MenuButton."Action Code", TempPOSAction) then begin
            if TempPOSAction.Workflow.HasValue() then begin
                TempPOSAction.Workflow.CreateInStream(InStr);
                Workflow.DeserializeFromJsonStream(InStr);
                if TempPOSAction."Bound to DataSource" then
                    Instance.Content().Add('DataBinding', true);
                if TempPOSAction."Custom JavaScript Logic".HasValue() then begin
                    Instance.Content().Add('CustomJavaScript', TempPOSAction.GetCustomJavaScriptLogic());
                end;
                if TempPOSAction.Description <> '' then
                    Instance.Content().Add('Description', TempPOSAction.Description);
                Calculated := true;
            end;
        end;

        if not Calculated then begin
            Workflow.SetName(TempPOSAction.Code);
        end;
    end;
}

codeunit 6248235 "NPR POS Action Param Buf."
{
    Access = Public;

    var
        _WorkflowConfig: Codeunit "NPR POS Workflow Config";
        _Workflow: Enum "NPR POS Workflow";

    procedure AddTextParameter(Name: Text[30]; DefaultValue: Text; CaptionName: Text; CaptionDescription: Text)
    begin
        _WorkflowConfig.AddTextParameter(Name, DefaultValue, CaptionName, CaptionDescription);
    end;

    procedure AddIntegerParameter(Name: Text[30]; DefaultValue: Integer; CaptionName: Text; CaptionDescription: Text)
    begin
        _WorkflowConfig.AddIntegerParameter(Name, DefaultValue, CaptionName, CaptionDescription);
    end;

    procedure AddDateParameter(Name: Text[30]; DefaultValue: Date; CaptionName: Text; CaptionDescription: Text)
    begin
        _WorkflowConfig.AddDateParameter(Name, DefaultValue, CaptionName, CaptionDescription);
    end;

    procedure AddBooleanParameter(Name: Text[30]; DefaultValue: Boolean; CaptionName: Text; CaptionDescription: Text)
    begin
        _WorkflowConfig.AddBooleanParameter(Name, DefaultValue, CaptionName, CaptionDescription);
    end;

    procedure AddDecimalParameter(Name: Text[30]; DefaultValue: Decimal; CaptionName: Text; CaptionDescription: Text)
    begin
        _WorkflowConfig.AddDecimalParameter(Name, DefaultValue, CaptionName, CaptionDescription);
    end;

    procedure AddOptionParameter(Name: Text[30]; Options: Text[250]; DefaultValue: Text[250]; CaptionName: Text; CaptionDescription: Text; CaptionOptions: Text)
    begin
        _WorkflowConfig.AddOptionParameter(Name, Options, DefaultValue, CaptionName, CaptionDescription, CaptionOptions);
    end;

    internal procedure SetParameters(Workflow: Enum "NPR POS Workflow"; var WorkflowConfig: Codeunit "NPR POS Workflow Config")
    begin
        _Workflow := Workflow;
        _WorkflowConfig := WorkflowConfig;
    end;

    procedure GetAction(): Enum "NPR POS Workflow"
    begin
        exit(_Workflow);
    end;
}
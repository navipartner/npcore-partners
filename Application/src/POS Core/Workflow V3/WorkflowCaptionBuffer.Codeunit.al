codeunit 6014572 "NPR Workflow Caption Buffer"
{
    // Stores the v3 workflow captions detected during discovery so they can be injected when POS session initializes or POS parameter page opens
    SingleInstance = true;
    Access = Internal;

    var
        _ParameterNameCaption: Dictionary of [Text, Dictionary of [Text, Text]];
        _ParameterDescriptionCaption: Dictionary of [Text, Dictionary of [Text, Text]];
        _ParameterOptionCaption: Dictionary of [Text, Dictionary of [Text, Text]];
        _FrontendLabels: Dictionary of [Text, Dictionary of [Text, Text]];
        _ActionDescriptions: Dictionary of [Text, Text];

    procedure GetAllParameterCaptionsOnPOSSessionInit(CaptionMgt: Codeunit "NPR POS Caption Management")
    var
        ActionCode: Text;
        ActionFrontendLabels: Dictionary of [Text, Text];
        FrontendLabel: Text;
    begin
        foreach ActionCode in _FrontendLabels.Keys() do begin
            _FrontendLabels.Get(ActionCode, ActionFrontendLabels);
            foreach FrontendLabel in ActionFrontendLabels.Keys() do begin
                CaptionMgt.AddActionCaption(ActionCode, FrontendLabel, ActionFrontendLabels.Get(FrontendLabel));
            end;
        end;
    end;

    procedure GetParameterNameCaption(ActionCode: Text; ParameterName: Text): Text
    var
        ParameterDict: Dictionary of [Text, Text];
        Caption: Text;
    begin
        if not _ParameterNameCaption.Get(ActionCode, ParameterDict) then
            exit;
        if ParameterDict.Get(ParameterName, Caption) then
            exit(Caption);
    end;

    procedure GetParameterDescriptionCaption(ActionCode: Text; ParameterName: Text): Text
    var
        ParameterDict: Dictionary of [Text, Text];
        Caption: Text;
    begin
        if not _ParameterDescriptionCaption.Get(ActionCode, ParameterDict) then
            exit;
        if ParameterDict.Get(ParameterName, Caption) then
            exit(Caption);
    end;

    procedure GetParameterOptionsCaption(ActionCode: Text; ParameterName: Text): Text
    var
        ParameterDict: Dictionary of [Text, Text];
        Caption: Text;
    begin
        if not _ParameterOptionCaption.Get(ActionCode, ParameterDict) then
            exit;
        if ParameterDict.Get(ParameterName, Caption) then
            exit(Caption);
    end;

    procedure GetActionDescription(ActionCode: Text) Description: Text
    begin
        if not _ActionDescriptions.Get(ActionCode, Description) then
            exit;
    end;

    procedure ClearAll()
    begin
        Clear(_ParameterDescriptionCaption);
        Clear(_ParameterNameCaption);
        Clear(_ParameterOptionCaption);
        Clear(_FrontendLabels);
        Clear(_ActionDescriptions);
    end;

    procedure AddWorkflowNameCaptions(ActionCode: Text; Value: Dictionary of [Text, Text])
    begin
        _ParameterNameCaption.Set(ActionCode, Value);
    end;

    procedure AddWorkflowDescriptionCaptions(ActionCode: Text; Value: Dictionary of [Text, Text])
    begin
        _ParameterDescriptionCaption.Set(ActionCode, Value);
    end;

    procedure AddWorkflowOptionCaptions(ActionCode: Text; Value: Dictionary of [Text, Text])
    begin
        _ParameterOptionCaption.Set(ActionCode, Value);
    end;

    procedure AddFrontendLabels(ActionCode: Text; Value: Dictionary of [Text, Text])
    begin
        _FrontendLabels.Set(ActionCode, Value);
    end;

    procedure AddActionDescription(ActionCode: Text; ActionDescription: Text)
    begin
        _ActionDescriptions.Set(ActionCode, ActionDescription);
    end;
}
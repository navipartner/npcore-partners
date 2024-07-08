codeunit 6150777 "NPR Front-End: CfgReusableWkf." implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _action: Codeunit "NPR Workflow Action";

    procedure Initialize(Action: Codeunit "NPR Workflow Action");
    begin
        _action := Action;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ConfigureReusableWorkflow');
        Json.Add('Content', _content);
        Json.Add('Action', _action.GetJson());
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

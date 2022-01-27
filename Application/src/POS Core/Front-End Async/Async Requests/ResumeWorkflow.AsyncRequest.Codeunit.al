codeunit 6150775 "NPR Front-End: ResumeWorkflow" implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _workflowId: Integer;
        _actionId: Integer;

    procedure Initialize(Id: Integer; ActionId: Integer)
    begin
        _workflowId := Id;
        _actionId := ActionId;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ResumeWorkflow');
        Json.Add('Content', _content);
        Json.Add('WorkflowId', _workflowId);

        _content.Add('actionId', _actionId);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

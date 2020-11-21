codeunit 6150774 "NPR Front-End: PauseWorkflow" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _workflowId: Integer;

    procedure Initialize(Id: Integer)
    begin
        _workflowId := Id;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'PauseWorkflow');
        Json.Add('Content', _content);
        Json.Add('WorkflowId', _workflowId);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

codeunit 6150769 "NPR Front-End: ProvideContext" implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _context: JsonObject;
        _workflowId: Integer;
        _action: Text;

    procedure Initialize(WorkflowId: Integer; "Action": Text)
    begin
        _workflowId := WorkflowId;
        _action := "Action";
    end;

    procedure StoreContext(Context: JsonObject)
    begin
        _context := Context;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ProvideContext');
        Json.Add('Content', _content);
        Json.Add('WorkflowId', _workflowId);
        Json.Add('Context', _context);

        _content.Add('actionCode', _action);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

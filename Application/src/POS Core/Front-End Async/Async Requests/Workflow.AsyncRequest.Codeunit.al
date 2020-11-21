codeunit 6150765 "NPR Front-End: WorkflowRequest" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _context: JsonObject;
        _workflowId: Integer;
        _workflow: Text;
        _step: Text;
        _id: Guid;
        _explicit: Boolean;
        _nested: Boolean;
        _parameters: JsonObject;
        _parametersSet: Boolean;
        _workflowContext: JsonObject;
        _workflowContextSet: Boolean;

    procedure Initialize(WorkflowId: Integer; Workflow: Text; Step: Text; Id: Guid)
    begin
        ClearAll();
        _workflowId := WorkflowId;
        _workflow := Workflow;
        _step := Step;
        _id := Id;
    end;

    procedure SetExplicit(Explicit: Boolean);
    begin
        _explicit := Explicit;
    end;

    procedure SetNested(Nested: Boolean);
    begin
        _nested := Nested;
    end;

    local procedure IsEmpty(Json: JsonObject): Boolean
    var
        Content: Text;
    begin
        Json.WriteTo(Content);
        Content := Content.Trim();
        exit(Content = '');
    end;

    procedure SetParameters(Parameters: JsonObject)
    var
        Check: Text;
    begin
        _parametersSet := false;
        if IsEmpty(Parameters) then
            exit;

        _parameters := Parameters;
        _parametersSet := true;
    end;

    procedure SetWorkflowContext(WorkflowContext: JsonObject)
    begin
        _workflowContextSet := false;
        if IsEmpty(WorkflowContext) then
            exit;

        _workflowContext := WorkflowContext;
        _workflowContextSet := true;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'Workflow');
        Json.Add('Content', _content);
        Json.Add('Context', _context);
        Json.Add('WorkflowId', _workflowId);
        Json.Add('WorkflowName', _workflow);
        Json.Add('StepName', _step);
        Json.Add('BackEndId', _id);

        if (_explicit) then
            _content.Add('explicit', _explicit);
        if (_nested) then
            _content.Add('nested', _nested);
        if (_parametersSet) then
            _content.Add('workflowParameters', _parameters);
        if (_workflowContextSet) then
            _content.Add('workflowContext', _workflowContext);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;

    procedure GetContext(): JsonObject
    begin
        exit(_context);
    end;
}
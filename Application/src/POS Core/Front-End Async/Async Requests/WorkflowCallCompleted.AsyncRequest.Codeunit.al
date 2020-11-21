codeunit 6150770 "NPR Front-End: WkfCallCompl." implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _workflowId: Integer;
        _actionId: Integer;
        _success: Boolean;
        _throwError: Boolean;
        _errorMessage: Text;
        _engine: Text;
        _context: JsonObject;

    procedure SignalSuccess(WorkflowId: Integer; ActionId: Integer)
    begin
        ClearAll();
        _workflowId := WorkflowId;
        _actionId := ActionId;
        _success := true;
    end;

    procedure SignalFailure(WorkflowId: Integer; ActionId: Integer)
    begin
        SignalSuccess(WorkflowId, ActionId);
        _success := false;
    end;

    procedure SignalFailureAndThrowError(WorkflowId: Integer; ActionId: Integer; ErrorMessage: Text)
    begin
        SignalFailure(WorkflowId, ActionId);
        _throwError := true;
        _errorMessage := ErrorMessage;
    end;

    procedure SetWorkflowResponse(Response: Variant)
    var
        JsonMgt: Codeunit "NPR POS JSON Management";
    begin
        JsonMgt.AddVariantValueToJsonObject(_content, 'workflowResponse', Response);
    end;

    procedure SetQueuedWorkflows(QueuedWorkflows: JsonArray)
    begin
        _content.Add('queuedWorkflows', QueuedWorkflows);
    end;

    procedure SetEngine20(Context: JsonObject)
    begin
        _engine := '2.0';
        _context := Context;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'WorkflowCallCompleted');
        Json.Add('Content', _content);
        Json.Add('WorkflowId', _workflowId);
        Json.Add('ActionId', _actionId);
        Json.Add('Success', _success);
        Json.Add('ThrowError', _throwError);
        Json.Add('ErrorMessage', _errorMessage);

        if _engine <> '' then begin
            _content.Add('workflowEngine', _engine);
            _content.Add('context', _context);
        end;
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

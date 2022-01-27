codeunit 6150773 "NPR Front-End: InvokeDevice" implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _id: Text;
        _envelope: Text;
        _action: Text;
        _step: Text;
        _method: Text;
        _type: Text;
        _async: Boolean;

    procedure Initialize(Id: Text; Envelope: Text)
    begin
        _id := Id;
        _envelope := Envelope
    end;

    procedure SetAction(ActionName: Text; Step: Text)
    begin
        _action := ActionName;
        _step := Step;
    end;

    procedure SetMethod(MethodName: Text; TypeName: Text)
    begin
        _method := MethodName;
        _type := TypeName;
    end;

    procedure SetAsync()
    begin
        _async := true;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'InvokeDevice');
        Json.Add('Content', _content);
        Json.Add('Id', _id);
        Json.Add('Envelope', _envelope);
        Json.Add('RequiresResponse', true);

        _content.Add('Action', _action);
        _content.Add('Step', _step);
        _content.Add('Method', _method);
        _content.Add('TypeName', _type);

        if _async then
            _content.Add('Async', true);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

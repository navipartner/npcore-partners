codeunit 6150752 "NPR Front-End: Generic" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _method: Text;

    procedure SetMethod(Method: Text)
    begin
        _method := Method;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', _method);
        Json.Add('Content', _content);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

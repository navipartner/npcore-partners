codeunit 6150772 "NPR Front-End: CfgSecureMeth." implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _methods: JsonObject;

    procedure AddMethod(Name: Text; Definition: JsonObject)
    begin
        _methods.Add(Name, Definition);
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ConfigureSecureMethods');
        Json.Add('Content', _content);
        _content.Add('methods', _methods);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

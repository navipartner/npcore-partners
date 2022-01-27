codeunit 6150776 "NPR Front-End: SetOptions" implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;

    procedure SetOptions(Options: JsonObject)
    begin
        _content := Options;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'SetOptions');
        Json.Add('Content', _content);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

codeunit 6150881 "NPR Base Action" implements "NPR IJsonSerializable"
{
    var
        _content: JsonObject;
        _parameters: JsonObject;

    procedure Content(): JsonObject;
    begin
        exit(_content);
    end;

    procedure Parameters(): JsonObject;
    begin
        exit(_parameters);
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Json.Add('Parameters', _parameters);
        Json.Add('Content', _content);
    end;
}

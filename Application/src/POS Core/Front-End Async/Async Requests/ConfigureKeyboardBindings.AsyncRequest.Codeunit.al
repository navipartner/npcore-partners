codeunit 6150760 "NPR Front-End: ConfigKeyBind." implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _bindings: JsonArray;

    procedure SetBindings(Bindings: List of [Text])
    var
        Binding: Text;
    begin
        clear(_bindings);
        foreach Binding in Bindings do
            _bindings.Add(Binding);
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ConfigureKeyboardBindings');
        Json.Add('Content', _content);
        _content.Add('bindings', _bindings);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

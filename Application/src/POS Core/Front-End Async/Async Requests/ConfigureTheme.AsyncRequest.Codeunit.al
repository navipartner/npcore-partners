codeunit 6150761 "NPR Front-End: ConfigureTheme" implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _theme: JsonArray;

    procedure SetTheme(Theme: JsonArray)
    begin
        _theme := Theme;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ConfigureTheme');
        Json.Add('Content', _content);
        _content.Add('theme', _theme);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

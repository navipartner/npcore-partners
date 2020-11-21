codeunit 6150758 "NPR Front-End: ConfigFont." implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _font: Interface "NPR Font Definition";

    procedure SetFont(Font: Interface "NPR Font Definition")
    begin
        _font := Font;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ConfigureFont');
        Json.Add('Font', _font.GetJSON());
        Json.Add('Content', _content);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

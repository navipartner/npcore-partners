codeunit 6150754 "NPR Front-End: SetCaptions" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _captions: JsonObject;

    procedure SetCaptions(Captions: JsonObject)
    begin
        _captions := Captions;
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'SetCaptions');
        Json.Add('Content', _content);
        Json.Add('Captions', _captions);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

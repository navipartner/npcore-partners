codeunit 6150756 "NPR Front-End: ConfigActSeq." implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _sequences: JsonArray;

    procedure SetSequences(Sequences: JsonArray)
    begin
        _sequences := Sequences;
    end;

    procedure GetSequences(): JsonArray
    begin
        exit(_sequences);
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'ConfigureActionSequences');
        Json.Add('Content', _content);
        _content.Add('sequences', _sequences);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

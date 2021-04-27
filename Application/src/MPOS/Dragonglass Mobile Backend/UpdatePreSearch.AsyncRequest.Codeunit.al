codeunit 6014566 "NPR Front-End: UpdatePreSearch" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _resultsLbl: Label 'results', Locked = true;

    procedure SetResults(Results: JsonObject);
    begin
        if (_content.Contains(_resultsLbl)) then
            _content.Remove(_resultsLbl);
        _content.Add(_resultsLbl, Results);
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'UpdatePreSearch');
        Json.Add('Content', _content);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

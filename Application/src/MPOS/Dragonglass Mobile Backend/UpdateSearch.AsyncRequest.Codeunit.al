codeunit 6014567 "NPR Front-End: UpdateSearch" implements "NPR Front-End Async Request"
{
    var
        _content: JsonObject;
        _resultsLbl: Label 'results', Locked = true;
        _hasMoreLbl: Label 'hasMore', Locked = true;

    procedure SetHasMore(HasMore: Boolean);
    begin
        if _content.Contains(_hasMoreLbl) then
            _content.Remove(_hasMoreLbl);
        _content.Add(_hasMoreLbl, HasMore);
    end;

    procedure SetResults(Results: JsonArray);
    begin
        if (_content.Contains(_resultsLbl)) then
            _content.Remove(_resultsLbl);
        _content.Add(_resultsLbl, Results);
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'UpdateSearch');
        Json.Add('Content', _content);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

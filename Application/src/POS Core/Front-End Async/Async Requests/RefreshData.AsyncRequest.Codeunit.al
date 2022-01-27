codeunit 6150781 "NPR Front-End: RefreshData" implements "NPR Front-End Async Request"
{
    Access = Internal;
    var
        _content: JsonObject;
        _dataSets: JsonObject;

    procedure AddDataSet(Set: JsonObject);
    var
        DataSetProxy: Codeunit "NPR Data Set";
        DataSource: Text;
    begin
        DataSource := DataSetProxy.DataSource(Set);
        if (_dataSets.Contains(DataSource)) then
            _dataSets.Remove(DataSource);
        _dataSets.Add(DataSource, Set);
    end;

    procedure GetJson() Json: JsonObject
    begin
        Json.Add('Method', 'RefreshData');
        Json.Add('Content', _content);
        Json.Add('DataSets', _dataSets);
    end;

    procedure GetContent(): JsonObject
    begin
        exit(_content);
    end;
}

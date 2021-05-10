codeunit 6150891 "NPR Data Store"
{
    var
        _dataSets: JsonObject;
        _dataSources: JsonArray;

    procedure DataSources(): JsonArray;
    begin
        exit(_dataSources);
    end;

    procedure GetDataSet(Source: Text; var DataSetOut: Codeunit "NPR Data Set");
    var
        Token: JsonToken;
    begin
        if not _dataSets.Keys.Contains(Source) then begin
            DataSetOut.Constructor(Source);
            exit;
        end;

        _dataSets.Get(Source, Token);
        DataSetOut.Constructor(Token.AsObject());
    end;

    procedure StoreAndGetDelta(Set: Codeunit "NPR Data Set"): JsonObject;
    var
        Original: Codeunit "NPR Data Set";
        Merged: JsonObject;
    begin
        GetDataSet(Set.DataSource(), Original);
        Merged := Original.GetDelta(Set.GetJson());
        if _dataSets.Contains(Set.DataSource()) then
            _dataSets.Replace(Set.DataSource(), Set.GetJson())
        else
            _dataSets.Add(Set.DataSource(), Set.GetJson());

        exit(Merged);
    end;

    procedure Constructor(DataSources: JsonArray);
    begin
        _dataSources := DataSources;
    end;
}

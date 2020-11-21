codeunit 6150896 "NPR POS View" implements "NPR IJsonSerializable"
{
    var
        _content: JsonObject;
        _canCache: Boolean;
        _type: Enum "NPR View Type";
        _menus: JsonArray;
        _dataSources: JsonObject;
        _layout: JsonObject;
        _instanceId: Guid;

    procedure InstanceId(): Guid;
    begin
        if IsNullGuid(_instanceId) then
            _instanceId := CreateGuid();

        exit(_instanceId);
    end;

    procedure CanCache(): Boolean;
    begin
        exit(_canCache);
    end;

    procedure SetCanCache(NewCanCache: Boolean): Boolean;
    begin
        _canCache := NewCanCache;
    end;

    procedure Type(): Enum "NPR View Type";
    begin
        exit(_type);
    end;

    procedure SetType(NewType: Enum "NPR View Type");
    begin
        _type := NewType;
    end;

    procedure AddDataSource(DataSource: Codeunit "NPR Data Source");
    begin
        if (_dataSources.Contains(DataSource.Id)) then
            _dataSources.Replace(DataSource.Id, DataSource.GetJson())
        else
            _dataSources.Add(DataSource.Id, DataSource.GetJson());
    end;

    procedure GetDataSources() DataSources: JsonArray;
    var
        DataSource: Text;
        Token: JsonToken;
    begin
        foreach DataSource in _dataSources.Keys() do begin
            _dataSources.Get(DataSource, Token);
            DataSources.Add(Token.AsObject());
        end;
    end;

    local procedure GetDescendants(Token: JsonToken; DataSourceNames: List of [Text]);
    var
        Property: Text;
        SubToken: JsonToken;
    begin
        if (Token.IsArray()) then begin
            foreach Subtoken in Token.AsArray() do begin
                if SubToken.IsArray() or Subtoken.IsObject() then
                    GetDescendants(SubToken, DataSourceNames);
            end;
            exit;
        end;

        if (Token.IsObject()) then begin
            foreach Property in Token.AsObject().Keys() do begin
                Token.AsObject().Get(Property, SubToken);

                // Do not "and" these two ifs into one! AL has no short-circuit evaluation!
                if (Property = 'dataSource') and (SubToken.IsValue()) then
                    if not DataSourceNames.Contains(SubToken.AsValue().AsText()) then
                        DataSourceNames.Add(SubToken.AsValue().AsText());

                if SubToken.IsArray() or Subtoken.IsObject() then
                    GetDescendants(SubToken, DataSourceNames);
            end;
        end;
    end;

    procedure GetLayoutDataSourceNames(var Result: List of [Text]);
    begin
        Clear(Result);
        GetDescendants(_layout.AsToken(), Result);
    end;

    procedure ParseLayout(Layout: Text);
    begin
        _layout.ReadFrom(Layout);
    end;

    procedure Content(): JsonObject;
    begin
        exit(_content);
    end;

    procedure GetJson() Json: JsonObject;
    begin
        Json.Add('canCache', _canCache);
        Json.Add('type', _type.AsInteger());
        Json.Add('menus', _menus);
        Json.Add('dataSources', _dataSources);
        Json.Add('layout', _layout);
        Json.Add('Content', _content);
    end;
}

codeunit 6150893 "NPR Data Set" implements "NPR IJsonSerializable"
{
    Access = Internal;
    var
        _constructed: Boolean;
        _json: JsonObject;
        _content: JsonObject;
        _rows: JsonArray;
        _isDelta: JsonToken;
        _currentPosition: JsonToken;
        _dataSource: JsonToken;
        _totals: JsonObject;

        LabelContent: Label 'Content', Locked = true;
        LabelRows: Label 'rows', Locked = true;
        LabelIsDelta: Label 'isDelta', Locked = true;
        LabelCurrentPosition: Label 'currentPosition', Locked = true;
        LabelDataSource: Label 'dataSource', Locked = true;
        LabelTotals: Label 'totals', Locked = true;

        ErrorAccessViolation: Label 'Attempting to access an instance of "NPR Data Source" before calling its constructor.';

        RowStatic: Codeunit "NPR Data Row";

    local procedure MakeSureIsConstructed();
    begin
        if not _constructed then
            Error(ErrorAccessViolation);
    end;

    procedure Rows(): JsonArray;
    begin
        MakeSureIsConstructed();
        exit(_rows);
    end;

    procedure IsDelta(): Boolean;
    begin
        MakeSureIsConstructed();
        exit(_isDelta.AsValue().AsBoolean());
    end;

    procedure SetIsDelta(NewIsDelta: Boolean): Boolean;
    begin
        MakeSureIsConstructed();
        _json.Replace(LabelIsDelta, NewIsDelta);
        _json.Get(LabelIsDelta, _isDelta);
    end;

    procedure CurrentPosition(): Text;
    begin
        MakeSureIsConstructed();
        exit(_currentPosition.AsValue().AsText());
    end;

    procedure SetCurrentPosition(NewCurrentPosition: Text);
    begin
        MakeSureIsConstructed();
        _json.Replace(LabelCurrentPosition, NewCurrentPosition);
        _json.Get(LabelCurrentPosition, _currentPosition);
    end;

    procedure DataSource(): Text;
    begin
        MakeSureIsConstructed();
        exit(_dataSource.AsValue().AsText());
    end;

    procedure DataSource(FromJson: JsonObject): Text;
    var
        Token: JsonToken;
    begin
        // No need to call MakeSureIsConstructed - this method is static
        FromJson.Get(LabelDataSource, Token);
        exit(Token.AsValue().AsText());
    end;

    procedure Totals(): JsonObject;
    begin
        MakeSureIsConstructed();
        exit(_totals);
    end;

    procedure AddTotal(Total: Text; Amount: Decimal);
    begin
        MakeSureIsConstructed();
        _totals.Add(Total, Amount);
    end;

    procedure Constructor(NewDataSource: Text);
    begin
        Clear(_json);
        Clear(_content);
        Clear(_rows);
        Clear(_totals);

        _json.Add(LabelContent, _content);
        _json.Add(LabelRows, _rows);
        _json.Add(LabelTotals, _totals);

        _json.Add(LabelIsDelta, false);
        _json.Get(LabelIsDelta, _isDelta);

        _json.Add(LabelCurrentPosition, '');
        _json.Get(LabelCurrentPosition, _currentPosition);

        _json.Add(LabelDataSource, NewDataSource);
        _json.Get(LabelDataSource, _dataSource);

        _constructed := true;
    end;

    procedure Constructor(FromJson: JsonObject);
    var
        Token: JsonToken;
    begin
        _json := FromJson.Clone().AsObject();
        Clear(_content);
        Clear(_rows);
        Clear(_totals);

        _json.Get(LabelDataSource, _dataSource);
        _json.Get(LabelIsDelta, _isDelta);
        _json.Get(LabelCurrentPosition, _currentPosition);
        _json.Get(LabelDataSource, _dataSource);

        _json.Get(LabelContent, Token);
        _content := Token.AsObject();

        _json.Get(LabelRows, Token);
        _rows := Token.AsArray();

        _json.Get(LabelTotals, Token);
        _totals := Token.AsObject();

        _constructed := true;
    end;

    local procedure FindRow(Position: Text; var RowOut: Codeunit "NPR Data Row"): Boolean;
    var
        RowToken: JsonToken;
    begin
        if (Position = '') then
            exit(false);

        foreach RowToken in _rows do begin
            if RowStatic.Position(Rowtoken.AsObject()) = Position then begin
                RowOut.Constructor(Rowtoken.AsObject());
                exit(true);
            end;
        end;
    end;

    procedure ContainsRow(Position: Text): Boolean;
    var
        RowToken: JsonToken;
    begin
        if (Position = '') then
            exit(false);

        foreach RowToken in _rows do begin
            if RowStatic.Position(Rowtoken.AsObject()) = Position then
                exit(true);
        end;
    end;

    procedure GetDelta(ModifiedJson: JsonObject): JsonObject;
    var
        Modified: Codeunit "NPR Data Set";
        Set: Codeunit "NPR Data Set";
        RowToken: JsonToken;
        Existing: Codeunit "NPR Data Row";
        RowPosition: Text;
        Total: Text;
        TotalToken: JsonToken;
    begin
        MakeSureIsConstructed();

        Modified.Constructor(ModifiedJson);
        Set.Constructor(Modified.DataSource());
        Set.SetIsDelta(true);
        Set.SetCurrentPosition(Modified.CurrentPosition());

        foreach RowToken in Modified.Rows() do begin
            if not FindRow(RowStatic.Position(RowToken.AsObject()), Existing) then begin
                Set.Rows().Add(RowToken);
            end else begin
                if not Existing.Equals(RowToken.AsObject()) then
                    Set.Rows().Add(RowToken);
            end;
        end;

        foreach RowToken in _rows do begin
            RowPosition := RowStatic.Position(RowToken.AsObject());
            if not Modified.ContainsRow(RowPosition) then begin
                Clear(Existing);
                Existing.Constructor(RowPosition);
                Existing.SetDeleted(true);
                Set.Rows().Add(Existing.GetJson());
            end;
        end;

        foreach Total in Modified.Totals().Keys do begin
            Modified.Totals().Get(Total, TotalToken);
            Set.Totals().Add(Total, TotalToken.Clone());
        end;

        exit(Set.GetJson());
    end;

    procedure NewRow(Position: Text; var RowOut: Codeunit "NPR Data Row");
    begin
        MakeSureIsConstructed();
        Clear(RowOut);
        RowOut.Constructor(Position);
        _rows.Add(RowOut.GetJson());
    end;

    procedure Content(): JsonObject;
    begin
        exit(_content);
    end;

    procedure GetJson(): JsonObject;
    begin
        MakeSureIsConstructed();
        exit(_json);
    end;
}

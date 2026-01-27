codeunit 6184965 "NPR FE Custom List Assistant"
{
    Access = Internal;

    var
        _JsonHelper: Codeunit "NPR Json Helper";
        _POSCustomListIHandler: Interface "NPR POS Custom List IHandler";
        _Topic: Enum "NPR POS Custom List";
        _Direction: Option Up,ReadAroundCurrent,Down;
        _PositionFieldID: Label 'position', Locked = true, Comment = 'DO NOT TRANSLATE!';

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', true, true)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", OnCustomMethod, '', true, true)]
#endif
    local procedure OnRequestCustomListRecords(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not (Method in
            ['GetCustomListRecords'])
        then
            exit;
        Handled := true;

        case Method of
            'GetCustomListRecords':
                FrontEnd.RespondToFrontEndMethod(Context, GetCustomListRecords(Context), FrontEnd);
        end;
    end;

    local procedure GetCustomListRecords(Context: JsonObject) Response: JsonObject
    begin
        ClearLastError();
        if not TryGetCustomListRecords(Context, Response) then begin
            Clear(Response);
            Response.Add('error', GetLastErrorText());
        end;
    end;

    [TryFunction]
    local procedure TryGetCustomListRecords(Context: JsonObject; var Response: JsonObject)
    var
        RecRef: RecordRef;
        ColumnFilters: JsonArray;
        Columns: JsonArray;
        DataSet: JsonArray;
        Parameters: JsonToken;
        UserDataFilteringAndSearchCriteria: JsonObject;
        DatasetNormalFields: List of [Integer];
        SearchString: Text;
        BasePosition: Text;
        Direction: Integer;
        MaxPageSize: Integer;
        Title: Text;
    begin
        Parameters := Context.AsToken();
        _Topic := Enum::"NPR POS Custom List".FromInteger(
            Enum::"NPR POS Custom List".Ordinals().Get(Enum::"NPR POS Custom List".Names().IndexOf(_JsonHelper.GetJText(Parameters, 'topic', true))));
        Response.Add('topic', POSCustomListEnumValueName(_Topic));

        _POSCustomListIHandler := _Topic;
        RecRef.Open(_POSCustomListIHandler.GetTableNo());
#if not (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        RecRef.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
        RecRef.SetLoadFields(RecRef.SystemIdNo());

        GetColumnsAndApplyCrossColumnSearchString(Parameters, RecRef, SearchString, Columns, DatasetNormalFields);
        Response.Add('columns', Columns);

        Response.Add('sorting', ApplySorting(Parameters, RecRef, DatasetNormalFields));
        ApplyMandatoryColumnFilters(RecRef);
        ApplyUserColumnFilters(Parameters, RecRef, ColumnFilters);
        UserDataFilteringAndSearchCriteria.Add('searchString', SearchString);
        UserDataFilteringAndSearchCriteria.Add('columnFilters', ColumnFilters);
        Response.Add('filters', UserDataFilteringAndSearchCriteria);

        DataSet := GenerateDataSetChunk(Parameters, Columns, DatasetNormalFields, RecRef, BasePosition, Direction, MaxPageSize);
        Response.Add('basePosition', BasePosition);
        Response.Add('scrollDirection', Format(Direction - 1, 0, 9));
        Response.Add('maxPageSize', Format(MaxPageSize, 0, 9));
        Response.Add('dataSet', DataSet);

        Title := _JsonHelper.GetJText(Parameters, 'title', false);
        if Title <> '' then
            Response.Add('title', Title);
    end;

    local procedure GetColumnsAndApplyCrossColumnSearchString(Parameters: JsonToken; var RecRef: RecordRef; var SearchString: Text; var ColumnsOut: JsonArray; var DatasetNormalFields: List of [Integer])
    var
        Field: Record "Field";
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
        Columns: JsonArray;
        Column: JsonToken;
        JToken: JsonToken;
        DistinctColumnIDs: List of [Text];
        ColumnID: Text;
        FieldNo: Integer;
        ColumnsReceived: Boolean;
        ReservedColumnIDErr: Label 'The word ''%1'' is reserved and cannot be used as a column ID for the data set.\This is a programming bug, not a user error. Please contact system vendor.';
    begin
        SearchString := _JsonHelper.GetJText(Parameters, 'filters.searchString', false);

        if _JsonHelper.GetJsonToken(Parameters, 'columns', JToken) and JToken.IsArray() then begin
            Columns := JToken.AsArray();
            ColumnsReceived := Columns.Count() > 0;
        end;
        if not ColumnsReceived then begin
            Columns := _POSCustomListIHandler.GetColumns();
            POSCustomListHelper.OnAfterGetColumns(_Topic, Columns);
        end;
        If SearchString <> '' then
            RecRef.FilterGroup(-1);  //Cross-column search
        foreach Column in Columns do begin
            ColumnID := _JsonHelper.GetJText(Column, 'fieldId', true);
            if not DistinctColumnIDs.Contains(ColumnID) then begin
                DistinctColumnIDs.Add(ColumnID);
                if Evaluate(FieldNo, ColumnID) and Field.Get(RecRef.Number(), FieldNo) then begin
                    if Field.ObsoleteState <> Field.ObsoleteState::Removed then begin
                        ColumnsOut.Add(Column);
                        if Field.Class = Field.Class::Normal then begin
                            RecRef.AddLoadFields(FieldNo);
                            if FieldNo < RecRef.SystemIdNo() then
                                DatasetNormalFields.Add(FieldNo);
                            if SearchString <> '' then
                                Case Field.Type of
                                    Field.Type::Code:
                                        RecRef.Field(Field."No.").SetFilter('*' + UpperCase(SearchString) + '*');
                                    Field.Type::Text:
                                        RecRef.Field(Field."No.").SetFilter('@*' + SearchString + '*');
                                end;
                        end;
                    end;
                end else begin
                    if ColumnID = _PositionFieldID then
                        Error(ReservedColumnIDErr, _PositionFieldID);
                    ColumnsOut.Add(Column);
                end;
            end;
        end;
        RecRef.FilterGroup(0);
    end;

    local procedure ApplyMandatoryColumnFilters(var RecRef: RecordRef)
    var
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
        ColumnFilters: JsonArray;
    begin
        ColumnFilters := _POSCustomListIHandler.GetMandatoryFilters();
        POSCustomListHelper.OnAfterGetMandatoryFilters(_Topic, ColumnFilters);
        if ColumnFilters.Count() <= 0 then
            exit;
        RecRef.FilterGroup(2);
        ApplyFilterSet(ColumnFilters, RecRef);
        RecRef.FilterGroup(0);
    end;

    local procedure ApplyUserColumnFilters(Parameters: JsonToken; var RecRef: RecordRef; var ColumnFilters: JsonArray)
    var
        JToken: JsonToken;
    begin
        Clear(ColumnFilters);
        if not (_JsonHelper.GetJsonToken(Parameters, 'filters.columnFilters', JToken) and JToken.IsArray()) then
            exit;
        ColumnFilters := JToken.AsArray();
        ApplyFilterSet(ColumnFilters, RecRef);
    end;

    local procedure ApplyFilterSet(ColumnFilters: JsonArray; var RecRef: RecordRef)
    var
        Field: Record "Field";
        Column: JsonToken;
    begin
        foreach Column in ColumnFilters do
            If Field.Get(RecRef.Number(), _JsonHelper.GetJInteger(Column, 'fieldId', true)) and (Field.ObsoleteState <> Field.ObsoleteState::Removed) then
                SetFieldFilter(RecRef, Field, _JsonHelper.GetJText(Column, 'filterString', false));
    end;

    local procedure SetFieldFilter(var RecRef: RecordRef; Field: Record "Field"; FilterString: Text)
    begin
        if FilterString = '' then
            exit;
        if Field.Type = Field.Type::Code then
            FilterString := UpperCase(FilterString);
        RecRef.Field(Field."No.").SetFilter(FilterString);
    end;

    local procedure ApplySorting(Parameters: JsonToken; var RecRef: RecordRef; DatasetNormalFields: List of [Integer]) SortingParams: JsonObject
    var
        Field: Record "Field";
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
        JToken: JsonToken;
        OrderByFieldID: Integer;
        NotInScopeErr: Label 'The field with ID %1 must be defined in the base table with the class ''Normal'' and must be included as a column in the data set to be able to sort by it.';
    begin
        if _JsonHelper.GetJsonToken(Parameters, 'sorting', JToken) and JToken.IsObject() then
            SortingParams := JToken.AsObject()
        else begin
            SortingParams := _POSCustomListIHandler.GetSorting();
            POSCustomListHelper.OnAfterGetSorting(_Topic, SortingParams);
        end;
        OrderByFieldID := _JsonHelper.GetJInteger(SortingParams.AsToken(), 'orderByFieldId', false);
        if OrderByFieldID <> 0 then
            If Field.Get(RecRef.Number(), OrderByFieldID) and (Field.ObsoleteState <> Field.ObsoleteState::Removed) then begin
                if not DatasetNormalFields.Contains(OrderByFieldID) then
                    Error(NotInScopeErr);
                RecRef.SetView(StrSubstNo('SORTING(%1)', Field.FieldName));
            end;
        if _JsonHelper.GetJBoolean(SortingParams.AsToken(), 'descending', false) then
            RecRef.Ascending(false);
    end;

    local procedure GenerateDataSetChunk(Parameters: JsonToken; Columns: JsonArray; DatasetNormalFields: List of [Integer]; var RecRef: RecordRef; var LastKnownPosition: Text; var Direction: Integer; var MaxPageSize: Integer) DataSet: JsonArray
    var
        NumberOfRecords: Integer;
        FirstPositionGuid: Guid;
        PassedRecordPosition: Text;
        LastKnownPositionApplied: Boolean;
    begin
        LastKnownPosition := _JsonHelper.GetJText(Parameters, 'position', false);
        Direction := _JsonHelper.GetJInteger(Parameters, 'scrollDirection', false) + 1;
        if not (Direction in [_Direction::Up .. _Direction::Down]) then
            Direction := _Direction::Down;
        MaxPageSize := _JsonHelper.GetJInteger(Parameters, 'maxPageSize', false);
        if MaxPageSize < 3 then
            MaxPageSize := 50;

        if RecRef.IsEmpty() then
            exit;

        PassedRecordPosition := SetLastKnownPosition(RecRef, LastKnownPosition);
        LastKnownPositionApplied := PassedRecordPosition <> '';
        if not LastKnownPositionApplied then begin
            Clear(LastKnownPosition);
            if Direction = _Direction::ReadAroundCurrent then
                Direction := _Direction::Down;
        end;
        case Direction of
            _Direction::ReadAroundCurrent:
                begin
                    RecRef.Find('=><');
                    RecRef.Next(-MinInt(MaxPageSize DIV 4, 15));
                    FirstPositionGuid := RecRef.Field(RecRef.SystemIdNo()).Value();
                end;
            _Direction::Up,
            _Direction::Down:
                begin
                    if Direction = _Direction::Up then
                        RecRef.Ascending(not RecRef.Ascending());
                    if not LastKnownPositionApplied then
                        RecRef.FindSet()
                    else
                        if not RecRef.Find('=>') then
                            exit;
                    if RecRef.GetPosition(false) = PassedRecordPosition then
                        if RecRef.Next() = 0 then
                            exit;
                end;
        end;

        NumberOfRecords := 0;
        repeat
            NumberOfRecords += 1;
            AddRecordToDataSet(RecRef, Columns, DatasetNormalFields, false, DataSet);
        until (RecRef.Next() = 0) or (NumberOfRecords >= MaxPageSize);

        if (Direction = _Direction::ReadAroundCurrent) and (NumberOfRecords < MaxPageSize) then begin
            RecRef.GetBySystemId(FirstPositionGuid);
            while (RecRef.Next(-1) <> 0) and (NumberOfRecords < MaxPageSize) do begin
                NumberOfRecords += 1;
                AddRecordToDataSet(RecRef, Columns, DatasetNormalFields, true, DataSet);
            end;
        end;
    end;

    local procedure SetLastKnownPosition(var RecRef: RecordRef; LastKnownPosition: Text) RecordPosition: Text
    var
        DataSetFieldValues: JsonToken;
        LastKnownPositionJTok: JsonToken;
        FieldIDs: List of [Text];
        FieldID: Text;
    begin
        if LastKnownPosition = '' then
            exit;
        if not (LastKnownPositionJTok.ReadFrom(LastKnownPosition) and LastKnownPositionJTok.IsObject()) then
            exit;
        RecordPosition := _JsonHelper.GetJText(LastKnownPositionJTok, 'pKey', false);
        if RecordPosition = '' then
            exit;
        RecRef.SetPosition(RecordPosition);
        if LastKnownPositionJTok.AsObject().Get('fields', DataSetFieldValues) and DataSetFieldValues.IsObject() then begin
            FieldIDs := DataSetFieldValues.AsObject().Keys();
            foreach FieldID in FieldIDs do
                AssignFieldValue(RecRef, FieldID, DataSetFieldValues)
        end;
    end;

    local procedure AssignFieldValue(var RecRef: RecordRef; FieldID: Text; DataSetFieldValues: JsonToken)
    var
        Field: Record "Field";
        FldRef: FieldRef;
        FieldNo: Integer;
        ValueAsDateFormula: DateFormula;
        ValueAsGuid: Guid;
        ValueAsTime: Time;
    begin
        if not Evaluate(FieldNo, FieldID, 9) then
            exit;
        if FieldNo >= RecRef.SystemIdNo() then
            exit;
        if not (Field.Get(RecRef.Number(), FieldNo) and (Field.Class = Field.Class::Normal) and (Field.ObsoleteState <> Field.ObsoleteState::Removed)) then
            exit;
        FldRef := RecRef.Field(Field."No.");
        case FldRef.Type of
            FldRef.Type::Code:
                FldRef.Value := _JsonHelper.GetJCode(DataSetFieldValues, FieldID, Field.Len, false);
            FldRef.Type::Text:
                FldRef.Value := _JsonHelper.GetJText(DataSetFieldValues, FieldID, Field.Len, false);
            FldRef.Type::Boolean:
                FldRef.Value := _JsonHelper.GetJBoolean(DataSetFieldValues, FieldID, false);
            FldRef.Type::Integer,
            FldRef.Type::Duration:
                FldRef.Value := _JsonHelper.GetJInteger(DataSetFieldValues, FieldID, false);
            FldRef.Type::BigInteger:
                FldRef.Value := _JsonHelper.GetJBigInteger(DataSetFieldValues, FieldID, false);
            FldRef.Type::Decimal:
                FldRef.Value := _JsonHelper.GetJDecimal(DataSetFieldValues, FieldID, false);
            FldRef.Type::Option:
                FldRef.Value := FldRef.GetEnumValueOrdinal(FldRef.OptionCaption().Split(',').IndexOf(_JsonHelper.GetJText(DataSetFieldValues, FieldID, false)));
            FldRef.Type::Date:
                FldRef.Value := _JsonHelper.GetJDate(DataSetFieldValues, FieldID, false);
            FldRef.Type::Time:
                if Evaluate(ValueAsTime, _JsonHelper.GetJText(DataSetFieldValues, FieldID, false)) then
                    FldRef.Value := ValueAsTime;
            FldRef.Type::DateTime:
                FldRef.Value := _JsonHelper.GetJDT(DataSetFieldValues, FieldID, false);
            FldRef.Type::DateFormula:
                if Evaluate(ValueAsDateFormula, _JsonHelper.GetJText(DataSetFieldValues, FieldID, false)) then
                    FldRef.Value := ValueAsDateFormula;
            FldRef.Type::GUID:
                if Evaluate(ValueAsGuid, _JsonHelper.GetJText(DataSetFieldValues, FieldID, Field.Len, false)) then
                    FldRef.Value := ValueAsGuid;
        end;
    end;

    local procedure AddRecordToDataSet(RecRef: RecordRef; Columns: JsonArray; DatasetNormalFields: List of [Integer]; AddFirst: Boolean; var DataSet: JsonArray)
    var
        Field: Record "Field";
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
        CalculatedValue: Variant;
        DataSetNormalFieldRow: JsonObject;
        DataSetRow: JsonObject;
        Position: JsonObject;
        Column: JsonToken;
        FieldNo: Integer;
        FieldID: Text;
        Calculated: Boolean;
    begin
        foreach Column in Columns do begin
            FieldID := _JsonHelper.GetJText(Column, 'fieldId', true);
            Calculated := _POSCustomListIHandler.CalculateColumnValue(RecRef, FieldID, CalculatedValue);
            POSCustomListHelper.OnCalculateColumnValue(_Topic, RecRef, FieldID, CalculatedValue, Calculated);
            if not Evaluate(FieldNo, FieldID, 9) then
                FieldNo := 0;
            if not Calculated and (FieldNo <> 0) then
                if Field.Get(RecRef.Number(), FieldNo) then begin
                    if Field.Class = Field.Class::FlowField then
                        RecRef.Field(FieldNo).CalcField();
                    Calculated := true;
                    CalculatedValue := RecRef.Field(FieldNo).Value();
                end;
            if Calculated then begin
                AddFieldToDataSetRow(FieldID, CalculatedValue, DataSetRow);
                if FieldNo <> 0 then
                    if DatasetNormalFields.Contains(FieldNo) then
                        AddFieldToDataSetRow(FieldID, CalculatedValue, DataSetNormalFieldRow);
            end;
        end;
        Position.Add('pKey', RecRef.GetPosition(false));
        Position.Add('fields', DataSetNormalFieldRow);
        DataSetRow.Add(_PositionFieldID, JObjectToText(Position));
        if AddFirst then
            DataSet.Insert(0, DataSetRow)
        else
            DataSet.Add(DataSetRow);
    end;

    local procedure AddFieldToDataSetRow(FieldID: Text; FieldValue: Variant; var DataSetRow: JsonObject)
    var
        ValueAsInt: Integer;
        ValueAsBigInt: BigInteger;
        ValueAsDec: Decimal;
        ValueAsDate: Date;
        ValueAsDateTime: DateTime;
        ValueAsTime: Time;
        ValueAsGuid: Guid;
        ValueAsBool: Boolean;
    begin
        case true of
            FieldValue.IsInteger:
                begin
                    ValueAsInt := FieldValue;
                    DataSetRow.Add(FieldID, ValueAsInt);
                end;
            FieldValue.IsBigInteger:
                begin
                    ValueAsBigInt := FieldValue;
                    DataSetRow.Add(FieldID, ValueAsBigInt);
                end;
            FieldValue.IsDecimal:
                begin
                    ValueAsDec := FieldValue;
                    DataSetRow.Add(FieldID, ValueAsDec);
                end;
            FieldValue.IsBoolean:
                begin
                    ValueAsBool := FieldValue;
                    DataSetRow.Add(FieldID, ValueAsBool);
                end;
            FieldValue.IsDate:
                begin
                    ValueAsDate := FieldValue;
                    DataSetRow.Add(FieldID, ValueAsDate);
                end;
            FieldValue.IsDateTime:
                begin
                    ValueAsDateTime := FieldValue;
                    DataSetRow.Add(FieldID, ValueAsDateTime);
                end;
            FieldValue.IsTime:
                begin
                    ValueAsTime := FieldValue;
                    DataSetRow.Add(FieldID, ValueAsTime);
                end;
            FieldValue.IsGuid:
                begin
                    ValueAsGuid := FieldValue;
                    DataSetRow.Add(FieldID, Format(ValueAsGuid, 0, 4));
                end;
            else
                DataSetRow.Add(FieldID, Format(FieldValue));
        end;
    end;

    local procedure JObjectToText(JObject: JsonObject) Text: Text
    begin
        JObject.WriteTo(Text);
    end;

    local procedure POSCustomListEnumValueName(Topic: Enum "NPR POS Custom List") Result: Text
    begin
        Topic.Names().Get(Topic.Ordinals().IndexOf(Topic.AsInteger()), Result);
    end;

    local procedure MinInt(Int1: Integer; Int2: Integer): Integer
    begin
        if Int1 < Int2 then
            exit(Int1);
        exit(Int2);
    end;
}
codeunit 6184977 "NPR POS Custom List Helper Int"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;

    internal procedure AddColumn(Field: Record Field; var Columns: JsonArray)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        FieldType: Text;
        FieldOptionCaptions: Text;
        FieldClass: Text;
    begin
        if Field.ObsoleteState = Field.ObsoleteState::Removed then
            exit;
        RecRef.GetTable(Field);
        FldRef := RecRef.Field(Field.FieldNo(Type));
        FieldType := FldRef.GetEnumValueNameFromOrdinalValue(Field.Type);

        If Field.Type in
            [Field.Type::Code, Field.Type::Text, Field.Type::GUID, Field.Type::Boolean,
             Field.Type::Integer, Field.Type::BigInteger, Field.Type::Decimal, Field.Type::Option,
             Field.Type::Date, Field.Type::Time, Field.Type::DateTime, Field.Type::DateFormula, Field.Type::Duration]
        then begin
            FldRef := RecRef.Field(Field.FieldNo(Class));
            FieldClass := FldRef.GetEnumValueNameFromOrdinalValue(Field.Class);
            if Field.Type = Field.Type::Option then begin
                RecRef.Close();
                RecRef.Open(Field.TableNo);
                FldRef := RecRef.Field(Field."No.");
                FieldOptionCaptions := FldRef.OptionCaption();
            end;
        end else
            FieldClass := 'Linked';

        AddColumn(Format(Field."No.", 0, 9), Field."Field Caption", FieldType, FieldClass, FieldOptionCaptions, Columns);
    end;

    internal procedure AddColumn(FieldID: Text; FieldCaption: Text; FieldType: Text; FieldClass: Text; OptionCaptions: Text; var Columns: JsonArray)
    var
        Column: JsonObject;
        FieldNo: Integer;
    begin
        if Evaluate(FieldNo, FieldID, 9) then
            Column.Add('fieldId', FieldNo)
        else
            Column.Add('fieldId', FieldID);
        Column.Add('caption', FieldCaption);
        Column.Add('type', FieldType);
        if OptionCaptions <> '' then
            Column.Add('options', OptionCaptions);
        Column.Add('class', FieldClass);
        Columns.Add(Column);
    end;

    internal procedure AddMandatoryFilter(Field: Record Field; FilterString: Text; var ColumnFilters: JsonArray)
    var
        ColumnFilter: JsonObject;
    begin
        if FilterString = '' then
            exit;
        ColumnFilter.Add('fieldId', Field."No.");
        ColumnFilter.Add('filterString', FilterString);
        ColumnFilters.Add(ColumnFilter);
    end;
}
codeunit 6184972 "NPR POS Custom List Helper"
{
    Access = Public;

    procedure AddColumn(Field: Record Field; Columns: JsonArray)
    var
        POSCustomListHelperInt: Codeunit "NPR POS Custom List Helper Int";
    begin
        POSCustomListHelperInt.AddColumn(Field, Columns);
    end;

    procedure AddColumn(FieldID: Text; FieldCaption: Text; FieldType: Text; FieldClass: Text; Columns: JsonArray)
    var
        POSCustomListHelperInt: Codeunit "NPR POS Custom List Helper Int";
    begin
        POSCustomListHelperInt.AddColumn(FieldID, FieldCaption, FieldType, FieldClass, '', Columns);
    end;

    procedure AddColumn(FieldID: Text; FieldCaption: Text; FieldType: Text; FieldClass: Text; OptionCaptions: Text; Columns: JsonArray)
    var
        POSCustomListHelperInt: Codeunit "NPR POS Custom List Helper Int";
    begin
        POSCustomListHelperInt.AddColumn(FieldID, FieldCaption, FieldType, FieldClass, OptionCaptions, Columns);
    end;

    procedure AddMandatoryFilter(Field: Record Field; FilterString: Text; var ColumnFilters: JsonArray)
    var
        POSCustomListHelperInt: Codeunit "NPR POS Custom List Helper Int";
    begin
        POSCustomListHelperInt.AddMandatoryFilter(Field, FilterString, ColumnFilters);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetColumns(Topic: Enum "NPR POS Custom List"; var Columns: JsonArray)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetMandatoryFilters(Topic: Enum "NPR POS Custom List"; var ColumnFilters: JsonArray)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetSorting(Topic: Enum "NPR POS Custom List"; var SortingParams: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnCalculateColumnValue(Topic: Enum "NPR POS Custom List"; RecRef: RecordRef; FieldID: Text; var CalculatedFieldValue: Variant; var Calculated: Boolean)
    begin
    end;
}
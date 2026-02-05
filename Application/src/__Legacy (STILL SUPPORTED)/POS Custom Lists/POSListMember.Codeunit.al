codeunit 6184970 "NPR POS List: Member" implements "NPR POS Custom List IHandler"
{
    Access = Internal;

    procedure GetTableNo(): Integer
    begin
        exit(Database::"NPR MM Member");
    end;

    procedure GetColumns() Columns: JsonArray
    var
        Field: Record Field;
        Member: Record "NPR MM Member";
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
    begin
        Field.Get(Database::"NPR MM Member", Member.FieldNo("External Member No."));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR MM Member", Member.FieldNo("First Name"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR MM Member", Member.FieldNo("Last Name"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR MM Member", Member.FieldNo("E-Mail Address"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR MM Member", Member.FieldNo("Phone No."));
        POSCustomListHelper.AddColumn(Field, Columns);
    end;

    procedure GetSorting() SortingParams: JsonObject
    begin
        SortingParams.ReadFrom('{}');
    end;

    procedure GetMandatoryFilters() ColumnFilters: JsonArray
    begin
        ColumnFilters.ReadFrom('[]');
    end;

    procedure CalculateColumnValue(RecRef: RecordRef; FieldID: Text; var CalculatedValue: Variant): Boolean
    begin
    end;
}
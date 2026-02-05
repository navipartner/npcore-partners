codeunit 6184971 "NPR POS List: Ticket" implements "NPR POS Custom List IHandler"
{
    Access = Internal;

    procedure GetTableNo(): Integer
    begin
        exit(Database::"NPR TM Ticket");
    end;

    procedure GetColumns() Columns: JsonArray
    var
        Field: Record Field;
        Ticket: Record "NPR TM Ticket";
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
    begin
        Field.Get(Database::"NPR TM Ticket", Ticket.FieldNo("External Ticket No."));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR TM Ticket", Ticket.FieldNo("Ticket Type Code"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR TM Ticket", Ticket.FieldNo("Valid From Date"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR TM Ticket", Ticket.FieldNo("Valid From Time"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR TM Ticket", Ticket.FieldNo("Valid To Date"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR TM Ticket", Ticket.FieldNo("Valid To Time"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR TM Ticket", Ticket.FieldNo(Blocked));
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
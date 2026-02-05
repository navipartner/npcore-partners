codeunit 6184969 "NPR POS List: Customer" implements "NPR POS Custom List IHandler"
{
    Access = Internal;

    procedure GetTableNo(): Integer
    begin
        exit(Database::Customer);
    end;

    procedure GetColumns() Columns: JsonArray
    var
        Field: Record Field;
        Customer: Record Customer;
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
    begin
        Field.Get(Database::Customer, Customer.FieldNo("No."));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::Customer, Customer.FieldNo(Name));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::Customer, Customer.FieldNo(Contact));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::Customer, Customer.FieldNo("E-Mail"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::Customer, Customer.FieldNo("Phone No."));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::Customer, Customer.FieldNo("Balance (LCY)"));
        POSCustomListHelper.AddColumn(Field, Columns);
    end;

    procedure GetSorting() SortingParams: JsonObject
    begin
        SortingParams.ReadFrom('{}');
    end;

    procedure GetMandatoryFilters() ColumnFilters: JsonArray
    var
        Field: Record Field;
        Customer: Record Customer;
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
    begin
        Field.Get(Database::Customer, Customer.FieldNo(Blocked));
        POSCustomListHelper.AddMandatoryFilter(Field, StrSubstNo('<>%1', Customer.Blocked::All), ColumnFilters);
    end;

    procedure CalculateColumnValue(RecRef: RecordRef; FieldID: Text; var CalculatedValue: Variant): Boolean
    begin
    end;
}
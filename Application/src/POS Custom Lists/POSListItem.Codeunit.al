codeunit 6184967 "NPR POS List: Item" implements "NPR POS Custom List IHandler"
{
    Access = Internal;

    var
        SubstitutesExistFldID: Label 'SUBSTEXIST', Locked = true;

    procedure GetTableNo(): Integer
    begin
        exit(Database::Item);
    end;

    procedure GetColumns() Columns: JsonArray
    var
        Field: Record Field;
        Item: Record Item;
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
        SubstitutesExistColumnCaption: Label 'Substituts Exist';
    begin
        Field.Get(Database::Item, Item.FieldNo("No."));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::Item, Item.FieldNo(Description));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::Item, Item.FieldNo(GTIN));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::Item, Item.FieldNo("Item Category Code"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::Item, Item.FieldNo("NPR Item Status"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::Item, Item.FieldNo(Inventory));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::Item, Item.FieldNo("Reordering Policy"));
        POSCustomListHelper.AddColumn(Field, Columns);

        POSCustomListHelper.AddColumn(SubstitutesExistFldID, SubstitutesExistColumnCaption, 'Boolean', 'Linked', Columns);
    end;

    procedure GetSorting() SortingParams: JsonObject
    begin
        SortingParams.ReadFrom('{}');
    end;

    procedure GetMandatoryFilters() ColumnFilters: JsonArray
    var
        Field: Record Field;
        Item: Record Item;
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
    begin
        Field.Get(Database::Item, Item.FieldNo(Blocked));
        POSCustomListHelper.AddMandatoryFilter(Field, Format(false, 9), ColumnFilters);
    end;

    procedure CalculateColumnValue(RecRef: RecordRef; FieldID: Text; var CalculatedValue: Variant): Boolean
    var
        ItemSubstitution: Record "Item Substitution";
    begin
        if FieldID <> SubstitutesExistFldID then
            exit(false);
        if RecRef.Number() <> Database::Item then
            exit(false);
        ItemSubstitution.SetRange("No.", RecRef.Field(1).Value());
        ItemSubstitution.SetRange(Type, ItemSubstitution.Type::Item);
        CalculatedValue := not ItemSubstitution.IsEmpty();
        exit(true);
    end;
}
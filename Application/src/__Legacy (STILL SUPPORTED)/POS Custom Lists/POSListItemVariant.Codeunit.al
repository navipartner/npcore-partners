codeunit 6184968 "NPR POS List: Item Variant" implements "NPR POS Custom List IHandler"
{
    Access = Internal;

    var
        InventoryFldID: Label 'INVENTORY', Locked = true;

    procedure GetTableNo(): Integer
    begin
        exit(Database::"Item Variant");
    end;

    procedure GetColumns() Columns: JsonArray
    var
        Field: Record Field;
        ItemVariant: Record "Item Variant";
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
        InventoryColumnCaption: Label 'Inventory';
    begin
        Field.Get(Database::"Item Variant", ItemVariant.FieldNo(Code));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"Item Variant", ItemVariant.FieldNo(Description));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"Item Variant", ItemVariant.FieldNo("Description 2"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"Item Variant", ItemVariant.FieldNo("NPR Variety 1 Value"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"Item Variant", ItemVariant.FieldNo("NPR Variety 2 Value"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"Item Variant", ItemVariant.FieldNo("NPR Variety 3 Value"));
        POSCustomListHelper.AddColumn(Field, Columns);

        POSCustomListHelper.AddColumn(InventoryFldID, InventoryColumnCaption, 'Decimal', 'Linked', Columns);
    end;

    procedure GetSorting() SortingParams: JsonObject
    begin
        SortingParams.ReadFrom('{}');
    end;

    procedure GetMandatoryFilters() ColumnFilters: JsonArray
    var
        Field: Record Field;
        ItemVariant: Record "Item Variant";
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
    begin
#if BC17 or BC18 or BC19 or BC20 or BC21 or BC22
        Field.Get(Database::"Item Variant", ItemVariant.FieldNo("NPR Blocked"));
#else
        Field.Get(Database::"Item Variant", ItemVariant.FieldNo(Blocked));
#endif
        POSCustomListHelper.AddMandatoryFilter(Field, Format(false, 9), ColumnFilters);
    end;

    procedure CalculateColumnValue(RecRef: RecordRef; FieldID: Text; var CalculatedValue: Variant): Boolean
    var
        Item: Record Item;
    begin
        if FieldID <> InventoryFldID then
            exit(false);
        if RecRef.Number() <> Database::"Item Variant" then
            exit(false);
        if not Item.Get(Format(RecRef.Field(2).Value())) then
            exit(false);
        Item.SetRange("Variant Filter", RecRef.Field(1).Value());
        Item.CalcFields(Inventory);
        CalculatedValue := Item.Inventory;
        exit(true);
    end;
}
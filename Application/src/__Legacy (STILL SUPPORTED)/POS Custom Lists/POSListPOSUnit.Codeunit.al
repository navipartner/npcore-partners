codeunit 6150876 "NPR POS List: POS Unit" implements "NPR POS Custom List IHandler"
{
    Access = Internal;

    procedure GetTableNo(): Integer
    begin
        exit(Database::"NPR POS Unit");
    end;

    procedure GetColumns() Columns: JsonArray
    var
        Field: Record Field;
        POSUnit: Record "NPR POS Unit";
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
    begin
        Field.Get(Database::"NPR POS Unit", POSUnit.FieldNo("No."));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR POS Unit", POSUnit.FieldNo(Name));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR POS Unit", POSUnit.FieldNo(Status));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR POS Unit", POSUnit.FieldNo("POS Store Code"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR POS Unit", POSUnit.FieldNo("POS Type"));
        POSCustomListHelper.AddColumn(Field, Columns);

        Field.Get(Database::"NPR POS Unit", POSUnit.FieldNo("Default POS Payment Bin"));
        POSCustomListHelper.AddColumn(Field, Columns);
    end;

    procedure GetSorting() SortingParams: JsonObject
    begin
        SortingParams.ReadFrom('{}');
    end;

    procedure GetMandatoryFilters() ColumnFilters: JsonArray
    var
        Field: Record Field;
        POSUnit: Record "NPR POS Unit";
        POSCustomListHelper: Codeunit "NPR POS Custom List Helper";
        UserSetup: Record "User Setup";
        CurrentPOSUnitNo: Code[10];
    begin
        CurrentPOSUnitNo := POSUnit.GetCurrentPOSUnit();

        if CurrentPOSUnitNo <> '' then begin
            Field.Get(Database::"NPR POS Unit", POSUnit.FieldNo("No."));
            POSCustomListHelper.AddMandatoryFilter(
                Field,
                '<>' + CurrentPOSUnitNo,
                ColumnFilters
            );
        end;

        if UserSetup.Get(UserId) then begin
            if UserSetup."NPR Register Switch Filter" <> '' then begin
                Field.Get(Database::"NPR POS Unit", POSUnit.FieldNo("No."));
                POSCustomListHelper.AddMandatoryFilter(
                    Field,
                    UserSetup."NPR Register Switch Filter",
                    ColumnFilters
                );
            end;
        end;
    end;

    procedure CalculateColumnValue(RecRef: RecordRef; FieldID: Text; var CalculatedValue: Variant): Boolean
    begin
    end;
}
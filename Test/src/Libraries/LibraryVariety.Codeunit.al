codeunit 85098 "NPR Library - Variety"
{
    procedure CreateVariety(VarietyCode: Text; var Variety: Record "NPR Variety")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        if VarietyCode = '' then
            VarietyCode := LibraryUtility.GenerateRandomCode(Variety.FieldNo(Code), Database::"NPR Variety");
        if not Variety.Get(VarietyCode) then begin
            Variety.Init();
            Variety.Validate(Code, VarietyCode);
            Variety.Description := VarietyCode;
            Variety.Insert(true);
        end;
    end;

    procedure CreateVarietyTable(VarietyCode: Text; VarietyTableCode: Text; var VarietyTable: Record "NPR Variety Table")
    var
        Variety: Record "NPR Variety";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        CreateVariety(VarietyCode, Variety);
        if VarietyTableCode = '' then
            VarietyTableCode := LibraryUtility.GenerateGuid();
        if not VarietyTable.Get(Variety.Code, VarietyTableCode) then begin
            VarietyTable.Init();
            VarietyTable.Validate(Type, Variety.Code);
            VarietyTable.Validate(Code, VarietyTableCode);
            VarietyTable.Description := VarietyTableCode;
            VarietyTable.Insert(true);
        end;
    end;

    procedure CreateVarietyValue(VarietyCode: Text; VarietyTableCode: Text; VarietyValueCode: Text; var VarietyValue: Record "NPR Variety Value")
    var
        VarietyTable: Record "NPR Variety Table";
        LibraryUtility: Codeunit "Library - Utility";
    begin
        CreateVarietyTable(VarietyCode, VarietyTableCode, VarietyTable);
        if VarietyValueCode = '' then
            VarietyValueCode := LibraryUtility.GenerateGuid();
        if not VarietyValue.Get(VarietyTable.Type, VarietyTable.Code, VarietyValueCode) then begin
            VarietyValue.Init();
            VarietyValue.Validate(Type, VarietyTable.Type);
            VarietyValue.Validate(Table, VarietyTable.Code);
            VarietyValue.Validate(Value, VarietyValueCode);
            VarietyValue.Insert(true);
        end;
    end;

    procedure AddVarietyToItem(VarietyValue: Record "NPR Variety Value"; VarietySet: Integer; var Item: Record Item)
    var
        VarietyTable: Record "NPR Variety Table";
    begin
        VarietyTable.Get(VarietyValue.Type, VarietyValue.Table);
        AddVarietyToItem(VarietyTable, VarietySet, Item);
    end;

    procedure AddVarietyToItem(VarietyTable: Record "NPR Variety Table"; VarietySet: Integer; var Item: Record Item)
    begin
        case VarietySet of
            1:
                begin
                    Item.Validate("NPR Variety 1", VarietyTable.Type);
                    Item.Validate("NPR Variety 1 Table", VarietyTable.Code);
                end;
            2:
                begin
                    Item.Validate("NPR Variety 2", VarietyTable.Type);
                    Item.Validate("NPR Variety 2 Table", VarietyTable.Code);
                end;
            3:
                begin
                    Item.Validate("NPR Variety 3", VarietyTable.Type);
                    Item.Validate("NPR Variety 3 Table", VarietyTable.Code);
                end;
            4:
                begin
                    Item.Validate("NPR Variety 4", VarietyTable.Type);
                    Item.Validate("NPR Variety 4 Table", VarietyTable.Code);
                end;
        end;
    end;

    procedure AddVarietyToItemVariant(VarietyValue: Record "NPR Variety Value"; VarietySet: Integer; var ItemVariant: Record "Item Variant")
    begin
        case VarietySet of
            1:
                begin
                    ItemVariant.Validate("NPR Variety 1", VarietyValue.Type);
                    ItemVariant.Validate("NPR Variety 1 Table", VarietyValue.Table);
                    ItemVariant.Validate("NPR Variety 1 Value", VarietyValue.Value);
                end;
            2:
                begin
                    ItemVariant.Validate("NPR Variety 2", VarietyValue.Type);
                    ItemVariant.Validate("NPR Variety 2 Table", VarietyValue.Table);
                    ItemVariant.Validate("NPR Variety 2 Value", VarietyValue.Value);
                end;
            3:
                begin
                    ItemVariant.Validate("NPR Variety 3", VarietyValue.Type);
                    ItemVariant.Validate("NPR Variety 3 Table", VarietyValue.Table);
                    ItemVariant.Validate("NPR Variety 3 Value", VarietyValue.Value);
                end;
            4:
                begin
                    ItemVariant.Validate("NPR Variety 4", VarietyValue.Type);
                    ItemVariant.Validate("NPR Variety 4 Table", VarietyValue.Table);
                    ItemVariant.Validate("NPR Variety 4 Value", VarietyValue.Value);
                end;
        end;
    end;

    procedure CreateVarietySetsAndAddToItem(VarietySets: Integer; var Item: Record Item)
    var
        MaxVarietySet: Integer;
        i: Integer;
        VarietyTable: Record "NPR Variety Table";
        LibraryRandom: Codeunit "Library - Random";
    begin
        MaxVarietySet := 4;
        if VarietySets = 0 then
            VarietySets := LibraryRandom.RandInt(MaxVarietySet);

        for i := 1 to VarietySets do begin
            CreateVarietyTable('', '', VarietyTable);
            AddVarietyToItem(VarietyTable, i, Item);
        end;
        Item.Modify(true);
    end;

    procedure CreateVarietyValuesAndAddToItemVariant(var ItemVariant: Record "Item Variant")
    var
        VarietyValue: Record "NPR Variety Value";
        Item: Record Item;
    begin
        Item.Get(ItemVariant."Item No.");
        if (Item."NPR Variety 1" <> '') and (Item."NPR Variety 1 Table" <> '') then begin
            CreateVarietyValue(Item."NPR Variety 1", Item."NPR Variety 1 Table", '', VarietyValue);
            AddVarietyToItemVariant(VarietyValue, 1, ItemVariant);
        end;
        if (Item."NPR Variety 2" <> '') and (Item."NPR Variety 2 Table" <> '') then begin
            CreateVarietyValue(Item."NPR Variety 2", Item."NPR Variety 2 Table", '', VarietyValue);
            AddVarietyToItemVariant(VarietyValue, 2, ItemVariant);
        end;
        if (Item."NPR Variety 3" <> '') and (Item."NPR Variety 3 Table" <> '') then begin
            CreateVarietyValue(Item."NPR Variety 3", Item."NPR Variety 3 Table", '', VarietyValue);
            AddVarietyToItemVariant(VarietyValue, 3, ItemVariant);
        end;
        if (Item."NPR Variety 4" <> '') and (Item."NPR Variety 4 Table" <> '') then begin
            CreateVarietyValue(Item."NPR Variety 4", Item."NPR Variety 4 Table", '', VarietyValue);
            AddVarietyToItemVariant(VarietyValue, 4, ItemVariant);
        end;
        ItemVariant.Modify(true);
    end;
}
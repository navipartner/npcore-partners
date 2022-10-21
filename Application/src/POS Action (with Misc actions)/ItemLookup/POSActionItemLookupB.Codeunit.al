codeunit 6059871 "NPR POS Action: Item Lookup B"
{
    Access = Internal;

    internal procedure LookupItem(POSSaleLine: Codeunit "NPR POS Sale Line"; Setup: Codeunit "NPR POS Setup"; ItemView: Text; LocationFilterOption: Integer) ItemNo: Code[20]
    var
        Item: Record Item;
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        if ItemView <> '' then
            Item.SetView(ItemView);

        case LocationFilterOption of
            -1, 0:
                Item.SetRange("Location Filter", GetStoreLocation(Setup));
            1:
                Item.SetRange("Location Filter", GetStoreLocationFromUnit(Setup));
        end;

        Item.SetRange(Blocked, false);

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if SaleLinePOS."Line Type" = SaleLinePOS."Line Type"::Item then
            if Item.Get(SaleLinePOS."No.") then;

        if Page.RunModal(Page::"Item List", Item) = Action::LookupOK then
            ItemNo := Item."No.";
    end;

    internal procedure LookupSKU(POSSetup: Codeunit "NPR POS Setup"; SKUView: Text; LocationFilterOption: Integer) ItemNo: Code[20]
    var
        StockkeepingUnitList: Page "Stockkeeping Unit List";
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        if SKUView <> '' then
            StockkeepingUnit.SetView(SKUView);

        case LocationFilterOption of
            -1, 0:
                StockkeepingUnit.SetRange("Location Code", GetStoreLocation(POSSetup));
            1:
                StockkeepingUnit.SetRange("Location Code", GetStoreLocationFromUnit(POSSetup));
        end;

        StockkeepingUnitList.Editable(false);
        StockkeepingUnitList.LookupMode(true);
        StockkeepingUnitList.SetTableView(StockkeepingUnit);
        if StockkeepingUnitList.RunModal() = Action::LookupOK then begin
            StockkeepingUnitList.GetRecord(StockkeepingUnit);
            ItemNo := StockkeepingUnit."Item No.";
        end;
    end;

    local procedure GetStoreLocation(POSSetup: Codeunit "NPR POS Setup"): Code[10]
    var
        POSStore: Record "NPR POS Store";
    begin
        POSSetup.GetPOSStore(POSStore);
        exit(POSStore."Location Code");
    end;

    local procedure GetStoreLocationFromUnit(POSSetup: Codeunit "NPR POS Setup"): Code[10]
    var
        POSStore: Record "NPR POS Store";
        POSUnit: Record "NPR POS Unit";
    begin
        POSSetup.GetPOSUnit(POSUnit);
        POSStore.Get(POSUnit."POS Store Code");
        exit(POSStore."Location Code");
    end;
}


codeunit 6151352 "NPR POS Action: Change UOM-B"
{
    Access = Internal;
    internal procedure SetUoM(DefaultUOM: Code[10]; SaleLine: Codeunit "NPR POS Sale Line")
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemUnitsofMeasure: Page "Item Units of Measure";
    begin
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        if DefaultUOM = '' then begin
            ItemUnitofMeasure.SetRange("Item No.", SaleLinePOS."No.");
            ItemUnitofMeasure.SetRange("NPR Block on POS Sale", false);
            ItemUnitsofMeasure.Editable(false);
            ItemUnitsofMeasure.LookupMode(true);
            ItemUnitsofMeasure.SetTableView(ItemUnitofMeasure);
            if ItemUnitsofMeasure.RunModal() <> Action::LookupOK then
                exit;
            ItemUnitsofMeasure.GetRecord(ItemUnitofMeasure);
        end else
            ItemUnitofMeasure.Get(SaleLinePOS."No.", DefaultUOM);

        if SaleLinePOS."Unit of Measure Code" = ItemUnitofMeasure.Code then
            exit;

        SaleLine.SetUoM(ItemUnitofMeasure.Code);
    end;
}

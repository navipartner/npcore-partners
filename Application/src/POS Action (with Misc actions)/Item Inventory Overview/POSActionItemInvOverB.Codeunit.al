codeunit 6059953 "NPR POS Action:ItemInv Over-B"
{
    Access = Internal;
    procedure OpenItemInventoryOverviewPage(SalePOS: Record "NPR POS Sale"; SalesLinePOS: Record "NPR POS Sale Line"; AllItems: Boolean; OnlyCurrentLocation: Boolean)
    var
        POSInventoryOverview: Page "NPR POS Inventory Overview";
        ItemsByLocationOverview: Page "NPR Items by Location Overview";
    begin
        if AllItems then begin
            Clear(ItemsByLocationOverview);
            if OnlyCurrentLocation then
                ItemsByLocationOverview.SetFilters(SalePOS."Location Code");
            ItemsByLocationOverview.Run();
            exit;
        end;

        POSInventoryOverview.SetParameters('', '', SalePOS."Location Code", OnlyCurrentLocation);
        if SalesLinePOS."Line Type" = SalesLinePOS."Line Type"::Item then
            POSInventoryOverview.SetParameters(SalesLinePOS."No.", SalesLinePOS."Variant Code", SalesLinePOS."Location Code", OnlyCurrentLocation);
        POSInventoryOverview.Run();
    end;
}
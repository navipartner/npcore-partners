codeunit 6150692 "NPR Sales Price Maint. Mgt."
{
    Access = Public;

    [IntegrationEvent(false, false)]
    procedure OnBeforeUpdateSalesPricesForStaff(var Item: Record Item; var Handled: Boolean)
    begin
    end;

    procedure CheckExcludeItemGroup(SalesPriceMaintenanceSetupId: Integer; ItemCategoryCode: Code[20]) Excluded: Boolean
    var
        SalesPriceMaintenanceGroups: Record "NPR Sales Price Maint. Groups2";
        SalesPriceMaintEvent: Codeunit "NPR Sales Price Maint. Event";
    begin
        Clear(SalesPriceMaintenanceGroups);
        SalesPriceMaintenanceGroups.SetRange(Id, SalesPriceMaintenanceSetupId);
        if SalesPriceMaintenanceGroups.FindSet() then begin
            repeat
                Excluded := SalesPriceMaintEvent.ExcludeItemGroup(ItemCategoryCode, SalesPriceMaintenanceGroups."Item Category Code");
            until (SalesPriceMaintenanceGroups.Next() = 0) or Excluded;
        end;
    end;
}
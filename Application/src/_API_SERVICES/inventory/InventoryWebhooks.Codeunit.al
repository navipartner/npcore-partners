#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
codeunit 6184702 "NPR Inventory Webhooks"
{
    Access = Internal;

    internal procedure RaiseItemsChanged()
    begin
        OnItemsChanged();
    end;

    [ExternalBusinessEvent('inventory_itemsChanged', 'Inventory Items Changed', 'Signal to re-sync items. Raised after items in the company changed, and once when the job first runs. Carries no data: run the item delta sync from your last rowVersion. One event can cover many changes, and an event can repeat or bring nothing new.', EventCategory::"NPR Inventory", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR Inventory Webhooks", 'X')]
    local procedure OnItemsChanged()
    begin
    end;
}
#endif

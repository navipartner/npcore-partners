#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6150997 "NPR Entria Integr. Webhooks"
{
    Access = Internal;

    [ExternalBusinessEvent('entria_itemUnitPriceChanged', 'Entria Item Unit Price Changed', 'Triggered when the Unit Price of an Entria Item changes', EventCategory::"NPR Inventory", '1.0')]
    procedure OnItemUnitPriceChanged(itemId: Guid; itemNo: Code[20]; newUnitPrice: Decimal)
    begin
    end;
}
#endif

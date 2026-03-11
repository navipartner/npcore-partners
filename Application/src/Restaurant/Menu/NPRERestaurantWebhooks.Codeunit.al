#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248636 "NPR NPRE Restaurant Webhooks"
{
    Access = Internal;

    procedure InvokeOrderReadyForServingWebhook(SystemId: Guid)
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
        KitchenOrder.GetBySystemId(SystemId);
#pragma warning disable AA0139
        OnOrderReadyForServing(Format(KitchenOrder."Order ID"), Format(SystemId, 0, 4).ToLower());
#pragma warning restore AA0139
        OnAfterOrderReadyForServingWebhook(KitchenOrder."Order ID");
#endif
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterOrderReadyForServingWebhook(KitchenOrderId: BigInteger)
    begin
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
    [ExternalBusinessEvent('restaurant_order_ready_for_serving', 'Restaurant Order Ready for Serving', 'Triggered when a kitchen order is marked as ready for serving', EventCategory::"NPR Restaurant", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR NPRE Restaurant Webhooks", 'X')]
    local procedure OnOrderReadyForServing(kitchenOrderNo: Text[250]; kitchenOrderId: Text[50])
    begin
    end;
#endif
}
#endif

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
codeunit 6151030 "NPR CMOrderWebhooks"
{
    Access = Internal;

    internal procedure SendOrderCompletionHook(OrderId: Guid)
    var
        Order: Record "NPR CMOrder";
        OrderAgent: Codeunit "NPR ChannelMgrOrderAgent";
    begin
        Order.SetLoadFields(OrderId, DocumentNo, Status);
        if (not Order.Get(OrderId)) then
            exit;

        OnOrderProcessed(
            CopyStr(Format(Order.OrderId, 0, 4).ToLower(), 1, 50),
            Order.DocumentNo,
            OrderAgent.GetStatusAsText(Order.Status));
    end;

    [ExternalBusinessEvent('ota_cm_order_processed', 'OTA Channel Manager Order Processed', 'Triggered when the JQ runner has settled an async-submitted order to a terminal state (Issued, Draft, or Error).', EventCategory::"NPR OTA Channel Manager", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR CMOrderWebhooks", 'X')]
    local procedure OnOrderProcessed(orderId: Text[50]; buyFromOrderReference: Text[50]; status: Text[50])
    begin
    end;
}
#endif

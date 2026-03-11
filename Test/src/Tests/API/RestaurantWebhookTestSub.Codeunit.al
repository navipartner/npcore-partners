#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22 and not BC23 and not BC24
codeunit 85158 "NPR Restaurant Webhook TestSub"
{
    EventSubscriberInstance = Manual;

    var
        _WebhookInvoked: Boolean;
        _LastKitchenOrderId: BigInteger;

    procedure Reset()
    begin
        _WebhookInvoked := false;
        _LastKitchenOrderId := 0;
    end;

    procedure WasWebhookInvoked(): Boolean
    begin
        exit(_WebhookInvoked);
    end;

    procedure GetLastKitchenOrderId(): BigInteger
    begin
        exit(_LastKitchenOrderId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NPRE Restaurant Webhooks", OnAfterOrderReadyForServingWebhook, '', false, false)]
    local procedure OnAfterOrderReadyForServingWebhook(KitchenOrderId: BigInteger)
    begin
        _WebhookInvoked := true;
        _LastKitchenOrderId := KitchenOrderId;
    end;
}
#endif

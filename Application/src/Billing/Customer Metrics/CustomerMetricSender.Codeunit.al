codeunit 6151259 "NPR Customer Metric Sender" implements "NPR ICustomer Metric Sender"
{
    Access = Internal;

    procedure RegisterEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; Quantity: Decimal; Metadata: JsonObject)
    var
        EventBillingClient: Codeunit "NPR Event Billing Client";
    begin
        EventBillingClient.RegisterEvent(EventId, EventType, Quantity, Metadata.AsToken());
    end;
}

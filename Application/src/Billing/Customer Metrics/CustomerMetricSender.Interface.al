interface "NPR ICustomer Metric Sender"
{
    Access = Internal;

    procedure RegisterEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; Quantity: Decimal; Metadata: JsonObject)
}

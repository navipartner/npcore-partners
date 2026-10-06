interface "NPR ICustomer Metric"
{
    Access = Internal;

    procedure GetEventType(): Enum "NPR Billing Event Type"

    /// <summary>
    /// The framework adds the 'business_date' metadata key.
    /// </summary>
    procedure Calculate(BusinessDate: Date; var Metadata: JsonObject): Decimal
}

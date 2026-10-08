interface "NPR ICustomer Metric"
{
    Access = Internal;

    procedure GetEventType(): Enum "NPR Billing Event Type"

    /// <summary>
    /// A delta covers everything since its previous event, so the framework does not catch up on missed business dates for it.
    /// </summary>
    procedure IsDelta(): Boolean

    /// <summary>
    /// MetricSync is the row the framework stores for the metric and business date after the calculation, so a delta metric keeps its position in it.
    /// The framework adds the 'business_date' metadata key.
    /// </summary>
    procedure Calculate(var MetricSync: Record "NPR Customer Metric Sync"; var Metadata: JsonObject): Decimal
}

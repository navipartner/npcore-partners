interface "NPR ICustomer Date Metric" extends "NPR ICustomer Metric"
{
    Access = Internal;

    /// <summary>
    /// MetricSync is the row the framework stores for the metric and business date after the calculation, so a delta metric keeps its position in it.
    /// The framework sends the value under the row's SystemId and adds the 'business_date' metadata key.
    /// </summary>
    procedure Calculate(var MetricSync: Record "NPR Customer Metric Sync"; var Metadata: JsonObject): Decimal
}

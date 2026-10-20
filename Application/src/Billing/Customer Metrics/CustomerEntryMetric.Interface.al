interface "NPR ICustomer Entry Metric" extends "NPR ICustomer Metric"
{
    Access = Internal;

    /// <summary>
    /// Registers one event per source entry under the entry's SystemId, so an entry that a later run finds again is not queued twice.
    /// Each event carries the 'business_date' of its entry. The framework stores MetricSync after the call, so the metric keeps its position in it.
    /// </summary>
    procedure RegisterEvents(var MetricSync: Record "NPR Customer Metric Sync"; Sender: Interface "NPR ICustomer Metric Sender")
}

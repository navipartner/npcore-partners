/// <summary>
/// A customer metric is a date metric, which sends one value per business date, or an entry metric, which sends one event per source entry.
/// </summary>
interface "NPR ICustomer Metric"
{
    Access = Internal;

    procedure GetEventType(): Enum "NPR Billing Event Type"

    /// <summary>
    /// A delta covers everything since its previous run, so the framework does not catch up on missed business dates for it.
    /// </summary>
    procedure IsDelta(): Boolean
}

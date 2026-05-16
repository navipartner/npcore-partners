#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
interface "NPR IRetention Policy V2" extends "NPR IRetention Policy"
{
    /// <summary>
    /// Returns the implementation-defined default DateFormula for the given period type.
    /// </summary>
    /// <param name="PeriodType">Identifies which retention period's value to return.</param>
    /// <returns>The default DateFormula for the period type.</returns>
    procedure GetDefaultRetentionPeriod(PeriodType: enum "NPR Retention Period Type"): DateFormula

    /// <summary>
    /// Shows the period setup for the retention policy.
    /// </summary>
    /// <param name="RetentionPolicy">Identifies which retention policy's setup to show.</param>
    /// <param name="PolicyEditable">Determines whether the user can edit the periods of this retention policy.</param>
    procedure ShowSetup(RetentionPolicy: Record "NPR Retention Policy"; PolicyEditable: Boolean)
}
#endif
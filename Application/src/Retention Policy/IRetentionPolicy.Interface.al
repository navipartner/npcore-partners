#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
interface "NPR IRetention Policy"
{
    Access = Internal;

    /// <summary>
    /// Deletes records with a datetime older than specified threshold.
    /// </summary>
    procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy")
}
#endif
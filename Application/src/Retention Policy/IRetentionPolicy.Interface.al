#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
interface "NPR IRetention Policy"
{
    Access = Internal;

    /// <summary>
    /// Deletes all records in a table older than the threshold specified by its respective implementation.
    /// </summary>
    /// <param name="RetentionPolicy">Identifies the retention policy record, which specifies the table and its respective implementation.</param>
    /// <param name="ReferenceDateTime">Specifies the reference DateTime from which the retention period is calculated.</param>
    procedure DeleteExpiredRecords(RetentionPolicy: Record "NPR Retention Policy"; ReferenceDateTime: DateTime)
}
#endif
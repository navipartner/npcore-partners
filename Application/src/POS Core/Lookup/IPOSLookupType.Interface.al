/// <summary>
/// Represents a lookup type.
/// </summary>
interface "NPR IPOSLookupType"
{
    /// <summary>
    /// Initializes the data read operation for the lookup. It should open a RecordRef over the source table, and it should
    /// set any necessary filters so that the lookup infrastructure can iterate over the correct data.
    /// </summary>
    /// <param name="RecRef">RecordRef to contain the filtered source table</param>
    procedure InitializeDataRead(var RecRef: RecordRef);

    /// <summary>
    /// Converts a single row from the lookup source table into a JsonObject to be included in the resulting front-end data set.
    /// </summary>
    /// <param name="RecRef">RecordRef containing the current row of data to convert to JsonObject</param>
    /// <returns></returns>
    procedure GetLookupEntry(RecRef: RecordRef): JsonObject;

    procedure IsMatchForSearch(RecRef: RecordRef; SearchFilter: Text): Boolean;
}

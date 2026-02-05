interface "NPR POS Custom List IHandler"
{
    /// <summary>
    /// Returns the table number the list will be based on.
    /// </summary>
    /// <returns>The table number as integer</returns>
    procedure GetTableNo(): Integer

    /// <summary>
    /// Returns the columns to display in the list.
    /// The return value must be a json array, consisting of json objects representing each column with the following key/value pairs:
    ///   "fieldId" - an alphanumeric value representing the field id. If this is a field from the table, on which the list is based, use the field number.
    ///   "caption" - an alphanumeric value representing the field caption.
    ///   "type" - an alphanumeric value representing the type of the field.
    ///   "class" - an alphanumeric value representing the class of the field. If this is a field from the table on which the list is based and the field is of type "Code", "Text", "GUID", "Integer", "BigInteger", "Boolean", "Date", "Time", "DateTime", then the class can be either "Normal" or "FlowField". Otherwise, the class must be set to the value "Linked".
    /// </summary>
    /// <returns>A set of colums as json array</returns>
    procedure GetColumns(): JsonArray

    /// <summary>
    /// Returns the sorting parameters to apply to the list.
    /// The return value must be a json object with the following key/value pairs:
    ///   "orderByFieldId" - an integer value representing the field number. Must be a field from the table, on which the list is based. The field must be included in the list as a separate column, and must be of class "Normal". This is the field by which the records in the list will be ordered.
    ///   "descending" - true or false. Whether you want the sort order to be ascending or descending.
    /// If you don't want to apply any particular sorting, just return an empty json object.
    /// </summary>
    /// <returns>The soring parameters as json object</returns>
    procedure GetSorting(): JsonObject

    /// <summary>
    /// Returns the mandatory filters to apply to the list before sending data to the frontend.
    /// The return value must be a json array, consisting of json objects representing each filter with the following key/value pairs:
    ///   "fieldId" - an integer value representing the field number. Must be a field from the table, on which the list is based.
    ///   "filterString" - a text value representing the filter string.
    /// </summary>
    /// <returns>A set of mandatory filters as json array</returns>
    procedure GetMandatoryFilters(): JsonArray

    /// <summary>
    /// Calculates a value for a column (cell) included in the list. Can be used when you need an alternative way of calculating the value.
    /// </summary>
    /// <param name="RecRef">The record for which to calculate the value</param>
    /// <param name="FieldID">The field (column) ID for which the value is to be calculated</param>
    /// <param name="CalculatedValue">The calculated value</param>
    /// <returns>Returns whether the value was calculated. If the function returns 'false', the system will fall back to the default calculation routine.</returns>
    procedure CalculateColumnValue(RecRef: RecordRef; FieldID: Text; var CalculatedValue: Variant): Boolean
}
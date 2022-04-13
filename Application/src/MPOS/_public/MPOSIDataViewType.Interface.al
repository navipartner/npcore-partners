interface "NPR MPOS IDataViewType"
{
    procedure LookupCode(var Text: Text): Boolean;
    procedure IsActive(DataViewCode: Code[20]): Boolean;
    procedure ProcessView(DataViewCode: Code[20]; Request: JsonToken): JsonToken;
    procedure GetViews(): JsonToken
}
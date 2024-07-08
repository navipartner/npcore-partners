interface "NPR MPOS IDataViewCategory"
{
    procedure Preveiw(SystemId: Guid);
    procedure GetViews(DataViewType: Enum "NPR MPOS Data View Type"; DataViewCategory: Enum "NPR MPOS Data View Category"): JsonToken
    procedure GetView(DataViewType: Enum "NPR MPOS Data View Type"; DataViewCategory: Enum "NPR MPOS Data View Category"; DataViewCode: Code[20]; Request: JsonToken): JsonToken
}
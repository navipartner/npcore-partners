#if not (BC17 or BC18 or BC19 or BC20 or BC21)
interface "NPR IDynamicTemplateDataProvider"
{
    procedure GetContent(RecRef: RecordRef): JsonObject
    procedure GenerateContentExample(): JsonObject
    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
}
#endif
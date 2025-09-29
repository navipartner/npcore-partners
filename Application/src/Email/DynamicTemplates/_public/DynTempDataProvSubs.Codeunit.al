codeunit 6248568 "NPR DynTempDataProvSubs"
{
    [IntegrationEvent(false, false)]
    procedure OnAfterMemberGetContent(var MemberNotificationEntryBuffer: Record "NPR MMMemberNotificEntryBuf"; var CustomJObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterMemberGenerateContentExample(var CustomJObject: JsonObject)
    begin
    end;
}
codeunit 6184774 "NPR Log Session Metadata"
{
    Access = Internal;

#if BC17 or BC18 or BC19
    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnAfterLogInStart', '', false, false)]
    local procedure OnAfterLogin()
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    local procedure LogUserMetadataOnAfterLogin()
#endif
    var
        SessionMetadata: Dictionary of [Text, Text];
    begin
        if not GuiAllowed then
            exit; //We are only interested in enriching metadata for human sessions. For non-human sessions it is enough to know client type i.e. API or Background.

        SessionMetadata.Add('SessionId', Format(SessionId()));
        SessionMetadata.Add('UserId', Format(UserId));
        SessionMetadata.Add('ServiceInstanceId', Format(ServiceInstanceId()));
        Session.LogMessage('NPR_UserLogin', 'User logged in', Verbosity::Normal, DataClassification::SystemMetadata, Telemetryscope::ExtensionPublisher, SessionMetadata);
    end;
}
codeunit 6248583 "NPR MemberImageMigrateToCFErr"
{
    Access = Internal;
    trigger OnRun()
    begin
        LogMessage();
    end;

    local procedure LogMessage()
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
        ResponseMessage: Text;
    begin
        ResponseMessage := StrSubstNo('[Member Media] %1', GetLastErrorText());

        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            ActiveSession.Init();

        CustomDimensions.Add('NPR_FunctionName', 'MigrateMemberImage (status)');
        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_SessionId', Format(Database.SessionId(), 0, 9));
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");

        Session.LogMessage('NPR_MemberMediaMigration', ResponseMessage, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

}
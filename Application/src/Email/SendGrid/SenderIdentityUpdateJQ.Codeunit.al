#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248273 "NPR Sender Identity Update JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Feature: Codeunit "NPR NP Email Feature";
        NPEmailAccount: Record "NPR NP Email Account";
        Client: Codeunit "NPR SendGrid Client";
    begin
        // Use feature and the setup to figure out if the module is enabled
        if (not Feature.IsFeatureEnabled()) or (NPEmailAccount.IsEmpty()) then
            exit;

        Client.UpdateLocalSenderIdentities();
    end;
}
#endif
codeunit 6059944 "NPR Invoke CaseSystem Login"
{
    Access = Internal;

    trigger OnRun()
    var
        ServiceTierUserMgt: Codeunit "NPR Service Tier User Mgt.";
        ClientDiagnNpCaseMgt: Codeunit "NPR Client Diagn. NpCase Mgt.";
    begin
        ServiceTierUserMgt.ValidateBCOnlineTenant();
        ServiceTierUserMgt.TestUserOnLogin();
        ServiceTierUserMgt.SendPosUnitQty();
        ClientDiagnNpCaseMgt.CollectAndSendClientDiagnostics();
    end;
}
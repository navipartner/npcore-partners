codeunit 6059944 "NPR Invoke CaseSystem Login"
{
    Access = Internal;
    TableNo = "NPR Client Diagnostic v2";
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

    trigger OnRun()
    var
        ServiceTierUserMgt: Codeunit "NPR Service Tier User Mgt.";
        ClientDiagnNpCaseMgt: Codeunit "NPR Client Diagn. NpCase Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
        AzureAdTenant: Codeunit "Azure AD Tenant";
        AzureAdTenantId: Text;
        IsSaas: Boolean;
    begin
        IsSaas := EnvironmentInformation.IsSaaS(); //Just hardcode this to true if you want to simulate SaaS on container
        AzureAdTenantId := AzureAdTenant.GetAadTenantId(); //Just hardcode this to some AD ID if you want to simulate SaaS on container, otherwise it will be 'common'

        if IsSaas then begin
            ServiceTierUserMgt.ValidateSaasTenant(AzureAdTenantId);
            ServiceTierUserMgt.TestUserOnLogin(IsSaas, AzureAdTenantId, Rec."User Login Type");
            ClientDiagnNpCaseMgt.CollectAndSendClientDiagnostics(IsSaas, AzureAdTenantId, Rec."User Login Type");
            ServiceTierUserMgt.SendPosStoreAndUnitQtyFromSaasEnvironment(AzureAdTenantId);
        end else begin
            ServiceTierUserMgt.ValidateTenant();
            ServiceTierUserMgt.TestUserOnLogin(IsSaas, '', Rec."User Login Type");
            ClientDiagnNpCaseMgt.CollectAndSendClientDiagnostics(IsSaas, '', Rec."User Login Type");
            ServiceTierUserMgt.SendPosStoreAndUnitQty();
        end;
    end;
}
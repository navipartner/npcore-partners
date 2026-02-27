#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6150966 "NPR Sentry Metadata"
{
    Access = Internal;
    SingleInstance = true;

    var
        _installedAppsLoaded: Boolean;
        _installedApp: Dictionary of [Text, Text];


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', true, true)]
    local procedure OnCustomMethod(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean);
    var
        Json: Codeunit "Json Text Reader/Writer";
        Response: JsonObject;
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        if Method <> 'getSentryMetadata' then
            exit;
        Handled := true;

        Json.WriteStartObject('');
        Json.WriteStringProperty('sentryKey', AzureKeyVaultMgt.GetAzureKeyVaultSecret('SentryIODragonglassEU'));
        Json.WriteStringProperty('sessionRecordAll', true);
        WriteFrontendMetadataJson(Json);
        Json.WriteEndObject();
        Response.ReadFrom(Json.GetJSonAsText());

        Frontend.RespondToFrontEndMethod(Context, Response, FrontEnd);
    end;

    internal procedure WriteFrontendMetadataJson(Json: Codeunit "Json Text Reader/Writer")
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        CompanyInformation: Record "Company Information";
        InstalledApp: Record "NAV App Installed App";
        TenantInformation: Codeunit "Tenant Information";
        ActiveSession: Record "Active Session";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        CompanyInformation.Get();

        Json.WriteStringProperty('userId', Format(UserSecurityId(), 0, 4).ToLower());
        Json.WriteStringProperty('tenantId', TenantInformation.GetTenantId());
        Json.WriteStringProperty('tenantDisplayName', TenantInformation.GetTenantDisplayName());
        Json.WriteStringProperty('user', UserId);
        Json.WriteStringProperty('POSUnit', POSUnit."No.");
        Json.WriteStringProperty('POSStore', POSUnit."POS Store Code");
        Json.WriteStringProperty('VATNumber', CompanyInformation."VAT Registration No.");
        if InstalledApp.Get('992c2309-cca4-43cb-9e41-911f482ec088') then begin
            Json.WriteStringProperty('retailAppVersion', StrSubstNo('%1.%2.%3.%4', InstalledApp."Version Major", InstalledApp."Version Minor", InstalledApp."Version Build", InstalledApp."Version Revision"));
        end;
        if InstalledApp.Get('437dbf0e-84ff-417a-965d-ed2bb9650972') then begin
            Json.WriteStringProperty('baseAppVersion', StrSubstNo('%1.%2.%3.%4', InstalledApp."Version Major", InstalledApp."Version Minor", InstalledApp."Version Build", InstalledApp."Version Revision"));
        end;
        Json.WriteStringProperty('companyName', CompanyName());
        Json.WriteStringProperty('environment', GetEnvironment());
        Json.WriteStringProperty('serviceInstanceId', ServiceInstanceId());
        Json.WriteStringProperty('sessionId', SessionId());
        Json.WriteStringProperty('clientType', Format(CurrentClientType()));
        if ActiveSession.Get(ServiceInstanceId(), SessionId()) then begin
            Json.WriteStringProperty('sessionUniqueId', Format(ActiveSession."Session Unique ID", 0, 4).ToLower());
            Json.WriteStringProperty('serverInstanceName', ActiveSession."Server Instance Name");
        end;
        Json.WriteStringProperty('POSType', Format(POSUnit."POS Type", 0, 9));
    end;

    internal procedure WriteTagsForBackendEvent(var Json: Codeunit "NPR Json Builder")
    var
        TenantInformation: Codeunit "Tenant Information";
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        ActiveSession: Record "Active Session";
        InstalledApp: Record "NAV App Installed App";
        UserSetup: Record "User Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        if UserSetup.Get(UserId) then begin
            if POSUnit.Get(UserSetup."NPR POS Unit No.") then;
        end;

        if EnvironmentInformation.IsSaaSInfrastructure() then
            Json.AddProperty('aadTenantId', AzureADTenant.GetAadTenantId())
        else
            Json.AddProperty('aadTenantId', '_');

        Json.AddProperty('tenantId', TenantInformation.GetTenantId());
        if TenantInformation.GetTenantDisplayName() <> '' then begin
            Json.AddProperty('tenantDisplayName', TenantInformation.GetTenantDisplayName());
        end else begin
            Json.AddProperty('tenantDisplayName', '_');
        end;

        if POSUnit."No." <> '' then
            Json.AddProperty('POSUnit', POSUnit."No.")
        else
            Json.AddProperty('POSUnit', '_');

        if POSUnit."POS Store Code" <> '' then
            Json.AddProperty('POSStore', POSUnit."POS Store Code")
        else
            Json.AddProperty('POSStore', '_');

        if InstalledApp.Get('992c2309-cca4-43cb-9e41-911f482ec088') then begin
            Json.AddProperty('retailAppVersion', StrSubstNo('%1.%2.%3.%4', InstalledApp."Version Major", InstalledApp."Version Minor", InstalledApp."Version Build", InstalledApp."Version Revision"));
        end;
        if InstalledApp.Get('437dbf0e-84ff-417a-965d-ed2bb9650972') then begin
            Json.AddProperty('baseAppVersion', StrSubstNo('%1.%2.%3.%4', InstalledApp."Version Major", InstalledApp."Version Minor", InstalledApp."Version Build", InstalledApp."Version Revision"));
        end;
        Json.AddProperty('company', CompanyName());
        Json.AddProperty('environment', GetEnvironment());
        Json.AddProperty('BCServiceInstanceId', ServiceInstanceId());
        Json.AddProperty('BCSessionId', SessionId());
        Json.AddProperty('BCClientType', Format(CurrentClientType()));
        if ActiveSession.Get(ServiceInstanceId(), SessionId()) then begin
            Json.AddProperty('BCSessionUniqueId', Format(ActiveSession."Session Unique ID", 0, 4).ToLower());
            if ActiveSession."Server Instance Name" <> '' then
                Json.AddProperty('BCServerInstanceName', ActiveSession."Server Instance Name")
            else
                Json.AddProperty('BCServerInstanceName', '_');
        end;
        Json.AddProperty('POSType', Format(POSUnit."POS Type", 0, 9));
    end;

    internal procedure GetEnvironment(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        case true of
            GetUrl(ClientType::Web).Contains('dynamics-retail.net'):
                Exit('Crane');
            EnvironmentInformation.IsSandbox():
                Exit('Sandbox');
            EnvironmentInformation.IsSaaSInfrastructure():
                Exit('SaaS');
            else
                Exit('OnPrem');
        end;
    end;

    internal procedure WriteModulesJson(var Json: Codeunit "NPR Json Builder")
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        AppKey: Text;
        AppValue: Text;
        i: Integer;
    begin
        if not _installedAppsLoaded then begin
            i := 0;
            NAVAppInstalledApp.SetCurrentKey(Name);
            NAVAppInstalledApp.SetFilter(Publisher, '<>%1', 'Microsoft');
            if NAVAppInstalledApp.FindSet() then begin
                repeat
                    i += 1;
                    AppKey := StrSubstNo('%1 - %2', i, NAVAppInstalledApp.Name);
                    AppValue := StrSubstNo('%1.%2.%3.%4', NAVAppInstalledApp."Version Major", NAVAppInstalledApp."Version Minor", NAVAppInstalledApp."Version Build", NAVAppInstalledApp."Version Revision");
                    _installedApp.Add(AppKey, AppValue);
                until NAVAppInstalledApp.Next() = 0;
            end;
            _installedAppsLoaded := true;
        end;

        Json.StartObject('modules');
        foreach AppKey in _installedApp.Keys() do begin
            Json.AddProperty(AppKey, _installedApp.Get(AppKey));
        end;
        Json.EndObject();
    end;
}
#endif
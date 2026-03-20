#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6150966 "NPR Sentry Metadata"
{
    Access = Internal;
    SingleInstance = true;

    var
        _tagsLoaded: Boolean;
        _cachedTags: JsonObject;
        _modulesJsonLoaded: Boolean;
        _cachedModulesJson: JsonObject;
        _spanTagsLoaded: Boolean;
        _cachedSpanTags: JsonObject;


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

    internal procedure WriteTagsForBackendEvent(): JsonObject
    var
        TenantInformation: Codeunit "Tenant Information";
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        ActiveSession: Record "Active Session";
        InstalledApp: Record "NAV App Installed App";
        UserSetup: Record "User Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        if _tagsLoaded then
            exit(_cachedTags.Clone().AsObject());

        if UserSetup.Get(UserId) then begin
            if POSUnit.Get(UserSetup."NPR POS Unit No.") then;
        end;

        if EnvironmentInformation.IsSaaSInfrastructure() then
            _cachedTags.Add('aadTenantId', AzureADTenant.GetAadTenantId())
        else
            _cachedTags.Add('aadTenantId', '_');

        _cachedTags.Add('tenantId', TenantInformation.GetTenantId());
        if TenantInformation.GetTenantDisplayName() <> '' then begin
            _cachedTags.Add('tenantDisplayName', TenantInformation.GetTenantDisplayName());
        end else begin
            _cachedTags.Add('tenantDisplayName', '_');
        end;

        if POSUnit."No." <> '' then
            _cachedTags.Add('POSUnit', POSUnit."No.")
        else
            _cachedTags.Add('POSUnit', '_');

        if POSUnit."POS Store Code" <> '' then
            _cachedTags.Add('POSStore', POSUnit."POS Store Code")
        else
            _cachedTags.Add('POSStore', '_');

        if InstalledApp.Get('992c2309-cca4-43cb-9e41-911f482ec088') then begin
            _cachedTags.Add('retailAppVersion', StrSubstNo('%1.%2.%3.%4', InstalledApp."Version Major", InstalledApp."Version Minor", InstalledApp."Version Build", InstalledApp."Version Revision"));
        end;
        if InstalledApp.Get('437dbf0e-84ff-417a-965d-ed2bb9650972') then begin
            _cachedTags.Add('baseAppVersion', StrSubstNo('%1.%2.%3.%4', InstalledApp."Version Major", InstalledApp."Version Minor", InstalledApp."Version Build", InstalledApp."Version Revision"));
        end;
        _cachedTags.Add('company', CompanyName());
        _cachedTags.Add('environment', GetEnvironment());
        _cachedTags.Add('BCServiceInstanceId', ServiceInstanceId());
        _cachedTags.Add('BCSessionId', SessionId());
        _cachedTags.Add('BCClientType', Format(CurrentClientType()));
        if ActiveSession.Get(ServiceInstanceId(), SessionId()) then begin
            _cachedTags.Add('BCSessionUniqueId', Format(ActiveSession."Session Unique ID", 0, 4).ToLower());
            if ActiveSession."Server Instance Name" <> '' then
                _cachedTags.Add('BCServerInstanceName', ActiveSession."Server Instance Name")
            else
                _cachedTags.Add('BCServerInstanceName', '_');
        end;
        _cachedTags.Add('POSType', Format(POSUnit."POS Type", 0, 9));

        _tagsLoaded := true;
        exit(_cachedTags.Clone().AsObject());
    end;

    internal procedure WriteSpanTags(): JsonObject
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        if _spanTagsLoaded then
            exit(_cachedSpanTags);

        if EnvironmentInformation.IsSaaSInfrastructure() then
            _cachedSpanTags.Add('aadTenantId', AzureADTenant.GetAadTenantId())
        else
            _cachedSpanTags.Add('aadTenantId', '_');

        _cachedSpanTags.Add('company', CompanyName());

        _spanTagsLoaded := true;
        exit(_cachedSpanTags);
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

    internal procedure WriteModulesJson(): JsonObject
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
        AppKey: Text;
        AppValue: Text;
        i: Integer;
    begin
        if _modulesJsonLoaded then
            exit(_cachedModulesJson.Clone().AsObject());

        i := 0;
        NAVAppInstalledApp.SetCurrentKey(Name);
        NAVAppInstalledApp.SetFilter(Publisher, '<>%1', 'Microsoft');
        if NAVAppInstalledApp.FindSet() then begin
            repeat
                i += 1;
                AppKey := StrSubstNo('%1 - %2', i, NAVAppInstalledApp.Name);
                AppValue := StrSubstNo('%1.%2.%3.%4', NAVAppInstalledApp."Version Major", NAVAppInstalledApp."Version Minor", NAVAppInstalledApp."Version Build", NAVAppInstalledApp."Version Revision");
                _cachedModulesJson.Add(AppKey, AppValue);
            until NAVAppInstalledApp.Next() = 0;
        end;

        _modulesJsonLoaded := true;
        exit(_cachedModulesJson.Clone().AsObject());
    end;
}
#endif
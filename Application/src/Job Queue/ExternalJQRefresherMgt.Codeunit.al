codeunit 6248231 "NPR External JQ Refresher Mgt."
{
    Access = Internal;

    var
        ServiceNameTok: Label 'ExternalJQRefresher', Locked = true, MaxLength = 240;

    internal procedure ManageExternalJQRefresherTenants(action: Enum "NPR Ext. JQ Refresher Options"; var HttpResponseMessage: HttpResponseMessage)
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        CompanyNameUrlEncoded: Text;
        RequestUrl: Text;
        BaseURL: Label 'https://job-queue-refresher-tenant-manager%1/?tenantID=%2&environmentName=%3&companyName=%4&action=%5', Locked = true;
        SandboxEndpoint: Label '-prelive.navipartner-prelive.workers.dev', Locked = true;
        LiveEndpoint: Label '.npretail.app', Locked = true;
    begin
        CompanyNameUrlEncoded := CompanyName();
        TypeHelper.UrlEncode(CompanyNameUrlEncoded);

        if EnvironmentInformation.IsProduction() then
            RequestUrl := StrSubstNo(BaseURL, LiveEndpoint, AzureADTenant.GetAadTenantId(), EnvironmentInformation.GetEnvironmentName(), CompanyNameUrlEncoded, ExtJQRefresherEnumValueName(action))
        else
            RequestUrl := StrSubstNo(BaseURL, SandboxEndpoint, AzureADTenant.GetAadTenantId(), EnvironmentInformation.GetEnvironmentName(), CompanyNameUrlEncoded, ExtJQRefresherEnumValueName(action));

        CreateCloudflareHttpRequest('', RequestUrl, Enum::"Http Request Type"::POST, HttpResponseMessage);
    end;

    internal procedure CreateSaaSSetup()
    var
        AADApplication: Record "AAD Application";
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        ClientId: Guid;
        PermissionSets: List of [Code[20]];
        ErrorTxt: Text;
        ClientIdLbl: Label '{bdf6bb95-9dad-4504-91ab-8404427f4043}', Locked = true;
    begin
        //Register Azure AD (Microsoft Entra ID) Cloudflare Application and Try Grant Permissions
        Evaluate(ClientId, ClientIdLbl);
        AADApplication.SetRange("Client Id", ClientId);
        if not AADApplication.IsEmpty() then begin
            AADApplication.FindFirst();
            if not AADApplication."Permission Granted" then
                if not AADApplicationMgt.TryGrantConsentToApp(ClientId, 'common', ErrorTxt) then
                    Error(ErrorTxt);
            if AADApplication.State = AADApplication.State::Disabled then begin
                AADApplication.State := AADApplication.State::Enabled;
                AADApplication.Modify();
            end;
        end else begin
#if not BC17
            PermissionSets.Add(ExtJQRefresherRoleID());
#else
            PermissionSets.Add('D365 AUTOMATION');
            PermissionSets.Add('SUPER (DATA)');
#endif
            AADApplicationMgt.RegisterAzureADApplication(ClientId, 'JQ Runner', PermissionSets);
            if not AADApplicationMgt.TryGrantConsentToApp(ClientId, 'common', ErrorTxt) then
                Error(ErrorTxt);
        end;
    end;

    [TryFunction]
    internal procedure ValidateExternalJQRefresherTenantManager()
    var
        TenantManageOptions: Enum "NPR Ext. JQ Refresher Options";
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        ResponseIsEmptyLbl: Label 'JQ Runner''s database returned an empty response.';
        TenantInformationDoesNotExistLbl: Label 'Tenant information does not exist in the JQ Runner''s database.';
    begin
        ManageExternalJQRefresherTenants(TenantManageOptions::select, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(ResponseText);

        if ResponseText = '' then
            Error(ResponseIsEmptyLbl);

        JsonObject.ReadFrom(ResponseText);
        if not JsonObject.Get('exists', JsonToken) then begin
            if not JsonObject.Get('error', JsonToken) then
                Error(ResponseIsEmptyLbl);
            Error(JsonToken.AsValue().AsText());
        end;
        if not JsonToken.IsValue() then
            Error(ResponseIsEmptyLbl);
        if not JsonToken.AsValue().AsBoolean() then
            Error(TenantInformationDoesNotExistLbl);
    end;

    internal procedure CreateTenantWebService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, Codeunit::"NPR External JQ Refresher WS", ServiceNameTok, true)
    end;

    internal procedure RemoveTenantWebService()
    var
        TenantWebService: Record "Tenant Web Service";
    begin
        if ExternalJQRefresherListenerWebserviceExists(TenantWebService) then
            TenantWebService.Delete(true);
    end;

    internal procedure SendRefreshRequest(var HttpResponseMessage: HttpResponseMessage): Text
    var
        TypeHelper: Codeunit "Type Helper";
        CompanyNameUrlEncoded: Text;
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        RequestUrl: Text;
        BaseUrl: Label 'https://job-queue-refresher%1/?tenantID=%2&environmentName=%3&companyName=%4', Locked = true;
        SandboxEndpoint: Label '-prelive.navipartner-prelive.workers.dev', Locked = true;
        LiveEndpoint: Label '.npretail.app', Locked = true;
    begin
        CompanyNameUrlEncoded := CompanyName();
        TypeHelper.UrlEncode(CompanyNameUrlEncoded);

        if EnvironmentInformation.IsProduction() then
            RequestUrl := StrSubstNo(BaseUrl, LiveEndpoint, AzureADTenant.GetAadTenantId(), EnvironmentInformation.GetEnvironmentName(), CompanyNameUrlEncoded)
        else
            RequestUrl := StrSubstNo(BaseUrl, SandboxEndpoint, AzureADTenant.GetAadTenantId(), EnvironmentInformation.GetEnvironmentName(), CompanyNameUrlEncoded);

        CreateCloudflareHttpRequest('', RequestUrl, Enum::"Http Request Type"::POST, HttpResponseMessage);
    end;

    #region Azure AD application
    internal procedure CreateAzureADApplication(AppDisplayName: Text[50]; var ClientID: Guid; var ClientSecret: Text)
    var
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        PermissionSets: List of [Code[20]];
    begin
#if not BC17
        PermissionSets.Add(ExtJQRefresherRoleID());
#else
        PermissionSets.Add('D365 AUTOMATION');
        PermissionSets.Add('SUPER (DATA)');
#endif
        AADApplicationMgt.SetSilent(true);
        AADApplicationMgt.CreateAzureADApplicationAndSecret(AppDisplayName, SecretDisplayName(), PermissionSets);
        AADApplicationMgt.GetApplicationIDAndSecret(ClientID, ClientSecret);
    end;

    [NonDebuggable]
    internal procedure ManageJQRefresherUser(ClientID: Guid; ClientSecret: Text; action: Enum "NPR Ext. JQ Refresher Options"; var HttpResponseMessage: HttpResponseMessage)
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        RequestUrl: Text;
        BaseUrl: Label 'https://job-queue-refresher-entra-app-manager%1/?action=%2', Locked = true;
        SandboxEndpoint: Label '-prelive.navipartner-prelive.workers.dev', Locked = true;
        LiveEndpoint: Label '.npretail.app', Locked = true;
        RequestBodyString: Label '{"TenantID_EnvironmentName_ClientID": "%1|%2|%3", "ClientSecret": "%4"}';
        RequestText: Text;
    begin
        if EnvironmentInformation.IsProduction() then
            RequestUrl := StrSubstNo(BaseUrl, LiveEndpoint, ExtJQRefresherEnumValueName(action))
        else
            RequestUrl := StrSubstNo(BaseUrl, SandboxEndpoint, ExtJQRefresherEnumValueName(action));

        RequestText := StrSubstNo(RequestBodyString, AzureADTenant.GetAadTenantId(), EnvironmentInformation.GetEnvironmentName(), Format(ClientID), ClientSecret);

        CreateCloudflareHttpRequest(RequestText, RequestUrl, Enum::"Http Request Type"::POST, HttpResponseMessage);
    end;

    internal procedure LookupJQRefresherUserName(var Text: Text): Boolean
    var
        AADApplication: Record "AAD Application";
        User: Record User;
        AADApplicationPage: Page "AAD Application List";
    begin
        FilterJQRefresherAADApps(AADApplication);
        AADApplicationPage.SetTableView(AADApplication);
        AADApplicationPage.LookupMode := true;
        if AADApplicationPage.RunModal() <> Action::LookupOK then
            exit(false);
        AADApplicationPage.GetRecord(AADApplication);
        User.Get(AADApplication."User ID");
        Text := User."User Name";
        exit(true);
    end;

    internal procedure FilterJQRefresherAADApps(var AADApplication: Record "AAD Application")
    var
        AccessControl: Record "Access Control";
    begin
        AADApplication.Reset();
        if AADApplication.FindSet() then
            repeat
                if AccessControl.Get(AADApplication."User ID", ExtJQRefresherRoleID(), '', AccessControl.Scope::System, AADApplication."App ID") then
                    AADApplication.Mark(true);
            until AADApplication.Next() = 0;
        AADApplication.MarkedOnly(true);
    end;

    internal procedure ExtJQRefresherRoleID(): Code[20]
    var
        PermissionSetLbl: Label 'NPR EXT JQ REFRESHER', MaxLength = 20, Locked = true;
    begin
        exit(PermissionSetLbl);
    end;

    internal procedure CreateExternalJQRefresherUser(var JQRefreshSetup: Record "NPR Job Queue Refresh Setup")
    var
        AADApplication: Record "AAD Application";
        User: Record User;
        ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
        ExtJQRefresherEntraApp: Report "NPR Ext JQ Refresher Entra App";
        HttpResponseMessage: HttpResponseMessage;
        AppDisplayName: Text[50];
        ClientSecret: Text;
        ResponseText: Text;
        ClientID: Guid;
        EntraAppFailedToCreateLbl: Label 'Entra App "%1" could not be created.\Please retry.';
        EntraAppIsMissingConsentLbl: Label '"%1" Entra App was successfully created and registered but the required permissions has not yet been granted. Please grant required permissions before expecting of the External Job Queue Refresher to use it.';
        EntraAppRegisterSuccessLbl: Label '"%1" Entra App was successfully created and registered.';
    begin
        AppDisplayName := CopyStr(ExtJQRefresherEntraApp.RequestAppDisplayName(), 1, MaxStrLen(AppDisplayName));
        if AppDisplayName = '' then
            exit;
        ExternalJQRefresherMgt.CreateAzureADApplication(AppDisplayName, ClientID, ClientSecret);
        if not AADApplication.Get(ClientID) then
            Error(EntraAppFailedToCreateLbl, AppDisplayName);
        ExternalJQRefresherMgt.ManageJQRefresherUser(ClientID, ClientSecret, Enum::"NPR Ext. JQ Refresher Options"::create, HttpResponseMessage);
        if not HttpResponseMessage.IsSuccessStatusCode() then begin
            HttpResponseMessage.Content().ReadAs(ResponseText);
            Message(ResponseText);
            exit;
        end;

        if JQRefreshSetup."Default Refresher User Name" = '' then
            if User.Get(AADApplication."User ID") then begin
                JQRefreshSetup.Validate("Default Refresher User Name", User."User Name");
                JQRefreshSetup.Modify();
            end;

        if not AADApplication."Permission Granted" then
            Message(EntraAppIsMissingConsentLbl, AppDisplayName)
        else
            Message(EntraAppRegisterSuccessLbl, AppDisplayName);
    end;

    local procedure SecretDisplayName(): Text
    var
        SecretDisplayNameLbl: Label 'NaviPartner External Job Queue Refresher integration - %1', Comment = '%1 = today''s date', Locked = true;
    begin
        exit(StrSubstNo(SecretDisplayNameLbl, Format(Today(), 0, 9)));
    end;
    #endregion

    local procedure ExternalJQRefresherListenerWebserviceExists(var TenantWebService: Record "Tenant Web Service"): Boolean
    begin
        exit(TenantWebService.Get(TenantWebService."Object Type"::Codeunit, ServiceNameTok));
    end;

    [NonDebuggable]
    local procedure CreateCloudflareHttpRequest(RequestText: Text; RequestUrl: Text; Method: Enum "Http Request Type"; var HttpResponseMessage: HttpResponseMessage)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HttpRequestHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        KeyLbl: Label 'NPCloudflareJQRefresherAPIKey', Locked = True;
    begin
        Clear(HttpRequestMessage);
        HttpContent.GetHeaders(HttpContentHeaders);
        HttpContentHeaders.Clear();
        HttpContentHeaders.Add('Content-Type', 'text/json; charset="utf-8"');

        HttpRequestMessage.GetHeaders(HttpRequestHeaders);
        HttpRequestHeaders.Add('Authorization', 'Bearer ' + AzureKeyVaultMgt.GetAzureKeyVaultSecret(KeyLbl));

        if (RequestText <> '') and (not (Method in [Enum::"Http Request Type"::GET])) then
            HttpContent.WriteFrom(RequestText);

        HttpRequestMessage.Content := HttpContent;
        HttpRequestMessage.SetRequestUri(RequestUrl);
        HttpRequestMessage.Method := Method.Names().Get(Method.Ordinals().IndexOf(Method.AsInteger()));

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
    end;

    internal procedure CheckBaseAppVerion(ShowError: Boolean): Boolean
    var
        BaseAppID: Codeunit "BaseApp ID";
        Info: ModuleInfo;
    begin
        NavApp.GetModuleInfo(BaseAppID.Get(), Info);
        if Info.DataVersion.Major >= 22 then
            exit(true);
        if ShowError then
            ThrowIncompatibleBaseVersion();
        exit(false)
    end;

    [TryFunction]
    internal procedure TryThrowIncompatibleBaseVersion()
    begin
        ThrowIncompatibleBaseVersion();
    end;

    local procedure ThrowIncompatibleBaseVersion()
    var
        NotCompatibleWithThisVersionErr: Label 'The External Job Queue Refresher requires a minimum BC version of 22.';
    begin
        Error(NotCompatibleWithThisVersionErr);
    end;

    local procedure ExtJQRefresherEnumValueName(RefresherOption: Enum "NPR Ext. JQ Refresher Options") Result: Text
    begin
        RefresherOption.Names().Get(RefresherOption.Ordinals().IndexOf(RefresherOption.AsInteger()), Result);
    end;

#if not (BC17 or BC18)
    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure DisableExtJQRefresher_OnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    var
        JQRefresherSetup: Record "NPR Job Queue Refresh Setup";
    begin
        if (NewCompanyName <> '') and (NewCompanyName <> CompanyName()) then
            JQRefresherSetup.ChangeCompany(NewCompanyName);
        if JQRefresherSetup.Get() and JQRefresherSetup."Use External JQ Refresher" then begin
            JQRefresherSetup."Use External JQ Refresher" := false;
            JQRefresherSetup.Modify();
        end;
    end;

#if BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
#endif
    local procedure DisableExtJQRefresher_OnClearCompanyConfiguration(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        JQRefresherSetup: Record "NPR Job Queue Refresh Setup";
    begin
        if JQRefresherSetup.Get() and JQRefresherSetup."Use External JQ Refresher" then begin
            JQRefresherSetup.Validate("Use External JQ Refresher", false);
            JQRefresherSetup.Modify();
        end;
    end;
#endif
}
codeunit 6248231 "NPR External JQ Refresher Mgt."
{
    Access = Internal;

    var
        ServiceNameTok: Label 'ExternalJQRefresher', Locked = true, MaxLength = 240;

    internal procedure ManageExternalJQRefresherTenants(action: Enum "NPR Ext. JQ Refresher Options"): Text
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        CompanyNameUrlEncoded: Text;
        RequestUrl: Text;
        BaseURL: Label 'https://job-queue-refresher-tenant-manager.navipartner-prelive.workers.dev/?tenantID=%1&environmentName=%2&companyName=%3&action=%4', Locked = true;
    begin
        CompanyNameUrlEncoded := CompanyName();
        TypeHelper.UrlEncode(CompanyNameUrlEncoded);

        RequestUrl := StrSubstNo(BaseURL, AzureADTenant.GetAadTenantId(), EnvironmentInformation.GetEnvironmentName(), CompanyNameUrlEncoded, ExtJQRefresherEnumValueName(action));

        exit(CreateCloudflareHttpRequest('', RequestUrl, Enum::"Http Request Type"::POST));
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
        //Register Azure AD Cloudflare Application and Try Grant Permissions
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
            PermissionSets.Add('NPR Ext JQ Refresher');
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
    internal procedure ValidateSaaSSetup()
    var
        AADApplication: Record "AAD Application";
        ClientId: Guid;
        ClientIdLbl: Label '{bdf6bb95-9dad-4504-91ab-8404427f4043}', Locked = true;
        EntraAppIsMissingLbl: Label 'JQ Runner Entra App is missing. Please create it by triggering the ''Create JQ Runner Entra App'' action.\This action can only be used by a user that is an Entra ID Global Administrator. The procedure will create a single-tenant Entra app on your behalf and ask for the required admin consent.';
        EntraAppIsMissingConsentLbl: Label 'JQ Runner Entra App exists but the required permissions has not yet been granted. Please grant required permissions by triggering the ''Create JQ Runner Entra App'' action or proceeding to the ''JQ Runner'' Microsoft Entra Application Card.\This action can only be used by a user that is an Entra ID Global Administrator. The procedure will create a single-tenant Entra app on your behalf and ask for the required admin consent.';
        EntraAppIsDisabledLbl: Label 'JQ Runner Entra App exists and is configured correctly but it is disabled. Please enable it by triggering the ''Create JQ Runner Entra App'' action or proceeding to the ''JQ Runner'' Microsoft Entra Application Card.\This action can only be used by a user that is an Entra ID Global Administrator. The procedure will create a single-tenant Entra app on your behalf and ask for the required admin consent.';
    begin
        Evaluate(ClientId, ClientIdLbl);
        AADApplication.SetRange("Client Id", ClientId);
        if AADApplication.IsEmpty() then
            Error(EntraAppIsMissingLbl);
        AADApplication.FindFirst();
        if not AADApplication."Permission Granted" then
            Error(EntraAppIsMissingConsentLbl);
        if AADApplication.State = AADApplication.State::Disabled then
            Error(EntraAppIsDisabledLbl);
    end;

    [TryFunction]
    internal procedure ValidateExternalJQRefresherTenantManager()
    var
        TenantManageOptions: Enum "NPR Ext. JQ Refresher Options";
        ResponseText: Text;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        ResponseIsEmptyLbl: Label 'JQ Runner''s database returned an empty response.';
        TenantInformationDoesNotExistLbl: Label 'Tenant information does not exist in the JQ Runner''s database.';
    begin
        ResponseText := ManageExternalJQRefresherTenants(TenantManageOptions::select);
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

    internal procedure ToggleTenantWebService(UseExternalJQRefresher: Boolean)
    begin
        if UseExternalJQRefresher then
            CreateTenantWebService()
        else
            RemoveTenantWebService();
    end;

    internal procedure SendRefreshRequest(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        CompanyNameUrlEncoded: Text;
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        RequestUrl: Text;
        BaseUrl: Label 'https://job-queue-refresher.navipartner-prelive.workers.dev/?tenantID=%1&environmentName=%2&companyName=%3', Locked = true;
    begin
        CompanyNameUrlEncoded := CompanyName();
        TypeHelper.UrlEncode(CompanyNameUrlEncoded);

        RequestUrl := StrSubstNo(BaseURL, AzureADTenant.GetAadTenantId(), EnvironmentInformation.GetEnvironmentName(), CompanyNameUrlEncoded);
        exit(CreateCloudflareHttpRequest('', RequestUrl, Enum::"Http Request Type"::POST));
    end;

    local procedure ExternalJQRefresherListenerWebserviceExists(var TenantWebService: Record "Tenant Web Service"): Boolean
    begin
        exit(TenantWebService.Get(TenantWebService."Object Type"::Codeunit, ServiceNameTok));
    end;

    [NonDebuggable]
    local procedure CreateCloudflareHttpRequest(RequestText: Text; RequestUrl: Text; Method: Enum "Http Request Type"): Text
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpContentHeaders: HttpHeaders;
        HttpRequestHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
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
        HttpResponseMessage.Content().ReadAs(ResponseText);

        exit(ResponseText);
    end;

    local procedure ExtJQRefresherEnumValueName(RefresherOption: Enum "NPR Ext. JQ Refresher Options") Result: Text
    begin
        RefresherOption.Names().Get(RefresherOption.Ordinals().IndexOf(RefresherOption.AsInteger()), Result);
    end;
}

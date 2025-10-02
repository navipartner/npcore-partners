#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248565 "NPR NP API Key Mgt."
{
    Access = Internal;

    // For development and testing use NPAPIKEYAUTHDEV preprocessor directive to use hardcoded values for API key validation and API authentication.
    // These are or should be aligned with the relevant prelive workers and their configurations.

    var
        FailedToCreateApiKeyErr: Label 'Failed to create API key. Status code: %1. Response: %2', Comment = '%1 = HTTP status code, %2 = response body';
        FailedToRevokeApiKeyErr: Label 'Failed to revoke API key. Status code: %1. Response: %2', Comment = '%1 = HTTP status code, %2 = response body';
        FailedToActivateApiKeyErr: Label 'Failed to activate API key. Status code: %1. Response: %2', Comment = '%1 = HTTP status code, %2 = response body';
        FailedToReadResponseBodyErr: Label 'Failed to read response body.';
        JtiNotFoundInResponseErr: Label 'Jti not found in response.';
        ApiKeyNotFoundInResponseErr: Label 'ApiKey not found in response.';
        FailedToRegisterEntraAppErr: Label 'Failed to register entra app. Status code: %1. Response: %2', Comment = '%1 = HTTP status code, %2 = response body';
        InvalidApiKeyFormatErr: Label 'Invalid API Key format.';
        InvalidApiKeySignatureErr: Label 'Invalid API Key signature.';
        OnlySaaSSupportedErr: Label 'NP API Key feature is supported in SaaS only!';
        ApiKeyValidationFailedErr: Label 'Error: %1\Details:%2', Comment = '%1 = error message, %2 = details';

    procedure CreateNewApiKey(Description: Text[30]): Text
    var
        NPAPIKey: Record "NPR NP API Key";
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpContentHeaders: HttpHeaders;
        HttpClient: HttpClient;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        JsonBody: JsonObject;
        JsonToken: JsonToken;
        JsonBodyString: Text;
        Jti: Text;
        ApiKey: Text;
        TenantId: Text;
        ResponseBody: Text;
    begin
        TenantId := GetTenantIdAsString();
        JsonBody.Add('tenantId', TenantId);
        JsonBody.WriteTo(JsonBodyString);

        RequestMsg.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Authorization', GetApiAuthHeader());

        HttpContent.WriteFrom(JsonBodyString);
        HttpContent.GetHeaders(HttpContentHeaders);

        HttpContentHeaders.Clear();
        HttpContentHeaders.Add('Content-Type', 'application/json');

        RequestMsg.SetRequestUri(GetWorkerBaseUrl() + '/keys');
        RequestMsg.Method := 'POST';
        RequestMsg.Content := HttpContent;

        HttpClient.Send(RequestMsg, ResponseMsg);

        if (not ResponseMsg.IsSuccessStatusCode) then begin
            if not ResponseMsg.Content.ReadAs(ResponseBody) then
                ResponseBody := '';
            Error(FailedToCreateApiKeyErr, ResponseMsg.HttpStatusCode, ResponseBody);
        end;

        if (not ResponseMsg.Content.ReadAs(JsonBodyString)) then
            Error(FailedToReadResponseBodyErr);
        JsonBody.ReadFrom(JsonBodyString);

        if not JsonBody.SelectToken('$.apiKey', JsonToken) then
            Error(ApiKeyNotFoundInResponseErr);
        ApiKey := JsonToken.AsValue().AsText();

        Jti := GetIdFromApiKey(ApiKey);

        NPAPIKey.Init();
        Evaluate(NPAPIKey.Id, CopyStr(Jti, 1, MaxStrLen(NPAPIKey.Id)));
        NPAPIKey.Description := Description;
        NPAPIKey.Status := "NPR NP API Key Status"::Active;
        NPAPIKey.Insert(true);

        exit(ApiKey);
    end;

    procedure RevokeApiKey(var NPAPIKey: Record "NPR NP API Key")
    begin
        ChangeStatus(NPAPIKey, "NPR NP API Key Status"::Revoked, FailedToRevokeApiKeyErr);
    end;

    procedure ActivateApiKey(var NPAPIKey: Record "NPR NP API Key")
    begin
        ChangeStatus(NPAPIKey, "NPR NP API Key Status"::Active, FailedToActivateApiKeyErr);
    end;

    local procedure ChangeStatus(var NPAPIKey: Record "NPR NP API Key"; NewStatus: Enum "NPR NP API Key Status"; ErrorMessage: Text)
    var
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpContentHeaders: HttpHeaders;
        HttpClient: HttpClient;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        JsonBody: JsonObject;
        JsonBodyString: Text;
        ResponseBody: Text;
    begin
        JsonBody.Add('status', Format(NewStatus, 0, 1));
        JsonBody.WriteTo(JsonBodyString);

        HttpContent.WriteFrom(JsonBodyString);
        HttpContent.GetHeaders(HttpContentHeaders);
        HttpContentHeaders.Clear();
        HttpContentHeaders.Add('Content-Type', 'application/json');

        RequestMsg.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Authorization', GetApiAuthHeader());

        RequestMsg.SetRequestUri(GetWorkerBaseUrl() + '/keys/' + GetGuidAsString(NPAPIKey.Id));
        RequestMsg.Method := 'PUT';
        RequestMsg.Content := HttpContent;

        HttpClient.Send(RequestMsg, ResponseMsg);

        if (not ResponseMsg.IsSuccessStatusCode) then begin
            if not ResponseMsg.Content.ReadAs(ResponseBody) then
                ResponseBody := '';
            Error(ErrorMessage, ResponseMsg.HttpStatusCode, ResponseBody);
        end;

        NPAPIKey.Status := NewStatus;
        NPAPIKey.Modify(true);
    end;

    local procedure DecodeBase64URL(Text: Text): Text
    var
        Output: Text;
    begin
        Output := ConvertStr(Text, '_-', '/+');
        exit(PadStr(Output, (StrLen(Output) + (4 - StrLen(Output) mod 4) mod 4), '='));
    end;

    local procedure GetIdFromApiKey(ApiKey: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        JsonPayload: JsonObject;
        JsonToken: JsonToken;
        JwtPayload: Text;
        JwtParts: List of [Text];
        ApiKeyId: Text;
        Base64JwtPayload: Text;
    begin
        JwtParts := ApiKey.Split('.');
        if (JwtParts.Count <> 3) then
            Error(InvalidApiKeyFormatErr);

        VerifyApiKeySignature(ApiKey);

        Base64JwtPayload := DecodeBase64URL(JwtParts.Get(2));
        JwtPayload := Base64Convert.FromBase64(Base64JwtPayload);
        JsonPayload.ReadFrom(JwtPayload);

        if (not JsonPayload.SelectToken('$.jti', JsonToken)) then
            Error(JtiNotFoundInResponseErr);

        ApiKeyId := JsonToken.AsValue().AsText();
        exit(ApiKeyId);
    end;

    local procedure VerifyApiKeySignature(ApiKey: Text)
    var
        JwtParts: List of [Text];
        DataToVerify: Text;
        Signature: Text;
        IsSignatureValid: Boolean;
        JWTVer: Codeunit "NPR JWT RS256 Verification";
    begin
        JwtParts := ApiKey.Split('.');
        DataToVerify := JwtParts.Get(1) + '.' + JwtParts.Get(2);
        Signature := DecodeBase64URL(JwtParts.Get(3));

        IsSignatureValid := JWTVer.VerifyCompleteJWT(ApiKey, GetPublicCertificateKey(), GetExpectedIssueer(), 'bc-rest-api-proxy', 300);

        if (not IsSignatureValid) then
            Error(ApiKeyValidationFailedErr, InvalidApiKeySignatureErr, JWTVer.GetLastDetectedIssues());

    end;

    procedure RegisterEntraAppAndCredentials(NPAPIKey: Record "NPR NP API Key")
    var
        AADApplication: Record "AAD Application";
        JsonBuilder: Codeunit "NPR Json Builder";
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpContentHeaders: HttpHeaders;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        JsonBodyString: Text;
        ApplicationId: Guid;
        ClientID: Guid;
        ClientSecret: Text;
        ResponseBody: Text;
    begin
        CreateNewEntraAppInAzure(GetEntraAppName(NPAPIKey.Description), 'Primary', GetNPAPIKeyPermissions(NPAPIKey), ApplicationId, ClientID, ClientSecret);

        JsonBodyString := JsonBuilder
            .Initialize()
            .StartObject()
                .AddProperty('id', GetGuidAsString(ApplicationId))
                .AddProperty('apiKeyId', GetGuidAsString(NPAPIKey.Id))
                .AddProperty('clientId', GetGuidAsString(ClientID))
                .AddProperty('clientSecret', ClientSecret)
                .AddProperty('description', NPAPIKey.Description)
                .AddProperty('tenantId', GetTenantIdAsString())
            .EndObject()
            .BuildAsText();

        RequestMsg.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Authorization', GetApiAuthHeader());

        HttpContent.WriteFrom(JsonBodyString);
        HttpContent.GetHeaders(HttpContentHeaders);
        HttpContentHeaders.Clear();
        HttpContentHeaders.Add('Content-Type', 'application/json');

        RequestMsg.SetRequestUri(GetWorkerBaseUrl() + '/entra-apps');
        RequestMsg.Method := 'POST';
        RequestMsg.Content := HttpContent;
        HttpClient.Send(RequestMsg, ResponseMsg);

        if (not ResponseMsg.IsSuccessStatusCode) then begin
            if not ResponseMsg.Content.ReadAs(ResponseBody) then
                ResponseBody := '';
            Error(FailedToRegisterEntraAppErr, ResponseMsg.HttpStatusCode, ResponseBody);
        end;

        AADApplication.Get(ClientID);
        AADApplication.Validate("NPR NP API Key Id", NPAPIKey.Id);
        AADApplication.Modify(true);
    end;

    local procedure GetEntraAppName(ApiKeyName: Text) RetVal: Text[50]
    begin
        RetVal := CopyStr(StrSubstNo('%1 - %2', ApiKeyName, Format(CurrentDateTime(), 0, '<Year4>-<Month,2>-<Day,2>_<Hours24,2><Minutes,2><Seconds,2>')), 1, MaxStrLen(RetVal));
        exit(RetVal);
    end;

    local procedure GetGuidAsString(GuidValue: Guid): Text
    begin
        exit(DelChr(Format(GuidValue), '=', '{}').ToLower());
    end;

    local procedure GetTenantIdAsString() TenantId: Text
    begin
        TenantId := GetTenantId();
        TenantId := GetGuidAsString(TenantId);

        exit(TenantId);
    end;

    local procedure GetTenantId(): Guid
    var
        AzureEntraIDTenant: Codeunit "Azure AD Tenant";
        Environment: Codeunit "Environment Information";
    begin
#if NPAPIKEYAUTHDEV
        if (not Environment.IsSaaSInfrastructure()) then
            exit('3b2a237c-fc42-4168-b2a9-9a1d718744f6');
#endif
        if (not Environment.IsSaaSInfrastructure()) then
            Error(OnlySaaSSupportedErr);

        exit(AzureEntraIDTenant.GetAadTenantId());
    end;

    local procedure GetNPAPIKeyPermissions(NPAPIKey: Record "NPR NP API Key"): List of [Code[20]]
    var
        NPAPIKeyPermission: Record "NPR NP API Key Permission";
        PermissionSets: List of [Code[20]];
    begin
        NPAPIKeyPermission.SetRange("NPR NP API Key Id", NPAPIKey.Id);
        if NPAPIKeyPermission.FindSet() then
            repeat
                PermissionSets.Add(NPAPIKeyPermission."Permission Set ID");
            until NPAPIKeyPermission.Next() = 0;
        exit(PermissionSets);
    end;

    local procedure CreateNewEntraAppInAzure(AppDisplayName: Text[50]; SecretDisplayName: Text; PermissionSets: List of [Code[20]];
        var ApplicationId: Guid; var ClientID: Guid; var ClientSecret: Text)
    var
        EntraAppMgt: Codeunit "NPR AAD Application Mgt.";
    begin
        EntraAppMgt.SetSilent(true);
        EntraAppMgt.CreateAzureADApplicationAndSecret(AppDisplayName, SecretDisplayName, PermissionSets);
        EntraAppMgt.GetApplicationIDAndSecret(ClientID, ClientSecret);
        ApplicationId := EntraAppMgt.GetApplicationId();
    end;

    local procedure
    GetPublicCertificateKey() CertPubKey: Text
    var
        KeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        CertPubKey := KeyVaultMgt.GetAzureKeyVaultSecret('BcRestApiProxyAuthProviderPubCert');
        exit(CertPubKey);
    end;

    local procedure GetApiAuthHeader() SecretHeader: SecretText;
    var
        KeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        SecretHeader := StrSubstNo('Bearer %1', KeyVaultMgt.GetAzureKeyVaultSecret('BcRestApiProxyAuthProviderApiKey'));
        exit(SecretHeader);
    end;

    local procedure GetWorkerBaseUrl(): Text
    begin
#if NPAPIKEYAUTHDEV
        exit('https://bc-rest-api-proxy-auth.npretail-prelive.app/api');
#endif
        exit('https://bc-rest-api-proxy-auth.npretail.app/api');
    end;

    local procedure GetExpectedIssueer(): Text
    begin
#if NPAPIKEYAUTHDEV
        exit('https://bc-rest-api-proxy-auth.npretail-prelive.app');
#endif
        exit('https://bc-rest-api-proxy-auth.npretail.app');
    end;

}
#endif
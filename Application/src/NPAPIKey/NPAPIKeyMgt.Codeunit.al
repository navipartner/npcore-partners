#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248565 "NPR NP API Key Mgt."
{
    Access = Internal;
    EventSubscriberInstance = StaticAutomatic;

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
        OnlySaaSSupportedErr: Label 'NaviPartner API Key feature is supported in SaaS only!';
        ApiKeyValidationFailedErr: Label 'Error: %1\Details:%2', Comment = '%1 = error message, %2 = details';
        AtLeastOnePermissionSetMustBeAssignedErr: Label 'At least one permission set must be assigned to the API key before registering an Entra ID application.';
        AtLeastOnePermissionSetMustBeAssignedForSyncErr: Label 'At least one permission set must be assigned to the API key before synchronizing to Entra ID application.';
        FailedToRotateApiKeyErr: Label 'Failed to rotate API key. Status code: %1. Response: %2', Comment = '%1 = HTTP status code, %2 = response body';
        FailedToRemoveEntraAppErr: Label 'Failed to remove existing Entra ID application. Status code: %1. Response: %2', Comment = '%1 = HTTP status code, %2 = response body';
        InvalidJtiGuidFormatErr: Label 'JTI is not a valid GUID. The value is: %1', Comment = '%1 = JTI value';

    procedure CreateNewApiKey(Description: Text[30]): Text
    var
        NPAPIKey: Record "NPR NaviPartner API Key";
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
        JsonBody.Add('description', Description);
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
            if (not ResponseMsg.Content.ReadAs(ResponseBody)) then
                ResponseBody := '';
            Error(FailedToCreateApiKeyErr, ResponseMsg.HttpStatusCode, ResponseBody);
        end;

        if (not ResponseMsg.Content.ReadAs(JsonBodyString)) then
            Error(FailedToReadResponseBodyErr);
        JsonBody.ReadFrom(JsonBodyString);

        if (not JsonBody.SelectToken('$.apiKey', JsonToken)) then
            Error(ApiKeyNotFoundInResponseErr);
        ApiKey := JsonToken.AsValue().AsText();

        Jti := GetIdFromApiKey(ApiKey);

        NPAPIKey.Init();
        Evaluate(NPAPIKey.Id, CopyStr(Jti, 1, MaxStrLen(NPAPIKey.Id)));
        NPAPIKey.Description := Description;
        NPAPIKey.Status := "NPR NP API Key Status"::Active;
        NPAPIKey."Key Secret Hint" := CopyStr(APIKey, 1, 4) + '******' + CopyStr(APIKey, StrLen(APIKey) - 3, 4);
        NPAPIKey.Insert(true);

        exit(ApiKey);
    end;

    procedure RotateApiKey(NPAPIKey: Record "NPR NaviPartner API Key"): Text
    var
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpContentHeaders: HttpHeaders;
        HttpClient: HttpClient;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        JsonBody: JsonObject;
        JsonToken: JsonToken;
        JsonBodyString: Text;
        ResponseBody: Text;
        Jti: Text;
        ApiKey: Text;
        TenantIdStr: Text;
        JtiGuid: Guid;
    begin
        NPAPIKey.LockTable();
        NPAPIKey.Get(NPAPIKey.RecordId());

        NPAPIKey.TestField(Id);
        NPAPIKey.TestField(Status, "NPR NP API Key Status"::Active);

        TenantIdStr := GetTenantIdAsString();
        JsonBody.Add('tenantId', TenantIdStr);
        JsonBody.WriteTo(JsonBodyString);

        RequestMsg.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Authorization', GetApiAuthHeader());

        HttpContent.WriteFrom(JsonBodyString);
        HttpContent.GetHeaders(HttpContentHeaders);

        HttpContentHeaders.Clear();
        HttpContentHeaders.Add('Content-Type', 'application/json');

        RequestMsg.SetRequestUri(GetWorkerBaseUrl() + StrSubstNo('/keys/%1/rotate', GetGuidAsString(NPAPIKey.Id)));
        RequestMsg.Method := 'POST';
        RequestMsg.Content := HttpContent;

        HttpClient.Send(RequestMsg, ResponseMsg);

        if (not ResponseMsg.IsSuccessStatusCode) then begin
            if (not ResponseMsg.Content.ReadAs(ResponseBody)) then
                ResponseBody := '';
            Error(FailedToRotateApiKeyErr, ResponseMsg.HttpStatusCode, ResponseBody);
        end;

        if (not ResponseMsg.Content.ReadAs(JsonBodyString)) then
            Error(FailedToReadResponseBodyErr);
        JsonBody.ReadFrom(JsonBodyString);

        if (not JsonBody.SelectToken('$.apiKey', JsonToken)) then
            Error(ApiKeyNotFoundInResponseErr);
        ApiKey := JsonToken.AsValue().AsText();

        Jti := GetIdFromApiKey(ApiKey);
        if (not Evaluate(JtiGuid, Jti)) then
            Error(InvalidJtiGuidFormatErr, Jti);

        NPAPIKey.TestField(Id, JtiGuid);
        NPAPIKey."Key Secret Hint" := CopyStr(APIKey, 1, 4) + '******' + CopyStr(APIKey, StrLen(APIKey) - 3, 4);
        NPAPIKey.Modify(true);

        exit(ApiKey);
    end;

    procedure RevokeApiKey(NPAPIKey: Record "NPR NaviPartner API Key")
    var
        NPAPIKey2: Record "NPR NaviPartner API Key";
    begin
        NPAPIKey2.LockTable();
        NPAPIKey2.Get(NPAPIKey.Id);
        ChangeStatus(NPAPIKey2, "NPR NP API Key Status"::Revoked, FailedToRevokeApiKeyErr);
    end;

    procedure ActivateApiKey(NPAPIKey: Record "NPR NaviPartner API Key")
    var
        NPAPIKey2: Record "NPR NaviPartner API Key";
    begin
        NPAPIKey2.LockTable();
        NPAPIKey2.Get(NPAPIKey.Id);
        ChangeStatus(NPAPIKey2, "NPR NP API Key Status"::Active, FailedToActivateApiKeyErr);
    end;

    procedure SynchronizeApiKeyPermissionsToEntraApps(NPAPIKeyId: Guid)
    var
        NPAPIKey: Record "NPR NaviPartner API Key";
    begin
        NPAPIKey.Get(NPAPIKeyId);
        SynchronizeApiKeyPermissionsToEntraApps(NPAPIKey);
    end;

    procedure SynchronizeApiKeyPermissionsToEntraApps(NPAPIKey: Record "NPR NaviPartner API Key")
    var
        EntraApp: Record "AAD Application";
        NPAPIKeyPermission: Record "NPR NaviPartner API Key Perm.";
        EntraAppMgt: Codeunit "NPR AAD Application Mgt.";
        PermissionSets: List of [Code[20]];
    begin
        EntraApp.Reset();
        EntraApp.SetRange("NPR NaviPartner API Key Id", NPAPIKey.Id);
        if (not EntraApp.FindFirst()) then
            exit;

        NPAPIKeyPermission.Reset();
        NPAPIKeyPermission.SetRange("NPR NP API Key Id", NPAPIKey.Id);
        if (not NPAPIKeyPermission.FindSet()) then
            Error(AtLeastOnePermissionSetMustBeAssignedForSyncErr);

        Clear(PermissionSets);
        repeat
            PermissionSets.Add(NPAPIKeyPermission."Permission Set ID");
        until (NPAPIKeyPermission.Next() = 0);

        repeat
            EntraAppMgt.SynchronizeEntraAppPermissionSets(EntraApp, true, PermissionSets);
        until (EntraApp.Next() = 0);
    end;

    local procedure ChangeStatus(var NPAPIKey: Record "NPR NaviPartner API Key"; NewStatus: Enum "NPR NP API Key Status"; ErrorMessage: Text)
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
        TenantId: Text;
    begin
        TenantId := GetTenantIdAsString();
        JsonBody.Add('tenantId', TenantId);
        JsonBody.Add('status', Format(NewStatus, 0, 1).ToLower());
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
            if (not ResponseMsg.Content.ReadAs(ResponseBody)) then
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

    [NonDebuggable]
    procedure RegisterEntraAppAndCredentials(NPAPIKey: Record "NPR NaviPartner API Key")
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
        ConsentGranted: Boolean;
        ErrorsFound: List of [Text];
        ErrorFound: Text;
        EntraAppNotCreatedErr: Label 'Entra ID application could not be created. The invoked actions and results are: ';
        EntraAppNotCreatedFurtherDetailsErr: Label 'The following errors were encountered during the creation of the Entra ID application: ';
        CreateNewEntraAppErrorBuilder: TextBuilder;
    begin
        TestValidPermissionSetsAssigned(NPAPIKey);

        CreateNewEntraAppInAzure(GetEntraAppName(NPAPIKey.Description), 'Primary', GetNPAPIKeyPermissions(NPAPIKey), ApplicationId, ClientID, ClientSecret, ConsentGranted, ErrorsFound);

        if ((IsNullGuid(ClientID)) or (ClientSecret = '') or (not ConsentGranted)) then begin
            CreateNewEntraAppErrorBuilder.AppendLine(EntraAppNotCreatedErr);
            CreateNewEntraAppErrorBuilder.AppendLine(StrSubstNo(' - Client ID created: %1', (not (IsNullGuid(ClientID)))));
            CreateNewEntraAppErrorBuilder.AppendLine(StrSubstNo(' - Client Secret created: %1', (ClientSecret <> '')));
            CreateNewEntraAppErrorBuilder.AppendLine(StrSubstNo(' - Consent granted: %1', ConsentGranted));
            CreateNewEntraAppErrorBuilder.AppendLine('');

            if (ErrorsFound.Count() > 0) then begin
                CreateNewEntraAppErrorBuilder.AppendLine(EntraAppNotCreatedFurtherDetailsErr);
                foreach ErrorFound in ErrorsFound do
                    CreateNewEntraAppErrorBuilder.AppendLine(StrSubstNo(' - %1', ErrorFound));
            end;

            Error(CreateNewEntraAppErrorBuilder.ToText());
        end;

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
            if (not ResponseMsg.Content.ReadAs(ResponseBody)) then
                ResponseBody := '';
            Error(FailedToRegisterEntraAppErr, ResponseMsg.HttpStatusCode, ResponseBody);
        end;

        AADApplication.Get(ClientID);
        AADApplication.Validate("NPR NaviPartner API Key Id", NPAPIKey.Id);
        AADApplication.Modify(true);
    end;

    internal procedure RemoveEntraApp(var NPAPIKey: Record "NPR NaviPartner API Key"; var EntraApp: Record "AAD Application")
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        ResponseBody: Text;
    begin
        EntraApp.LockTable();

        NPAPIKey.TestField(Id);
        EntraApp.TestField("NPR NaviPartner API Key Id", NPAPIKey.Id);

        RequestMsg.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Authorization', GetApiAuthHeader());

        RequestMsg.SetRequestUri(GetWorkerBaseUrl() + '/entra-apps/' + GetGuidAsString(EntraApp."Client Id"));
        RequestMsg.Method := 'DELETE';
        HttpClient.Send(RequestMsg, ResponseMsg);

        if (not ResponseMsg.IsSuccessStatusCode) then begin
            if (not ResponseMsg.Content.ReadAs(ResponseBody)) then
                ResponseBody := '';
            Error(FailedToRemoveEntraAppErr, ResponseMsg.HttpStatusCode, ResponseBody);
        end;

        EntraApp.Delete(true);
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

    local procedure GetNPAPIKeyPermissions(NPAPIKey: Record "NPR NaviPartner API Key"): List of [Code[20]]
    var
        NPAPIKeyPermission: Record "NPR NaviPartner API Key Perm.";
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
        var ApplicationId: Guid; var ClientID: Guid; var ClientSecret: Text; var ConsentGranted: Boolean; var ErrorsFound: List of [Text])
    var
        EntraAppMgt: Codeunit "NPR AAD Application Mgt.";
    begin
        EntraAppMgt.SetSilent(true);
        EntraAppMgt.CreateAzureADApplicationAndSecret(AppDisplayName, SecretDisplayName, PermissionSets);
        EntraAppMgt.GetApplicationIDAndSecret(ClientID, ClientSecret);
        ApplicationId := EntraAppMgt.GetApplicationId();
        ConsentGranted := EntraAppMgt.GetConsentGranted();
        EntraAppMgt.GetErrorMessages(ErrorsFound);
    end;

    local procedure TestValidPermissionSetsAssigned(NPAPIKey: Record "NPR NaviPartner API Key")
    var
        NPAPIKeyPermission: Record "NPR NaviPartner API Key Perm.";
    begin
        NPAPIKeyPermission.Reset();
        NPAPIKeyPermission.SetRange("NPR NP API Key Id", NPAPIKey.Id);
        if NPAPIKeyPermission.IsEmpty() then
            Error(AtLeastOnePermissionSetMustBeAssignedErr);
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


    [EventSubscriber(ObjectType::Table, Database::"NPR NaviPartner API Key Perm.", OnAfterInsertEvent, '', false, false)]
    local procedure NPRNPAPIKeyPermissionOnAfterInsertEvent(var Rec: Record "NPR NaviPartner API Key Perm.")
    begin
        if (Rec.IsTemporary()) then
            exit;

        SynchronizeApiKeyPermissionsToEntraApps(Rec."NPR NP API Key Id");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NaviPartner API Key Perm.", OnAfterDeleteEvent, '', false, false)]
    local procedure NPRNPAPIKeyPermissionOnAfterDeleteEvent(var Rec: Record "NPR NaviPartner API Key Perm.")
    begin
        if (Rec.IsTemporary()) then
            exit;

        SynchronizeApiKeyPermissionsToEntraApps(Rec."NPR NP API Key Id");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NaviPartner API Key Perm.", OnAfterRenameEvent, '', false, false)]
    local procedure NPRNPAPIKeyPermissionOnAfterRenameEvent(var Rec: Record "NPR NaviPartner API Key Perm.")
    begin
        if (Rec.IsTemporary()) then
            exit;

        SynchronizeApiKeyPermissionsToEntraApps(Rec."NPR NP API Key Id");
    end;
}
#endif
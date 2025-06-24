codeunit 6060060 "NPR AAD Application Mgt."
{
    Access = Internal;

    var
        BadApiResponseErr: Label 'Received a bad response from the API.\Status Code: %1 - %2\Body: %3', Comment = '%1 = status code, %2 = reason phrase, %3 = body';
        CreatedAzureADAppSuccessMsg: Label 'Successfully created Entra ID application with the following details:\\Client ID: %1\Client Secret: %2\Tenant ID: %3\\The secret expires at: %4\\NOTE! The secret cannot be seen after this message is closed. Copy it to a safe place.\\Remember to grant admin consent to the app before use if you haven''t already done this.', Comment = '%1 = client id, %2 = client secret, %3 = entra id tenant id, %4 = expiration date';
        CreateAADAppCreationOfSecretFailedMsg: Label 'Successfully created Entra ID application, but FAILED to create a secret.\\Client ID: %1\Tenant ID: %2', Comment = '%1 = client id, %2 = entra id tenant id';
        CreatedSecretMsg: Label 'Created secret for Entra ID App. Details:\\Client ID: %1\Client Secret: %2\Tenant ID: %3\\Expires: %4\\NOTE! The secret cannot be seen after this message is closed. Copy it to a safe place.', Comment = '%1 = client id, %2 = client secret, %3 = entra id tenant id, %4 = expiration date';
        CouldNotCreateAADAppErr: Label 'Could not create Entra ID App with the Microsoft Graph API.\\Error message: %1', Comment = '%1 = error message';
        CouldNotCreateSecretErr: Label 'Could not create secret. Error message was:\\%1';
        MissingPermissionsErr: Label 'You need to have write permission to both %1 and %2. If you do not have access to manage users and Entra ID Applications, you cannot perform this action', Comment = '%1 = table caption of "AAD Application", %2 = table caption of "Access Control"';
        ResponseMalformedValueNotArrayOrObjectErr: Label 'The response from the Graph API is malformed. Expected "value" to be either an array or an object, but it is neither.\\Response: %1', Comment = '%1 = response body';
        NoAzureADRegisteredErr: Label 'System was not able to acquire the Entra ID Tenant ID. This is required to be able to get an access token.';
        CouldNotGetAccessTokenErr: Label 'Unable to get an access token to Microsoft''s Graph API.\\Error message: %1', Comment = '%1 = error message';
        UserDoestNotExistErr: Label 'The user associated with the Entra ID App (%1) does not exist. System cannot assign permissions. Before the app can be used, make sure to create the user and assign appropriate permissions', Comment = '%1 = Entra ID App Client ID';
        CouldNotFindObjectIdFromAppIdErr: Label 'Could not find Entra ID App Object ID from the given Entra ID App ID (%1)', Comment = '%1 = Entra ID App ID';
        GrantConsentQst: Label 'Before being able to use the newly created app it requires admin consent to be granted. Do you want to do that now?';
        ErrorDuringAppConsentErr: Label 'An error occurred while giving consent to the Entra ID app.\\Error message: %1', Comment = '%1 = error message';
        ConsentFailedErr: Label 'Failed to give consent.';
        WaitingForAppToBeReadyMsg: Label 'Waiting for the Entra ID App to be ready for approval...';
        ParameterValueEmptyErr: Label '%1 cannot be blank.', Comment = '%1 = name of the parameter that was evaluated.';
        FindExistingEntraAppsErr: Label 'An error occurred while searching for existing Entra apps with DisplayName = %1 in Entra directory. Error message was:\\%2', Comment = '%1 = name of the application, %2 = error message.';
        ExistingAppRegisteredOnlyMsg: Label 'The Entra application %1 has already been found in the Entra directory, so it was only registered in Business Central.', Comment = '%1 = name of the application';
        EntraAppRegenerateQst: Label 'Do you want to regenerate secret for the Microsoft Entra Application %1?', Comment = '%1 = Application Name; Do not translate Microsoft Entra Application.';
        [NonDebuggable]
        _AccessToken: Text;
        _AccessTokenExpiry: DateTime;
        _ClientID: Guid;
        [NonDebuggable]
        _ClientSecret: Text;
        _Silent: Boolean;

    internal procedure CreateAzureADApplicationAndSecret(AppDisplayName: Text[50]; SecretDisplayName: Text; PermissionSets: List of [Code[20]])
    var
        AppJson: JsonObject;
        BufferToken: JsonToken;
        ApplicationId: Text;
        ApplicationObjectId: Text;
        ErrorTxt: Text;
        Secret: Text;
        Expires: DateTime;
        AzureADTenant: Codeunit "Azure AD Tenant";
        Window: Dialog;
        ExistingAppsArray: JsonArray;
        ExistingAppToken: JsonToken;
        ClientGuid: Guid;
        AttemptNo: Integer;
        Success: Boolean;
    begin
        if (not TryFindExistingAppsWithSameDisplayNameInEntra(AppDisplayName, ExistingAppsArray)) then begin
            Error(FindExistingEntraAppsErr, AppDisplayName, GetLastErrorText())
        end;

        if (ExistingAppsArray.Count = 0) then begin
            // Create new application, try to grant consent and register in BC:
            AppJson := CreateAzureADApplication(AppDisplayName, PermissionSets);

            AppJson.SelectToken('appId', BufferToken);
            ApplicationId := BufferToken.AsValue().AsText();

            AppJson.SelectToken('id', BufferToken);
            ApplicationObjectId := BufferToken.AsValue().AsText();

            if (Confirm(GrantConsentQst, true)) then begin
                // Azure is really slow to actually recognize the new app,
                // so we sleep here to ensure that it's ready for approval.
                Window.Open(WaitingForAppToBeReadyMsg);
                AttemptNo := 0;
                repeat
                    Sleep(20000);
                    Success := TryGrantConsentToApp(ApplicationId, AzureADTenant.GetAadTenantId(), ErrorTxt);
                    AttemptNo := AttemptNo + 1;
                until Success or (AttemptNo >= 3);
                Window.Close();
                if not Success then
                    Message(ErrorDuringAppConsentErr, ErrorTxt);
            end;

            if (TryCreateAzureADSecret(ApplicationObjectId, SecretDisplayName, Secret, Expires)) then begin
                _ClientID := ApplicationId;
                _ClientSecret := Secret;
                if not _Silent then
                    Message(CreatedAzureADAppSuccessMsg, ApplicationId, Secret, AzureADTenant.GetAadTenantId(), Expires);
            end else
                Message(CreateAADAppCreationOfSecretFailedMsg, ApplicationId, AzureADTenant.GetAadTenantId());
        end else begin
            // Use an existing application (the first one - ideally we should try to find an app with consent already granted or let the user select one) and register in BC:
            ExistingAppsArray.Get(0, ExistingAppToken);

            AppJson := ExistingAppToken.AsObject();
            ExistingAppToken.SelectToken('appId', BufferToken);
            ClientGuid := BufferToken.AsValue().AsText();

            RegisterAzureADApplication(ClientGuid, AppDisplayName, PermissionSets);

            Message(ExistingAppRegisteredOnlyMsg, AppDisplayName);
        end;
    end;

    internal procedure CreateAzureADSecret(ApplicationId: Guid; DisplayName: Text)
    var
        Secret: Text;
        Expires: DateTime;
        AzureADTenant: Codeunit "Azure AD Tenant";
        ApplicationObjectId: Guid;
    begin
        ClearLastError();

        if (not TryGetAzureAppObjectIdFromAppId(ApplicationId, ApplicationObjectId)) then
            Error(CouldNotFindObjectIdFromAppIdErr, ApplicationId);

        if (not TryCreateAzureADSecret(ApplicationObjectId, DisplayName, Secret, Expires)) then
            Error(CouldNotCreateSecretErr, GetLastErrorText());

        if not _Silent then
            Message(CreatedSecretMsg, LowerCase(DelChr(ApplicationId, '=', '{}')), Secret, AzureADTenant.GetAadTenantId(), Expires);
    end;

    internal procedure RegenerateEntraAppSecret(var EntraApp: Record "AAD Application"; WithConfirmDialog: Boolean)
    begin
        EntraApp.TestField("Client Id");
        EntraApp.TestField(Description);

        if not Confirm(EntraAppRegenerateQst, false, EntraApp.Description) then begin
            Error('');
        end;

        CreateAzureADSecret(EntraApp."Client Id", StrSubstNo('%1 - %2', EntraApp.Description, Format(CurrentDateTime, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>')));
    end;

    local procedure CreateAzureADApplication(DisplayName: Text[50]; PermissionSets: List of [Code[20]]) AppJson: JsonObject
    var
        ClientGuid: Guid;
        BufferToken: JsonToken;
    begin
        CheckPermissions();

        if (not TryCreateAzureADApplication(DisplayName, AppJson)) then
            Error(CouldNotCreateAADAppErr, GetLastErrorText());

        AppJson.SelectToken('appId', BufferToken);
        ClientGuid := BufferToken.AsValue().AsText();

        RegisterAzureADApplication(ClientGuid, DisplayName, PermissionSets);
    end;

    internal procedure RegisterAzureADApplication(ClientID: Guid; DisplayName: Text[50]; PermissionSets: List of [Code[20]])
    var
        AADApplication: Record "AAD Application";
        User: Record User;
        AADApplicationInterface: Codeunit "AAD Application Interface";
        AppInfo: ModuleInfo;
        PermSet: Code[20];
    begin
        CheckPermissions();
        NavApp.GetCurrentModuleInfo(AppInfo);

        AADApplicationInterface.CreateAADApplication(
            ClientID,
            DisplayName,
            CopyStr(AppInfo.Publisher, 1, 50),
            true
        );

        AADApplication.Get(ClientID);
        AADApplication."App ID" := AppInfo.Id;
        AADApplication."App Name" := CopyStr(AppInfo.Name, 1, MaxStrLen(AADApplication."App Name"));
        AADApplication.Modify();
        Commit();

        if (not User.Get(AADApplication."User ID")) then
            Error(UserDoestNotExistErr, AADApplication."Client Id");

        foreach PermSet in PermissionSets do
            AddPermissionSet(AADApplication."User ID", PermSet);

        Commit();
    end;

    [NonDebuggable]
    internal procedure GetApplicationIDAndSecret(var ClientID: Guid; var ClientSecret: Text)
    begin
        ClientID := _ClientID;
        ClientSecret := _ClientSecret;
    end;

    internal procedure SetSilent(Silent: Boolean)
    begin
        _Silent := Silent;
    end;

    local procedure CheckPermissions()
    var
        AADApplication: Record "AAD Application";
        AccessControl: Record "Access Control";
    begin
        if not (AADApplication.WritePermission() and AccessControl.WritePermission()) then
            Error(MissingPermissionsErr, AADApplication.TableCaption(), AccessControl.TableCaption());
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure TryCreateAzureADApplication(DisplayName: Text; var AppJson: JsonObject)
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        Request: Text;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        RedirectUrl: Text;
    begin
        RedirectUrl := GetRedirectUrl();

        // This will let the app request permissions to interact with BC
        //
        // The following Business Central permissions are represented by the UUIDs:
        // - API.ReadWrite.All
        // - Automation.ReadWrite.All
        Request := '{' +
                        '"displayName":"' + DisplayName + '",' +
                        '"signInAudience": "AzureADMyOrg",' +
                        '"requiredResourceAccess":[{"resourceAppId":"996def3d-b36c-4153-8607-a6fd3c01b89f","resourceAccess":[{"id":"a42b0b75-311e-488d-b67e-8fe84f924341","type":"Role"},{"id":"d365bc00-a990-0000-00bc-160000000001","type":"Role"}]}],' +
                        '"web":{"redirectUris":["' + RedirectUrl + '"]}' +
                    '}';

        Content.WriteFrom(Request);

        Content.GetHeaders(ContentHeaders);
        if (ContentHeaders.Contains('Content-Type')) then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        Client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + GetGraphAccessToken());
        Client.Post('https://graph.microsoft.com/v1.0/applications', Content, ResponseMsg);

        ResponseMsg.Content.ReadAs(ResponseTxt);

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), ResponseTxt);

        AppJson.ReadFrom(ResponseTxt);
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure TryFindExistingAppsWithSameDisplayNameInEntra(DisplayName: Text; var ExistingApps: JsonArray)
    var
        Client: HttpClient;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        RedirectUrl: Text;
        ResponseToken: JsonToken;
        ValueToken: JsonToken;
    begin
        if (DisplayName = '') then begin
            Error(ParameterValueEmptyErr, 'DisplayName');
        end;

        Clear(ExistingApps);

        RedirectUrl := GetRedirectUrl();

        Client.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + GetGraphAccessToken());
        Client.DefaultRequestHeaders.Add('ConsistencyLevel', 'eventual');
        Client.Get(StrSubstNo('https://graph.microsoft.com/v1.0/applications?$filter=displayName eq ''%1''', DisplayName), ResponseMsg);

        ResponseMsg.Content.ReadAs(ResponseTxt);

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), ResponseTxt);

        ResponseToken.ReadFrom(ResponseTxt);

        ResponseToken.SelectToken('value', ValueToken);
        ExistingApps := ValueToken.AsArray();
    end;

    internal procedure TryGrantConsentToApp(ClientId: Guid; TenantId: Text; var PermissionGrantErrorTxt: Text): Boolean
    var
        AADApplication: Record "AAD Application";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        OAuth2: Codeunit OAuth2;
        OAuthAuthorityUrl: Text;
        Success: Boolean;
    begin
        Clear(PermissionGrantErrorTxt);
        ClearLastError();
        OAuthAuthorityUrl := StrSubstNo('https://login.microsoftonline.com/%1/adminconsent', TenantId);
        if not OAuth2.RequestClientCredentialsAdminPermissions(GraphMgtGeneralTools.StripBrackets(Format(ClientId)), OAuthAuthorityUrl, '', Success, PermissionGrantErrorTxt) then
            PermissionGrantErrorTxt := GetLastErrorText()
        else
            if Success then begin
                if AADApplication.Get(ClientId) then begin
                    AADApplication."Permission Granted" := True;
                    AADApplication.Modify();
                end;
                exit(true);
            end;
        if PermissionGrantErrorTxt = '' then
            PermissionGrantErrorTxt := ConsentFailedErr;
        exit(false);
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure TryCreateAzureADSecret(ApplicationObjectId: Guid; DisplayName: Text; var Secret: Text; var Expires: DateTime)
    var
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        ResponseMsg: HttpResponseMessage;
        Request: Text;
        Response: Text;
        JToken: JsonToken;
        ExpiresToken: JsonToken;
        SecretToken: JsonToken;
        ExpirationDateTimeString: Text;
    begin
        ExpirationDateTimeString := GetFormattedDateInNumberOfYears(100);
        Request := StrSubstNo('{"passwordCredential":{"displayName":"%1", "endDateTime": "%2"}}', DisplayName, ExpirationDateTimeString);
        Content.WriteFrom(Request);

        Content.GetHeaders(ContentHeaders);
        if (ContentHeaders.Contains('Content-Type')) then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');

        Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + GetGraphAccessToken());
        Client.Post(StrSubstNo('https://graph.microsoft.com/v1.0/applications/%1/addPassword', DelChr(ApplicationObjectId, '=', '{}')), Content, ResponseMsg);

        ResponseMsg.Content().ReadAs(Response);

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), Response);

        JToken.ReadFrom(Response);
        JToken.SelectToken('endDateTime', ExpiresToken);
        JToken.SelectToken('secretText', SecretToken);

        Secret := SecretToken.AsValue().AsText();
        Expires := ExpiresToken.AsValue().AsDateTime();
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure TryGetAzureAppObjectIdFromAppId(AppId: Guid; var ObjectId: Guid)
    var
        Client: HttpClient;
        ResponseMsg: HttpResponseMessage;
        ResponseTxt: Text;
        ResponseToken: JsonToken;
        ValueToken: JsonToken;
        IdToken: JsonToken;
    begin
        Client.DefaultRequestHeaders().Add('Authorization', 'Bearer ' + GetGraphAccessToken());
        Client.Get(StrSubstNo('https://graph.microsoft.com/v1.0/applications?$filter=appId eq ''%1''', DelChr(AppId, '=', '{}')), ResponseMsg);

        ResponseMsg.Content().ReadAs(ResponseTxt);

        if (not ResponseMsg.IsSuccessStatusCode()) then
            Error(BadApiResponseErr, ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), ResponseTxt);

        ResponseToken.ReadFrom(ResponseTxt);
        ResponseToken.SelectToken('$.value', ValueToken);

        case true of
            ValueToken.IsObject():
                ValueToken.SelectToken('id', IdToken);
            ValueToken.IsArray():
                ResponseToken.SelectToken('$.value[0].id', IdToken);
            else
                Error(ResponseMalformedValueNotArrayOrObjectErr, ResponseTxt);
        end;

        ObjectId := IdToken.AsValue().AsText();
    end;

    [NonDebuggable]
    local procedure GetGraphAccessToken(): Text
    var
        i: Integer;
        RedirectURL: Text;
        AccessToken: Text;
        TokenParts: List of [Text];
        AuthCodeErr: Text;
        AccessTokenJson: JsonToken;
        ExpiryToken: JsonToken;
        ExpiryBigInt: BigInteger;
        TxtBuffer: Text;
        Remainder: Integer;
        KeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        ClientId: Text;
        ClientSecret: Text;
        AADTenantId: Text;
        Convert: Codeunit "Base64 Convert";
        TypeHelper: Codeunit "Type Helper";
        Scope: Text;
        EncodedScope: Text;
        AzureADTenant: Codeunit "Azure AD Tenant";
        NPROAuthControlAddIn: Page "NPR OAuth ControlAddIn";
        URLText: Text;
        AuthCode: Text;
        State: Integer;
    begin
        if (_AccessToken <> '') and (_AccessTokenExpiry > CurrentDateTime()) then
            exit(_AccessToken);

        AADTenantId := AzureADTenant.GetAadTenantId();
        if (AADTenantId = '') then
            Error(NoAzureADRegisteredErr);

        RedirectURL := GetRedirectUrl();

        ClientId := KeyVaultMgt.GetAzureKeyVaultSecret('AzureADAppMgtClientId');
        ClientSecret := KeyVaultMgt.GetAzureKeyVaultSecret('AzureADAppMgtClientSecret');

        State := Random(10000);
        Scope := 'https://graph.microsoft.com/Application.ReadWrite.All';
        EncodedScope := TypeHelper.UrlEncode(Scope);
        URLText := StrSubstNo('https://login.microsoftonline.com/%1/oauth2/v2.0/authorize?client_id=%2&redirect_uri=%3&state=%4&response_type=code&scope=%5&actor=application', AADTenantId, ClientId, RedirectURL, State, EncodedScope);
        NPROAuthControlAddIn.SetRequestProps(URLText);
        NPROAuthControlAddIn.RunModal();
        AuthCode := NPROAuthControlAddIn.GetAuthCode();
        AuthCodeErr := NPROAuthControlAddIn.GetAuthError();
        NPROAuthControlAddIn.RequestToken(AuthCode, RedirectURL, ClientId, ClientSecret, AccessToken);

        if (AccessToken = '') or (AuthCodeErr <> '') then
            Error(CouldNotGetAccessTokenErr, AuthCodeErr);

        // Access tokens are JWT containing the expiry
        TokenParts := AccessToken.Split('.');
        if (not TokenParts.Get(2, TxtBuffer)) then begin
            Clear(_AccessToken);
            Clear(_AccessTokenExpiry);
            exit(AccessToken);
        end;

        // Ensure token part has proper length for base64 decode
        Remainder := (4 - (StrLen(TxtBuffer) mod 4));
        if (not (Remainder = 4)) then
            for i := 1 to Remainder do
                TxtBuffer := TxtBuffer + '=';

        if (AccessTokenJson.ReadFrom(Convert.FromBase64(TxtBuffer)) and
                AccessTokenJson.SelectToken('exp', ExpiryToken) and
                TryGetJValue(ExpiryToken, ExpiryBigInt)) then
            _AccessTokenExpiry := TypeHelper.EvaluateUnixTimestamp(ExpiryBigInt)
        else
            // We couldn't read the expiry from the token. Assuming it to be one hour
            // which is the lowest possible value at the time of developing this code.
            // https://learn.microsoft.com/en-us/azure/active-directory/develop/active-directory-configurable-token-lifetimes#access-tokens
            _AccessTokenExpiry := CurrentDateTime() + (60 * 60 * 1000);

        _AccessToken := AccessToken;
        exit(_AccessToken);
    end;

    local procedure GetRedirectUrl() RedirectURL: Text
    var
#if not BC1700
        OAuth2: Codeunit OAuth2;
#endif
    begin
#if BC1700
        RedirectURL := GetUrl(ClientType::Web);
        if (RedirectURL[StrLen(RedirectURL)] <> '/') then
            RedirectURL += '/';
        RedirectURL += 'OAuthLandingPage.htm';
#else
        OAuth2.GetDefaultRedirectURL(RedirectURL);
#endif
    end;

    local procedure AddPermissionSet(UserSecurityId: Guid; PermissionSetId: Code[20])
    var
        AccessControl: Record "Access Control";
        AggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityId);
        AccessControl.SetRange("Role ID", PermissionSetId);
        if (not AccessControl.IsEmpty()) then
            exit;

        AggregatePermissionSet.SetRange("Role ID", PermissionSetId);
        AggregatePermissionSet.FindFirst();

        AccessControl.Init();
        AccessControl."User Security ID" := UserSecurityId;
        AccessControl."Role ID" := PermissionSetId;
        AccessControl.Scope := AggregatePermissionSet.Scope;
        AccessControl."App ID" := AggregatePermissionSet."App ID";
        AccessControl.Insert(true);
    end;

    [TryFunction]
    local procedure TryGetJValue(Token: JsonToken; var BigInt: BigInteger)
    begin
        BigInt := Token.AsValue().AsBigInteger();
    end;

    local procedure GetFormattedDateInNumberOfYears(NumberOfYears: Integer) Result: Text
    var
        FutureDate: Date;
        FutureDateTime: DateTime;
    begin
        FutureDate := CalcDate(StrSubstNo('<+%1Y>', NumberOfYears), Today);
        FutureDateTime := CreateDateTime(FutureDate, 0T);
        Result := Format(FutureDateTime, 0, '<Standard Format,9>');
    end;
}
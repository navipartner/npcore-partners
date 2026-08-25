codeunit 6014462 "NPR Web Service Auth. Helper"
{
    Access = Internal;

    #region FieldsVisibility
    procedure SetAuthenticationFieldsVisibility(AuthType: Enum "NPR API Auth. Type"; var IsBasicAuthVisible: Boolean)
    begin
        IsBasicAuthVisible := false;
        BasicAuthVisible(AuthType, IsBasicAuthVisible);
    end;

    procedure SetAuthenticationFieldsVisibility(AuthType: Enum "NPR API Auth. Type"; var IsBasicAuthVisible: Boolean; var IsOAuth2Visible: Boolean)
    begin
        IsOAuth2Visible := false;
        SetAuthenticationFieldsVisibility(AuthType, IsBasicAuthVisible);
        if not IsBasicAuthVisible then
            OAuth2Visible(AuthType, IsOAuth2Visible);
    end;

    procedure SetAuthenticationFieldsVisibility(AuthType: Enum "NPR API Auth. Type"; var IsBasicAuthVisible: Boolean; var IsOAuth2Visible: Boolean; var IsCustomAuthVisible: Boolean)
    var
    begin
        IsCustomAuthVisible := false;
        SetAuthenticationFieldsVisibility(AuthType, IsBasicAuthVisible, IsOAuth2Visible);
        If (not IsBasicAuthVisible) And (not IsOAuth2Visible) then
            CustomAuthVisible(AuthType, IsCustomAuthVisible);
    end;

    procedure SetAuthenticationFieldsVisibility(AuthType: Enum "NPR API Auth. Type"; var IsBasicAuthVisible: Boolean; var IsOAuth2Visible: Boolean; var IsCustomAuthVisible: Boolean; var IsNPApiKeyVisible: Boolean)
    var
    begin
        IsNPApiKeyVisible := false;
        SetAuthenticationFieldsVisibility(AuthType, IsBasicAuthVisible, IsOAuth2Visible, IsCustomAuthVisible);
        if (not IsBasicAuthVisible) and (not IsOAuth2Visible) and (not IsCustomAuthVisible) then
            NPApiKeyVisible(AuthType, IsNPApiKeyVisible);
    end;


    procedure BasicAuthVisible(AuthType: Enum "NPR API Auth. Type"; var IsBasicAuthVisible: Boolean): Boolean
    var
        iAuth: Interface "NPR API IAuthorization";
    begin
        iAuth := AuthType;
        IsBasicAuthVisible := iAuth.IsEnabled(Format(AuthType), Format(AuthType::Basic));
    end;

    procedure OAuth2Visible(AuthType: Enum "NPR API Auth. Type"; var IsOAuth2Visible: Boolean): Boolean
    var
        iAuth: Interface "NPR API IAuthorization";
    begin
        iAuth := AuthType;
        IsOAuth2Visible := iAuth.IsEnabled(Format(AuthType), Format(AuthType::OAuth2));
    end;

    procedure CustomAuthVisible(AuthType: Enum "NPR API Auth. Type"; var IsCustomAuthVisible: Boolean): Boolean
    var
        iAuth: Interface "NPR API IAuthorization";
    begin
        iAuth := AuthType;
        IsCustomAuthVisible := iAuth.IsEnabled(Format(AuthType), Format(AuthType::Custom));
    end;

    procedure NPApiKeyVisible(AuthType: Enum "NPR API Auth. Type"; var IsNPApiKeyVisible: Boolean): Boolean
    var
        iAuth: Interface "NPR API IAuthorization";
    begin
        iAuth := AuthType;
        IsNPApiKeyVisible := iAuth.IsEnabled(Format(AuthType), Format(AuthType::"NP API Key"));
    end;
    #endregion

    #region Basic API Password Key
    [NonDebuggable]
    procedure SetApiPassword(NewPassword: Text; var APIPassGUID: Guid);
    begin
        if IsNullGuid(APIPassGUID) then
            APIPassGUID := CreateGuid();

        if not EncryptionEnabled() then
            IsolatedStorage.Set(APIPassGUID, NewPassword, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(APIPassGUID, NewPassword, DataScope::Company);
    end;

    [NonDebuggable]
    procedure SetLongApiPassword(NewPassword: Text; var APIPassGUID: Guid);
    var
        MaxEncryptableLength: Integer;
    begin
        // IsolatedStorage.SetEncrypted uses RSA, which cannot encrypt plaintext longer than the key
        // permits (~215 bytes for a 2048-bit key). Secrets that may exceed that (e.g. JWT API keys)
        // are stored unencrypted; isolated storage is still tenant/company-isolated and encrypted at
        // rest by the platform. Kept separate from SetApiPassword so short-secret callers keep their
        // strict encryption behaviour. Threshold is a conservative bound below the RSA limit.
        MaxEncryptableLength := 150;

        if IsNullGuid(APIPassGUID) then
            APIPassGUID := CreateGuid();

        if not EncryptionEnabled() or (StrLen(NewPassword) > MaxEncryptableLength) then
            IsolatedStorage.Set(APIPassGUID, NewPassword, DataScope::Company)
        else
            IsolatedStorage.SetEncrypted(APIPassGUID, NewPassword, DataScope::Company);
    end;

    [NonDebuggable]
    procedure GetApiPassword(APIPassGUID: Guid) PasswordValue: Text
    begin
        if not IsNullGuid(APIPassGUID) then
            if IsolatedStorage.Get(APIPassGUID, DataScope::Company, PasswordValue) then;
    end;

    procedure HasApiPassword(APIPassGUID: Guid): Boolean
    begin
        exit(GetApiPassword(APIPassGUID) <> '');
    end;

    procedure RemoveApiPassword(var APIPassGUID: Guid)
    begin
        IsolatedStorage.Delete(APIPassGUID, DataScope::Company);
        Clear(APIPassGUID);
    end;
    #endregion

    #region Authorization Parameters Buffer
    procedure GetBasicAuthorizationParamsBuff(BasicUsername: Text[250]; BasicPasswordKey: Guid; var AuthorizationParamsBuffer: Record "NPR Auth. Param. Buffer")
    begin
        AuthorizationParamsBuffer.Init();
        AuthorizationParamsBuffer."Auth. Type" := AuthorizationParamsBuffer."Auth. Type"::Basic;
        AuthorizationParamsBuffer."Basic UserName" := BasicUsername;
        AuthorizationParamsBuffer."Basic Password Key" := BasicPasswordKey;
    end;

    procedure GetOpenAuthorizationParamsBuff(OAuthSetupCode: Code[20]; var AuthorizationParamsBuffer: Record "NPR Auth. Param. Buffer")
    begin
        AuthorizationParamsBuffer.Init();
        AuthorizationParamsBuffer."Auth. Type" := AuthorizationParamsBuffer."Auth. Type"::OAuth2;
        AuthorizationParamsBuffer."OAuth Setup Code" := OAuthSetupCode;
    end;

    procedure GetCustomAuthorizationParamsBuff(CustomAuthValue: Text[250]; var AuthorizationParamsBuffer: Record "NPR Auth. Param. Buffer")
    begin
        AuthorizationParamsBuffer.Init();
        AuthorizationParamsBuffer."Auth. Type" := AuthorizationParamsBuffer."Auth. Type"::Custom;
        AuthorizationParamsBuffer."Custom Auth." := CustomAuthValue;
    end;

    procedure GetNPApiKeyAuthorizationParamsBuff(NPApiKeySetupCode: Code[20]; var AuthorizationParamsBuffer: Record "NPR Auth. Param. Buffer")
    begin
        AuthorizationParamsBuffer.Init();
        AuthorizationParamsBuffer."Auth. Type" := AuthorizationParamsBuffer."Auth. Type"::"NP API Key";
        AuthorizationParamsBuffer."NP API Key Setup Code" := NPApiKeySetupCode;
    end;

    #endregion
}

codeunit 6014462 "NPR Web Service Auth. Helper"
{

    #region FieldsVisibility
    procedure SetAuthenticationFieldsVisibility(AuthType: Enum "NPR API Auth. Type"; var IsBasicAuthVisible: Boolean; var IsOAuth2Visible: Boolean)
    begin
        IsBasicAuthVisible := false;
        IsOAuth2Visible := false;
        BasicAuthVisible(AuthType, IsBasicAuthVisible);
        if not IsBasicAuthVisible then
            OAuth2Visible(AuthType, IsOAuth2Visible);
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
    procedure GetBasicAuthorizationParamsBuff(BasicUsername: Code[50]; BasicPasswordKey: Guid; var AuthorizationParamsBuffer: Record "NPR Auth. Param. Buffer")
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
    #endregion
}

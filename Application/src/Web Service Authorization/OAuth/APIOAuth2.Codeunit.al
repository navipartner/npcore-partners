codeunit 6014618 "NPR API OAuth2" implements "NPR API IAuthorization"
{

    Access = Internal;
    procedure IsEnabled(AuthTypeValue: Text; CompareAgainstValue: Text): Boolean
    begin
        exit(AuthTypeValue = CompareAgainstValue);
    end;

    [NonDebuggable]
    internal procedure GetAuthorizationValue(AuthParamBuff: Record "NPR Auth. Param. Buffer") AuthText: Text
    var
        NPROAuthSetup: Record "NPR OAuth Setup";
        AccessToken: Text;
        BearerTokenText: Label 'Bearer %1';
    begin
        NPROAuthSetup.Get(AuthParamBuff."OAuth Setup Code");
        AccessToken := NPROAuthSetup.GetOauthToken();
        AuthText := StrSubstNo(BearerTokenText, AccessToken);
    end;

    [NonDebuggable]
    procedure SetAuthorizationValue(var Headers: HttpHeaders; AuthParamsBuff: Record "NPR Auth. Param. Buffer")
    var
    begin
        if (Headers.Contains('Authorization')) then
            Headers.Remove('Authorization');

        Headers.Add('Authorization', GetAuthorizationValue(AuthParamsBuff))
    end;

    procedure CheckMandatoryValues(AuthParamBuff: Record "NPR Auth. Param. Buffer")
    var
        SettingIsMissingErr: Label 'Setting ''%1'' is missing.';
    begin
        if AuthParamBuff."OAuth Setup Code" = '' then
            Error(SettingIsMissingErr, 'OAuthSetupCode');
    end;
}

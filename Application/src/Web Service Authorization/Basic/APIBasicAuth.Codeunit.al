codeunit 6014609 "NPR API Basic Auth" implements "NPR API IAuthorization"
{
    Access = Internal;
    procedure IsEnabled(AuthTypeValue: Text; CompareAgainstValue: Text): Boolean
    begin
        exit(AuthTypeValue = CompareAgainstValue);
    end;

    [NonDebuggable]
    internal procedure GetAuthorizationValue(AuthParamBuff: Record "NPR Auth. Param. Buffer") AuthText: Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        StrSubStNoTextLbl1: Label '%1:%2', Locked = true;
        StrSubStNoTextLbl2: Label 'Basic %1', Locked = true;
    begin
        AuthText := StrSubstNo(StrSubStNoTextLbl1, AuthParamBuff."Basic UserName", WebServiceAuthHelper.GetApiPassword(AuthParamBuff."Basic Password Key"));
        AuthText := Base64Convert.ToBase64(AuthText);
        AuthText := StrSubstNo(StrSubStNoTextLbl2, AuthText);
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
        if AuthParamBuff."Basic UserName" = '' then
            Error(SettingIsMissingErr, 'BasicUserName');

        if IsNullGuid(AuthParamBuff."Basic Password Key") then
            Error(SettingIsMissingErr, 'BasicPassword');
    end;
}

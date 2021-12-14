codeunit 6014690 "NPR API Custom Auth" implements "NPR API IAuthorization"
{
    // will be defined in the caller object
    Access = Internal;
    procedure IsEnabled(AuthTypeValue: Text; CompareAgainstValue: Text): Boolean
    begin
        exit(AuthTypeValue = CompareAgainstValue);
    end;

    [NonDebuggable]
    internal procedure GetAuthorizationValue(AuthParamBuff: Record "NPR Auth. Param. Buffer") AuthText: Text
    var
    begin
        AuthText := AuthParamBuff."Custom Auth.";
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
        if AuthParamBuff."Custom Auth." = '' then
            Error(SettingIsMissingErr, 'CustomAuthorizationValue');
    end;
}

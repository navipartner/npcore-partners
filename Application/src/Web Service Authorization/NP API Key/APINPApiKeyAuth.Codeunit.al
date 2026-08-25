codeunit 6151248 "NPR API NP API Key Auth" implements "NPR API IAuthorization"
{
    Access = Internal;

    procedure IsEnabled(AuthTypeValue: Text; CompareAgainstValue: Text): Boolean
    begin
        exit(AuthTypeValue = CompareAgainstValue);
    end;

    [NonDebuggable]
    internal procedure GetAuthorizationValue(AuthParamBuff: Record "NPR Auth. Param. Buffer") AuthText: Text
    var
        NPApiKeySetup: Record "NPR NP API Key Setup";
    begin
        // Consumers always call CheckMandatoryValues immediately before this, so re-running the full
        // ladder here would just repeat the IsolatedStorage HasApiKey probe on hot loops. GetSetup
        // already loads the record, so honoring the Enabled kill-switch costs no extra I/O and holds
        // the invariant even for a future unpaired caller; the missing-setup guard lives in GetSetup.
        GetSetup(AuthParamBuff, NPApiKeySetup);
        NPApiKeySetup.TestField(Enabled);
        AuthText := NPApiKeySetup.GetApiKey();
    end;

    [NonDebuggable]
    procedure SetAuthorizationValue(var Headers: HttpHeaders; AuthParamsBuff: Record "NPR Auth. Param. Buffer")
    var
        HeaderNameLbl: Label 'x-np-api-key', Locked = true;
    begin
        if (Headers.Contains(HeaderNameLbl)) then
            Headers.Remove(HeaderNameLbl);

        Headers.Add(HeaderNameLbl, GetAuthorizationValue(AuthParamsBuff))
    end;

    procedure CheckMandatoryValues(AuthParamBuff: Record "NPR Auth. Param. Buffer")
    var
        NPApiKeySetup: Record "NPR NP API Key Setup";
        SettingIsMissingErr: Label 'Setting ''%1'' is missing.';
        SetupDisabledErr: Label 'The %1 ''%2'' is disabled.', Comment = '%1 = table caption, %2 = setup code';
        SetupHasNoKeyErr: Label 'The %1 ''%2'' has no %3 configured.', Comment = '%1 = table caption, %2 = setup code, %3 = API Key field caption';
    begin
        if AuthParamBuff."NP API Key Setup Code" = '' then
            Error(SettingIsMissingErr, 'NPApiKeySetupCode');

        GetSetup(AuthParamBuff, NPApiKeySetup);
        if not NPApiKeySetup.Enabled then
            Error(SetupDisabledErr, NPApiKeySetup.TableCaption(), NPApiKeySetup.Code);
        if not NPApiKeySetup.HasApiKey() then
            Error(SetupHasNoKeyErr, NPApiKeySetup.TableCaption(), NPApiKeySetup.Code, NPApiKeySetup.FieldCaption("API Key"));
    end;

    local procedure GetSetup(AuthParamBuff: Record "NPR Auth. Param. Buffer"; var NPApiKeySetup: Record "NPR NP API Key Setup")
    var
        SetupMissingErr: Label 'The %1 ''%2'' does not exist.', Comment = '%1 = table caption, %2 = setup code';
    begin
        if not NPApiKeySetup.Get(AuthParamBuff."NP API Key Setup Code") then
            Error(SetupMissingErr, NPApiKeySetup.TableCaption(), AuthParamBuff."NP API Key Setup Code");
    end;
}

codeunit 6014618 "NPR API OAuth2" implements "NPR API IAuthorization"
{

    Access = Internal;
    procedure IsEnabled(Rec: Variant; SearchForFieldName: Text; CompareAgainstValue: Text): Boolean
    var
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FieldReference: FieldRef;
    begin
        if not DataTypeMgt.GetRecordRef(Rec, RecRef) then
            exit;
        if not DataTypeMgt.FindFieldByName(RecRef, FieldReference, SearchForFieldName) then
            exit;
        exit(Format(FieldReference.Value()) = CompareAgainstValue);
    end;

    procedure GetAuthorizationValue(AuthDetailsDict: Dictionary of [Text, Text]) AuthText: Text
    var
        OAuthSetupCode: Text;
        NPROAuthSetup: Record "NPR OAuth Setup";
        AccessToken: Text;
        BearerTokenText: Label 'Bearer %1';
    begin
        AuthDetailsDict.Get('OAuthSetupCode', OAuthSetupCode);
        NPROAuthSetup.Get(OAuthSetupCode);
        AccessToken := NPROAuthSetup.GetOauthToken();
        AuthText := StrSubstNo(BearerTokenText, AccessToken);
    end;

    procedure CheckMandatoryValues(AuthDetailsDict: Dictionary of [Text, Text])
    var
        OAuthSetupCode: Text;
        SettingIsMissingErr: Label 'Setting ''%1'' is missing.';
    begin
        AuthDetailsDict.Get('OAuthSetupCode', OAuthSetupCode);
        IF OAuthSetupCode = '' then
            Error(SettingIsMissingErr, 'OAuthSetupCode');
    end;


#IF BC17
    [NonDebuggable]
    procedure GetAuthorizationDetailsDict(BasicUserName: Code[50]; BasicPassword: Text; OAuthSetupCode: Code[20]; var AuthDetailsDict: Dictionary of [Text, Text]);
    begin
        AuthDetailsDict.Add('OAuthSetupCode', OAuthSetupCode);
    end;

#ELSE
    [NonDebuggable]
    procedure GetAuthorizationDetailsDict(BasicUserName: Code[50]; BasicPassword: Text; OAuthSetupCode: Code[20]) AuthDetailsDict: Dictionary of [Text, Text];
    begin
        AuthDetailsDict.Add('OAuthSetupCode', OAuthSetupCode);
    end;
#ENDIF

}

codeunit 6014609 "NPR API Basic Auth" implements "NPR API IAuthorization"
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

    [NonDebuggable]
    procedure GetAuthorizationValue(AuthDetailsDict: Dictionary of [Text, Text]) AuthText: Text
    var
        BasicUserName: Text;
        BasicPassword: Text;
        Base64Convert: Codeunit "Base64 Convert";
        StrSubStNoText1: Label '%1:%2';
        StrSubStNoText2: Label 'Basic %1';
    begin
        AuthDetailsDict.Get('BasicUserName', BasicUserName);
        AuthDetailsDict.Get('BasicPassword', BasicPassword);
        AuthText := StrSubstNo(StrSubStNoText1, BasicUserName, BasicPassword);
        AuthText := Base64Convert.ToBase64(AuthText);
        AuthText := StrSubstNo(StrSubStNoText2, AuthText);
    end;

    [NonDebuggable]
    procedure CheckMandatoryValues(AuthDetailsDict: Dictionary of [Text, Text])
    var
        BasicUserName: Text;
        BasicPassword: Text;
        SettingIsMissingErr: Label 'Setting ''%1'' is missing.';
    begin
        AuthDetailsDict.Get('BasicUserName', BasicUserName);
        AuthDetailsDict.Get('BasicPassword', BasicPassword);
        IF BasicUserName = '' then
            Error(SettingIsMissingErr, 'BasicUserName');
        IF BasicPassword = '' then
            Error(SettingIsMissingErr, 'BasicPassword');
    end;

#IF BC17
    [NonDebuggable]
    procedure GetAuthorizationDetailsDict(BasicUserName: Code[50]; BasicPassword: Text; OAuthSetupCode: Code[20]; var AuthDetailsDict: Dictionary of [Text, Text]);
    begin
        AuthDetailsDict.Add('BasicUserName', BasicUserName);
        AuthDetailsDict.Add('BasicPassword', BasicPassword);
    end;
#ELSE
    [NonDebuggable]
    procedure GetAuthorizationDetailsDict(BasicUserName: Code[50]; BasicPassword: Text; OAuthSetupCode: Code[20]) AuthDetailsDict: Dictionary of [Text, Text];
    begin
        AuthDetailsDict.Add('BasicUserName', BasicUserName);
        AuthDetailsDict.Add('BasicPassword', BasicPassword);
    end;
#ENDIF

}

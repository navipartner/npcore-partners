codeunit 6014618 "NPR Replication API OAuth2" implements "NPR Replication API IAuthorization"
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

    procedure GetAuthorizationValue(ServiceSetup: Record "NPR Replication Service Setup") AuthText: Text
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        OAuth20Mgt: Codeunit "OAuth 2.0 Mgt.";
        MessageText, AccessToken, RefreshToken : Text;
        BearerTokenText: Label 'Bearer %1';
    begin
        OAuth20Setup.Get(ServiceSetup."OAuth2 Setup Code");
        OAuth20Mgt.RefreshAccessToken(OAuth20Setup, MessageText, OAuth20Setup."Client ID", OAuth20Setup."Client Secret", AccessToken, RefreshToken);
        AuthText := StrSubstNo(BearerTokenText, AccessToken);
    end;

    procedure CheckMandatoryValues(ServiceSetup: Record "NPR Replication Service Setup")
    begin
        ServiceSetup.TestField("OAuth2 Setup Code");
    end;

}

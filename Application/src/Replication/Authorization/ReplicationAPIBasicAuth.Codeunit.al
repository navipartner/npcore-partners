codeunit 6014609 "NPR Replication API Basic Auth" implements "NPR Replication API IAuthorization"
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
        Base64Convert: Codeunit "Base64 Convert";
        StrSubStNoText1: Label '%1:%2';
        StrSubStNoText2: Label 'Basic %1';
    begin
        AuthText := StrSubstNo(StrSubStNoText1, ServiceSetup.UserName, ServiceSetup.GetApiPassword());
        AuthText := Base64Convert.ToBase64(AuthText);
        AuthText := StrSubstNo(StrSubStNoText2, AuthText);
    end;

    procedure CheckMandatoryValues(ServiceSetup: Record "NPR Replication Service Setup")
    begin
        ServiceSetup.TestField(UserName);
        ServiceSetup.TestField("API Password Key");
    end;

}

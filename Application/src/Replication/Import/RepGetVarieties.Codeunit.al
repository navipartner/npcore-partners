codeunit 6014624 "NPR Rep. Get Varieties" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetVarieties_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetVarieties(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetVarieties(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        URI := ReplicationAPI.CreateURI(ReplicationSetup, ReplicationEndPoint, NextLinkURI);
        ReplicationAPI.GetBCAPIResponse(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    procedure ProcessImportedContent(Content: Codeunit "Temp Blob"; ReplicationEndPoint: Record "NPR Replication Endpoint"): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        JTokenMainObject: JsonToken;
        JArrayValues: JsonArray;
        JTokenEntity: JsonToken;
        i: integer;
    begin
        IF Not ReplicationAPI.GetJTokenMainObjectFromContent(Content, JTokenMainObject) THEN
            exit;

        IF NOT ReplicationAPI.GetJsonArrayFromJsonToken(JTokenMainObject, '$.value', JArrayValues) then
            exit;

        for i := 0 to JArrayValues.Count - 1 do begin
            JArrayValues.Get(i, JTokenEntity);
            HandleArrayElementEntity(JTokenEntity, ReplicationEndPoint);
        end;

        ReplicationAPI.UpdateReplicationCounter(JTokenEntity, ReplicationEndPoint);
    end;

    local procedure HandleArrayElementEntity(JToken: JsonToken; ReplicationEndPoint: Record "NPR Replication Endpoint")
    var
        Variety: Record "NPR Variety";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        VarietyCode: Text;
        VarietyId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        VarietyCode := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code');
        VarietyId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.systemId');

        IF VarietyId <> '' then
            IF Variety.GetBySystemId(VarietyId) then begin
                RecFoundBySystemId := true;
                If Variety.Code <> VarietyCode then // rename!
                    if NOT Variety.Rename(VarietyCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT Variety.Get(VarietyCode) then
                InsertNewRec(Variety, VarietyCode, VarietyId);

        IF CheckFieldsChanged(Variety, JToken) then
            Variety.Modify(true);
    end;

    local procedure CheckFieldsChanged(var Variety: Record "NPR Variety"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(Variety, Variety.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Variety, Variety.FieldNo("Use in Variant Description"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.useinVariantDescription'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Variety, Variety.FieldNo("Pre tag In Variant Description"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.pretagInVariantDescription'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Variety, Variety.FieldNo("Use Description field"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.useDescriptionfield'), false) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var Variety: Record "NPR Variety"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(Variety, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(Variety);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var Variety: Record "NPR Variety"; VarietyCode: Text; VarietyId: text)
    begin
        Variety.Init();
        Variety.Code := VarietyCode;
        IF VarietyId <> '' THEN begin
            IF Evaluate(Variety.SystemId, VarietyId) Then
                Variety.Insert(false, true)
            Else
                Variety.Insert(false);
        end else
            Variety.Insert(false);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

}
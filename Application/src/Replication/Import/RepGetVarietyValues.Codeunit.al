codeunit 6014642 "NPR Rep. Get Variety Values" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetVarietyValues_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetVarietyTables(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetVarietyTables(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        VarietyValue: Record "NPR Variety Value";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        VarietyValueType: Code[10];
        VarietyValueTable: Code[40];
        VarietyValueValue: Code[50];
        VarietyValueId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        VarietyValueType := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.type'), 1, Maxstrlen(VarietyValueType));
        VarietyValueTable := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.table'), 1, MaxStrLen(VarietyValueTable));
        VarietyValueValue := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.value'), 1, MaxStrLen(VarietyValueValue));
        VarietyValueId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.systemId');

        IF VarietyValueId <> '' then
            IF VarietyValue.GetBySystemId(VarietyValueId) then begin
                RecFoundBySystemId := true;
                If (VarietyValue.Type <> VarietyValueType) OR (VarietyValue.Table <> VarietyValueTable) OR (VarietyValue.Value <> VarietyValueValue) then // rename!
                    if NOT VarietyValue.Rename(VarietyValueType, VarietyValueTable, VarietyValueValue) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT VarietyValue.Get(VarietyValueType, VarietyValueTable, VarietyValueValue) then
                InsertNewRec(VarietyValue, VarietyValueType, VarietyValueTable, VarietyValueValue, VarietyValueId);

        IF CheckFieldsChanged(VarietyValue, JToken) then
            VarietyValue.Modify(true);
    end;

    local procedure CheckFieldsChanged(var VarietyValue: Record "NPR Variety Value"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(VarietyValue, VarietyValue.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyValue, VarietyValue.FieldNo("Sort Order"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.sortOrder'), false) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var VarietyValue: Record "NPR Variety Value"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(VarietyValue, RecRef) then
            exit;

        If ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(VarietyValue);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var VarietyValue: Record "NPR Variety Value"; VarietyValueType: Code[10]; VarietyValueTable: Code[40]; VarietyValueValue: Code[50]; VarietyTableId: text)
    begin
        VarietyValue.Init();
        VarietyValue.Type := VarietyValueType;
        VarietyValue.Table := VarietyValueTable;
        VarietyValue.Value := VarietyValueValue;
        IF VarietyTableId <> '' THEN begin
            IF Evaluate(VarietyValue.SystemId, VarietyTableId) Then
                VarietyValue.Insert(false, true)
            Else
                VarietyValue.Insert(false);
        end else
            VarietyValue.Insert(false);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

    procedure CheckResponseContainsData(Content: Codeunit "Temp Blob"): Boolean;
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        JTokenMainObject: JsonToken;
        JArrayValues: JsonArray;
    begin
        IF Not ReplicationAPI.GetJTokenMainObjectFromContent(Content, JTokenMainObject) THEN
            exit(false);

        IF NOT ReplicationAPI.GetJsonArrayFromJsonToken(JTokenMainObject, '$.value', JArrayValues) then
            exit(false);

        Exit(JArrayValues.Count > 0);
    end;

}
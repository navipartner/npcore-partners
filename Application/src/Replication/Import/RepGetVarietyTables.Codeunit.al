codeunit 6014648 "NPR Rep. Get Variety Tables" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetVarietyTables_%1', Comment = '%1=Current Date and Time';

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
        VarietyTable: Record "NPR Variety Table";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        VarietyTableType: Text;
        VarietyTableCode: Text;
        VarietyTableId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        VarietyTableType := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.type');
        VarietyTableCode := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code');
        VarietyTableId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.systemId');

        IF VarietyTableId <> '' then
            IF VarietyTable.GetBySystemId(VarietyTableId) then begin
                RecFoundBySystemId := true;
                If (VarietyTable.Type <> VarietyTableType) OR (VarietyTable.Code <> VarietyTableCode) then // rename!
                    if NOT VarietyTable.Rename(VarietyTableType, VarietyTableCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT VarietyTable.Get(VarietyTableType, VarietyTableCode) then
                InsertNewRec(VarietyTable, VarietyTableType, VarietyTableCode, VarietyTableId);

        IF CheckFieldsChanged(VarietyTable, JToken) then
            VarietyTable.Modify(true);
    end;

    local procedure CheckFieldsChanged(var VarietyTable: Record "NPR Variety Table"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(VarietyTable, VarietyTable.FieldNo("Copy from"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.copyfrom'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyTable, VarietyTable.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyTable, VarietyTable.FieldNo("Is Copy"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.isCopy'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyTable, VarietyTable.FieldNo("Lock Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.lockTable'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyTable, VarietyTable.FieldNo("Pre tag In Variant Description"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.pretagInVariantDescription'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyTable, VarietyTable.FieldNo("Use Description field"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.useDescriptionfield'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyTable, VarietyTable.FieldNo("Use in Variant Description"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.useinVariantDescription'), false) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var VarietyTable: Record "NPR Variety Table"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(VarietyTable, RecRef) then
            exit;

        If ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(VarietyTable);
            Exit(true);
        end;
    end;

    local procedure InsertNewRec(var VarietyTable: Record "NPR Variety Table"; VarietyTableType: Text; VarietyTableCode: Text; VarietyTableId: text)
    begin
        VarietyTable.Init();
        VarietyTable.Type := VarietyTableType;
        VarietyTable.Code := VarietyTableCode;
        IF VarietyTableId <> '' THEN begin
            IF Evaluate(VarietyTable.SystemId, VarietyTableId) Then
                VarietyTable.Insert(false, true)
            Else
                VarietyTable.Insert(false);
        end else
            VarietyTable.Insert(false);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

}
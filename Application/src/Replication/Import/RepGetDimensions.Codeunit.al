codeunit 6014667 "NPR Rep. Get Dimensions" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetDimensions_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetDimensions(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetDimensions(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        // each entity can have it's own 'Get' logic, but mostly should be the same, so code stays in Replication API codeunit
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
        // each entity can have it's own 'Process' logic, but mostly should be the same, so part of code stays in Replication API codeunit
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
        Dimension: Record Dimension;
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        DimensionCode: Text;
        DimensionId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        DimensionCode := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code');
        DimensionId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF DimensionId <> '' then
            IF Dimension.GetBySystemId(DimensionId) then begin
                RecFoundBySystemId := true;
                If Dimension."Code" <> DimensionCode then // rename!
                    if NOT Dimension.Rename(DimensionCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT Dimension.Get(DimensionCode) then
                InsertNewRec(Dimension, DimensionCode, DimensionId);

        IF CheckFieldsChanged(Dimension, JToken) then
            Dimension.Modify(true);
    end;

    local procedure CheckFieldsChanged(var Dimension: Record Dimension; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(Dimension, Dimension.FieldNo(Name), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Dimension, Dimension.FieldNo("Code Caption"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.codeCaption'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Dimension, Dimension.FieldNo("Filter Caption"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.filterCaption'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Dimension, Dimension.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Dimension, Dimension.FieldNo(Blocked), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.blocked'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Dimension, Dimension.FieldNo("Consolidation Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.consolidationCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Dimension, Dimension.FieldNo("Map-to IC Dimension Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.mapToICDimensionCode'), true) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldValue(var Dimension: Record Dimension; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(Dimension, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(Dimension);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var Dimension: Record Dimension; DimensionCode: Text; DimensionId: text)
    begin
        Dimension.Init();
        Dimension.Code := DimensionCode;
        IF DimensionId <> '' THEN begin
            IF Evaluate(Dimension.SystemId, DimensionId) Then
                Dimension.Insert(false, true)
            Else
                Dimension.Insert(false);
        end else
            Dimension.Insert(false);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

}
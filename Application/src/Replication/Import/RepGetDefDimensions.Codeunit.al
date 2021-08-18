codeunit 6014672 "NPR Rep. Get Def. Dimensions" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetDefaultDimensions_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetDefaultDimensions(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetDefaultDimensions(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        DefaultDimension: Record "Default Dimension";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        TableID: Integer;
        No: Code[20];
        DimensionCode: Code[20];
        DefaultDimensionId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        Evaluate(TableID, ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.tableID'));
        No := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.no'), 1, MaxStrLen(No));
        DimensionCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.dimensionCode'), 1, maxstrlen(DimensionCode));
        DefaultDimensionId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF DefaultDimensionId <> '' then
            IF DefaultDimension.GetBySystemId(DefaultDimensionId) then begin
                RecFoundBySystemId := true;
                If (DefaultDimension."Table ID" <> TableID) OR (DefaultDimension."No." <> No) OR
                 (DefaultDimension."Dimension Code" <> DimensionCode) then // rename!
                    if NOT DefaultDimension.Rename(TableID, No, DimensionCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT DefaultDimension.Get(TableID, No, DimensionCode) then
                InsertNewRec(DefaultDimension, TableID, No, DimensionCode, DefaultDimensionId);

        IF CheckFieldsChanged(DefaultDimension, JToken) then
            DefaultDimension.Modify(true);
    end;

    local procedure CheckFieldsChanged(var DefaultDimension: Record "Default Dimension"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(DefaultDimension, DefaultDimension.FieldNo("Dimension Value Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.dimensionValueCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DefaultDimension, DefaultDimension.FieldNo("Parent Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.parentType'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DefaultDimension, DefaultDimension.FieldNo("Value Posting"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.postingValidation'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DefaultDimension, DefaultDimension.FieldNo("Multi Selection Action"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.multiSelectionAction'), true) then
            FieldsChanged := true;

        DefaultDimension.UpdateReferencedIdFields();
    end;

    local procedure CheckFieldValue(var DefaultDimension: Record "Default Dimension"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(DefaultDimension, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(DefaultDimension);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var DefaultDimension: Record "Default Dimension"; TableId: integer; No: Code[20]; DimensionCode: Code[20]; DefaultDimensionId: text)
    begin
        DefaultDimension.Init();
        DefaultDimension."Table ID" := TableId;
        DefaultDimension."No." := No;
        DefaultDimension."Dimension Code" := DimensionCode;
        IF DefaultDimensionId <> '' THEN begin
            IF Evaluate(DefaultDimension.SystemId, DefaultDimensionId) Then
                DefaultDimension.Insert(false, true)
            Else
                DefaultDimension.Insert(false);
        end else
            DefaultDimension.Insert(false);
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
codeunit 6014668 "NPR Rep. Get Dimension Values" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetDimensionValues_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetDimensionValues(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetDimensionValues(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        DimensionValue: Record "Dimension Value";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        DimensionCode: Code[20];
        DimensionValueCode: Code[20];
        DimensionValueId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        DimensionValueCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(DimensionValueCode));
        DimensionCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.dimensionCode'), 1, MaxStrLen(DimensionCode));
        DimensionValueId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF DimensionValueId <> '' then
            IF DimensionValue.GetBySystemId(DimensionValueId) then begin
                RecFoundBySystemId := true;
                If (DimensionValue."Code" <> DimensionCode) OR (DimensionValue."Dimension Code" <> DimensionCode) then // rename!
                    if NOT DimensionValue.Rename(DimensionCode, DimensionValueCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT DimensionValue.Get(DimensionCode, DimensionValueCode) then
                InsertNewRec(DimensionValue, DimensionCode, DimensionValueCode, DimensionValueId);

        IF CheckFieldsChanged(DimensionValue, JToken) then
            DimensionValue.Modify(true);
    end;

    local procedure CheckFieldsChanged(var DimensionValue: Record "Dimension Value"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(DimensionValue, DimensionValue.FieldNo(Name), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DimensionValue, DimensionValue.FieldNo("Dimension Value Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.dimensionValueType'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DimensionValue, DimensionValue.FieldNo(Totaling), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.totaling'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DimensionValue, DimensionValue.FieldNo(Blocked), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.blocked'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DimensionValue, DimensionValue.FieldNo("Consolidation Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.consolidationCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DimensionValue, DimensionValue.FieldNo(Indentation), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.indentation'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DimensionValue, DimensionValue.FieldNo("Global Dimension No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.globalDimensionNo'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DimensionValue, DimensionValue.FieldNo("Map-to IC Dimension Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.mapToICDimensionCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DimensionValue, DimensionValue.FieldNo("Map-to IC Dimension Value Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.mapToICDimensionValueCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(DimensionValue, DimensionValue.FieldNo(Name), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName'), true) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var DimensionValue: Record "Dimension Value"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(DimensionValue, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(DimensionValue);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var DimensionValue: Record "Dimension Value"; DimensionCode: Code[20]; DimensionValueCode: Code[20]; DimensionValueId: text)
    begin
        DimensionValue.Init();
        DimensionValue.Validate("Dimension Code", DimensionCode); // populate Dimension Id
        DimensionValue.Code := DimensionValueCode;
        IF DimensionValueId <> '' THEN begin
            IF Evaluate(DimensionValue.SystemId, DimensionValueId) Then
                DimensionValue.Insert(false, true)
            Else
                DimensionValue.Insert(false);
        end else
            DimensionValue.Insert(false);
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
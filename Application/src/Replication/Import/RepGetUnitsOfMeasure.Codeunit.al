codeunit 6014605 "NPR Rep. Get Units Of Measure" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetUnitsOfMeasure_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetUnitsOfMeasure(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetUnitsOfMeasure(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        UOM: Record "Unit of Measure";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        UOMCode: Text;
        UOMId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        UOMCode := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code');
        UOMId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF UOMId <> '' then
            IF UOM.GetBySystemId(UOMId) then begin
                RecFoundBySystemId := true;
                If (UOM.Code <> UOMCode) then // rename!
                    if NOT UOM.Rename(UOMCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT UOM.Get(UOMCode) then
                InsertNewRec(UOM, UOMCode, UOMId);

        IF CheckFieldsChanged(UOM, JToken) then
            UOM.Modify(true);
    end;

    local procedure CheckFieldsChanged(var UOM: Record "Unit of Measure"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(UOM, UOM.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(UOM, UOM.FieldNo("International Standard Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.internationalStandardCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(UOM, UOM.FieldNo(Symbol), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.symbol'), false) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var UOM: Record "Unit of Measure"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean) ValueChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(UOM, RecRef) then
            exit;

        ValueChanged := ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation);
        IF ValueChanged then
            RecRef.SetTable(UOM);
    end;

    local procedure InsertNewRec(var UOM: Record "Unit of Measure"; UOMCode: Text; UOMId: text)
    begin
        UOM.Init();
        UOM.Code := UOMCode;
        IF UOMId <> '' THEN begin
            IF Evaluate(UOM.SystemId, UOMId) Then
                UOM.Insert(false, true)
            Else
                UOM.Insert(false);
        end else
            UOM.Insert(false);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

}
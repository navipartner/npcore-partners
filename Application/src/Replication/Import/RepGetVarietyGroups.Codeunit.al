codeunit 6014625 "NPR Rep. Get Variety Groups" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetVarGroups_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetVarietyGroups(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetVarietyGroups(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        VarietyGroup: Record "NPR Variety Group";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        GroupCode: Text;
        GroupId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        GroupCode := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code');
        GroupId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.systemId');

        IF GroupId <> '' then
            IF VarietyGroup.GetBySystemId(GroupId) then begin
                RecFoundBySystemId := true;
                If VarietyGroup.Code <> GroupCode then // rename!
                    if NOT VarietyGroup.Rename(GroupCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT VarietyGroup.Get(GroupCode) then
                InsertNewRec(VarietyGroup, GroupCode, GroupId);

        IF CheckFieldsChanged(VarietyGroup, JToken) then
            VarietyGroup.Modify(true);
    end;

    local procedure CheckFieldsChanged(var VarietyGroup: Record "NPR Variety Group"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Cross Variety No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.crossVarietyNo'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variety 1"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety1'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variety 1 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety1Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Create Copy of Variety 1 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.createCopyofVariety1Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Copy Naming Variety 1"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.copyNamingVariety1'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variety 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety2'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variety 2 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety2Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Create Copy of Variety 2 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.createCopyofVariety2Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Copy Naming Variety 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.copyNamingVariety2'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variety 3"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety3'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variety 3 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety3Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Create Copy of Variety 3 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.createCopyofVariety3Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Copy Naming Variety 3"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.copyNamingVariety3'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variety 4"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety4'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variety 4 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety4Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Create Copy of Variety 4 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.createCopyofVariety4Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Copy Naming Variety 4"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.copyNamingVariety4'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variant Code Part 1"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCodePart1'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variant Code Part 1 Length"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCodePart1Length'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variant Code Seperator 1"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCodeSeperator1'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variant Code Part 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCodePart2'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variant Code Part 2 Length"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCodePart2Length'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variant Code Seperator 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCodeSeperator2'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variant Code Part 3"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCodePart3'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(VarietyGroup, VarietyGroup.FieldNo("Variant Code Part 3 Length"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCodePart3Length'), false) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldValue(var VarietyGroup: Record "NPR Variety Group"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(VarietyGroup, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(VarietyGroup);
            exit(true);
        end
    end;

    local procedure InsertNewRec(var VarietyGroup: Record "NPR Variety Group"; GroupCode: Text; GroupId: text)
    begin
        VarietyGroup.Init();
        VarietyGroup.Code := GroupCode;
        IF GroupId <> '' THEN begin
            IF Evaluate(VarietyGroup.SystemId, GroupId) Then
                VarietyGroup.Insert(false, true)
            Else
                VarietyGroup.Insert(false);
        end else
            VarietyGroup.Insert(false);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

}
codeunit 6014637 "NPR Rep. Get Item Categories" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetItemCategories_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetItemCategories(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetItemCategories(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        ItemCat: Record "Item Category";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        ItemCatId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        ItemCatId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF ItemCatId <> '' then
            IF ItemCat.GetBySystemId(ItemCatId) then begin
                RecFoundBySystemId := true;
                If ItemCat.Code <> ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code') then // rename!
                    IF Not ItemCat.Rename(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code')) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF NOT RecFoundBySystemId Then
            IF NOT ItemCat.Get(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code')) then
                InsertNewRec(JToken, ItemCat);

        IF CheckFieldsChanged(ItemCat, JToken) then
            ItemCat.Modify(true);
    end;

    local procedure CheckFieldsChanged(var ItemCat: Record "Item Category"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(ItemCat, ItemCat.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemCat, ItemCat.FieldNo("NPR Item Template Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprItemTemplateCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemCat, ItemCat.FieldNo("Parent Category"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.parentCategory'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemCat, ItemCat.FieldNo("NPR Main Category"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMainCategory'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemCat, ItemCat.FieldNo("NPR Main Category Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMainCategoryCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemCat, ItemCat.FieldNo("NPR Blocked"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprBlocked'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemCat, ItemCat.FieldNo("NPR Global Dimension 1 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprGlobalDimension1Code'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemCat, ItemCat.FieldNo("NPR Global Dimension 2 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprGlobalDimension2Code'), false) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var ItemCat: Record "Item Category"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(ItemCat, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(ItemCat);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(JToken: JsonToken; var ItemCat: Record "Item Category")
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        ItemCat.Init();
        ItemCat.Code := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code');
        IF ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id') <> '' THEN begin
            IF Evaluate(ItemCat.SystemId, ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id')) Then
                ItemCat.Insert(true, true)
            Else
                ItemCat.Insert(true);
        end else
            ItemCat.Insert(true);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

}

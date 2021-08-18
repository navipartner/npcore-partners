codeunit 6014655 "NPR Rep. Get Item Variants" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetItemVariants_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetItemVariants(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetItemVariants(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        ItemVariant: Record "Item Variant";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        ItemNo: Code[20];
        VariantCode: Code[10];
        ItemVariantId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        ItemNo := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.itemNumber'), 1, MaxStrLen(ItemNo));
        VariantCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(VariantCode));
        ItemVariantId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        If ItemVariantId <> '' then
            IF ItemVariant.GetBySystemId(ItemVariantId) then begin
                RecFoundBySystemId := true;
                If (ItemVariant.Code <> VariantCode) OR (ItemVariant."Item No." <> ItemNo) then // rename!
                    if NOT ItemVariant.Rename(ItemNo, VariantCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT ItemVariant.Get(ItemNo, VariantCode) then
                InsertNewRec(ItemVariant, ItemNo, VariantCode, ItemVariantId);

        IF CheckFieldsChanged(ItemVariant, JToken) then
            ItemVariant.Modify(true);
    end;

    local procedure CheckFieldsChanged(var ItemVariant: Record "Item Variant"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        Item: Record Item;
    begin
        if Item.Get(ItemVariant."Item No.") then
            ItemVariant."Item Id" := Item.SystemId
        Else begin
            IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("Item Id"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.itemId'), false) then
                FieldsChanged := true;
        end;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("Description 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description2'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 1"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety1'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 1 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety1Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 1 Value"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety1Value'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety2'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 2 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety2Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 2 Value"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety2Value'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 3"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety3'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 3 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety3Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 3 Value"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety3Value'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 4"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety4'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 4 Table"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety4Table'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Variety 4 Value"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variety4Value'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemVariant, ItemVariant.FieldNo("NPR Blocked"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.blocked'), false) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldValue(var ItemVariant: Record "Item Variant"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(ItemVariant, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(ItemVariant);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var ItemVariant: Record "Item Variant"; ItemNo: Code[20]; VariantCode: Code[10]; VariantId: text)
    begin
        ItemVariant.Init();
        ItemVariant."Item No." := ItemNo;
        ItemVariant.Code := VariantCode;
        IF VariantId <> '' THEN begin
            IF Evaluate(ItemVariant.SystemId, VariantId) Then
                ItemVariant.Insert(false, true)
            Else
                ItemVariant.Insert(false);
        end else
            ItemVariant.Insert(false);
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
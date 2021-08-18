codeunit 6014606 "NPR Rep. Get Item UOM" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetItemUnitsOfMeasure_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetItemUnitsOfMeasure(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetItemUnitsOfMeasure(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        ItemUOM: Record "Item Unit of Measure";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        ItemNo: Code[20];
        UOMCode: Code[10];
        ItemUOMId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        ItemNo := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.itemNumber'), 1, MaxStrLen(ItemNo));
        UOMCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(UOMCode));
        ItemUOMId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF ItemUOMId <> '' then
            IF ItemUOM.GetBySystemId(ItemUOMId) then begin
                RecFoundBySystemId := true;
                If (ItemUOM."Item No." <> ItemNo) OR (ItemUOM.Code <> UOMCode) then // rename!
                    if NOT ItemUOM.Rename(ItemNo, UOMCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT ItemUOM.Get(ItemNo, UOMCode) then
                InsertNewRec(ItemUOM, ItemNo, UOMCode, ItemUOMId);

        IF CheckFieldsChanged(ItemUOM, JToken) then
            ItemUOM.Modify(true);
    end;

    local procedure CheckFieldsChanged(var ItemUOM: Record "Item Unit of Measure"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(ItemUOM, ItemUOM.FieldNo("Qty. per Unit of Measure"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.qtyperUnitofMeasure'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemUOM, ItemUOM.FieldNo(Length), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.length'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemUOM, ItemUOM.FieldNo(Width), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.width'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemUOM, ItemUOM.FieldNo(Height), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.height'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemUOM, ItemUOM.FieldNo(Cubage), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.cubage'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemUOM, ItemUOM.FieldNo(Weight), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.weight'), false) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var ItemUOM: Record "Item Unit of Measure"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(ItemUOM, RecRef) then
            exit(false);

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) THEN begin
            RecRef.SetTable(ItemUOM);
            Exit(true);
        end;
    end;

    local procedure InsertNewRec(var ItemUOM: Record "Item Unit of Measure"; ItemNo: Code[20]; UOMCode: Code[10]; ItemUOMId: text)
    begin
        ItemUOM.Init();
        ItemUOM."Item No." := ItemNo;
        ItemUOM.Code := UOMCode;
        IF ItemUOMId <> '' THEN begin
            IF Evaluate(ItemUOM.SystemId, ItemUOMId) Then
                ItemUOM.Insert(false, true)
            Else
                ItemUOM.Insert(false);
        end else
            ItemUOM.Insert(false);
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
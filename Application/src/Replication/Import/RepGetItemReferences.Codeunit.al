codeunit 6014604 "NPR Rep. Get Item References" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetItemReferences_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetItemReferences(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetItemReferences(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        ItemReference: Record "Item Reference";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        ItemNo: Code[20];
        VariantCode: Code[10];
        UOMCode: Code[10];
        ReferenceType: ENUM "Item Reference Type";
        ReferenceTypeNo: Code[20];
        ReferenceNo: Code[50];
        ItemReferenceId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        ItemNo := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.itemNo'), 1, MaxStrLen(ItemNo));
        VariantCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCode'), 1, MaxStrLen(VariantCode));
        UOMCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitofMeasure'), 1, MaxStrLen(UOMCode));
        IF Evaluate(ReferenceType, ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.referenceType')) then;
        ReferenceTypeNo := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.referenceTypeNo'), 1, MaxStrLen(ReferenceTypeNo));
        ReferenceNo := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.referenceNo'), 1, MaxStrLen(ReferenceNo));
        ItemReferenceId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.systemId');

        IF ItemReferenceId <> '' then
            IF ItemReference.GetBySystemId(ItemReferenceId) then begin
                RecFoundBySystemId := true;
                If (ItemReference."Item No." <> ItemNo) OR (ItemReference."Variant Code" <> VariantCode) OR (ItemReference."Unit of Measure" <> UOMCode)
                 OR (ItemReference."Reference Type" <> ReferenceType) OR (ItemReference."Reference Type No." <> ReferenceTypeNo) OR
                 (ItemReference."Reference No." <> ReferenceNo) then // rename!
                    if NOT ItemReference.Rename(ItemNo, VariantCode, UOMCode, ReferenceType, ReferenceTypeNo, ReferenceNo) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT ItemReference.Get(ItemNo, VariantCode, UOMCode, ReferenceType, ReferenceTypeNo, ReferenceNo) then
                InsertNewRec(ItemReference, ItemNo, VariantCode, UOMCode, ReferenceType, ReferenceTypeNo, ReferenceNo, ItemReferenceId);

        IF CheckFieldsChanged(ItemReference, JToken) then
            ItemReference.Modify(true);
    end;

    local procedure CheckFieldsChanged(var ItemReference: Record "Item Reference"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(ItemReference, ItemReference.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(ItemReference, ItemReference.FieldNo("Description 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description2'), false) then
            FieldsChanged := true;

#IF BC17
        IF CheckFieldValue(ItemReference, ItemReference.FieldNo("Discontinue Bar Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.discontinueBarCode'), false) then
            FieldsChanged := true;
#ENDIF
    end;

    local procedure CheckFieldValue(var ItemReference: Record "Item Reference"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(ItemReference, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(ItemReference);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var ItemReference: Record "Item Reference"; ItemNo: Code[20]; VariantCode: Code[10]; UOMCode: Code[10]; ReferenceType: Enum "Item Reference Type"; ReferenceTypeNo: Code[20]; ReferenceNo: Code[50]; ReferenceId: text)
    begin
        ItemReference.Init();
        ItemReference."Item No." := ItemNo;
        ItemReference."Variant Code" := VariantCode;
        ItemReference."Unit of Measure" := UOMCode;
        ItemReference."Reference Type" := ReferenceType;
        ItemReference."Reference Type No." := ReferenceTypeNo;
        ItemReference."Reference No." := ReferenceNo;
        IF ReferenceId <> '' THEN begin
            IF Evaluate(ItemReference.SystemId, ReferenceId) Then
                ItemReference.Insert(false, true)
            Else
                ItemReference.Insert(false);
        end else
            ItemReference.Insert(false);
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
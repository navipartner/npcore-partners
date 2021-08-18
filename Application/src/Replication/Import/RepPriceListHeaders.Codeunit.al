codeunit 6014592 "NPR Rep. Price List Headers" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetSalesListPriceHeaders_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetPriceListHeaders(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetPriceListHeaders(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        PriceListHeader: Record "Price List Header";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        PriceListCode: Code[20];
        PriceListId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        PriceListCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(PriceListCode));
        PriceListId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF PriceListId <> '' then
            IF PriceListHeader.GetBySystemId(PriceListId) then begin
                RecFoundBySystemId := true;
                If PriceListHeader."Code" <> PriceListCode then // rename!
                    if NOT PriceListHeader.Rename(PriceListCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT PriceListHeader.Get(PriceListCode) then
                InsertNewRec(PriceListHeader, PriceListCode, PriceListId);

        IF CheckFieldsChanged(PriceListHeader, JToken) then
            PriceListHeader.Modify(true);
    end;

    local procedure CheckFieldsChanged(var PriceListHeader: Record "Price List Header"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Price Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.priceType'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo(Status), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.status'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Source Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.sourceType'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Source No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.sourceNo'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Source ID"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.sourceID'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Currency Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.currencyCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Starting Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.startingDate'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Ending Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.endingDate'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("VAT Bus. Posting Gr. (Price)"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vatBusPostingGrPrice'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Price Includes VAT"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.priceIncludesVAT'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Amount Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.amountType'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Allow Invoice Disc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.allowInvoiceDisc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Allow Line Disc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.allowLineDisc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Source Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.sourceGroup'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListHeader, PriceListHeader.FieldNo("Parent Source No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.parentSourceNo'), true) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldValue(var PriceListHeader: Record "Price List Header"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(PriceListHeader, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(PriceListHeader);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var PriceListHeader: Record "Price List Header"; PriceListCode: Code[20]; PriceListId: text)
    begin
        PriceListHeader.Init();
        PriceListHeader.Code := PriceListCode;
        IF PriceListId <> '' THEN begin
            IF Evaluate(PriceListHeader.SystemId, PriceListId) Then
                PriceListHeader.Insert(false, true)
            Else
                PriceListHeader.Insert(false);
        end else
            PriceListHeader.Insert(false);
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
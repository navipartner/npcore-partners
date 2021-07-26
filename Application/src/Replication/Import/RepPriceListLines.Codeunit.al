codeunit 6014654 "NPR Rep. Price List Lines" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetSalesListPriceLines_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetPriceListLines(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetPriceListLines(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        PriceListLine: Record "Price List Line";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        PriceListCode: Text;
        PriceListLineNo: Integer;
        PriceListLineId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        PriceListCode := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.priceListCode');
        IF Evaluate(PriceListLineNo, ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.lineNo')) then;
        PriceListLineId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF PriceListLineId <> '' then
            IF PriceListLine.GetBySystemId(PriceListLineId) then begin
                RecFoundBySystemId := true;
                If (PriceListLine."Price List Code" <> PriceListCode) OR (PriceListLine."Line No." <> PriceListLineNo) then // rename!
                    if NOT PriceListLine.Rename(PriceListCode, PriceListLineNo) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT PriceListLine.Get(PriceListCode, PriceListLineNo) then
                InsertNewRec(PriceListLine, PriceListCode, PriceListLineNo, PriceListLineId);

        IF CheckFieldsChanged(PriceListLine, JToken) then
            PriceListLine.Modify(true);
    end;

    local procedure CheckFieldsChanged(var PriceListLine: Record "Price List Line"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Price Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.priceType'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo(Status), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.status'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Source Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.sourceType'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Source No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.sourceNo'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Source ID"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.sourceID'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Asset Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.assetType'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Asset No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.assetNo'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Variant Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Currency Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.currencyCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Work Type Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.workTypeCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Starting Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.startingDate'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Ending Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.endingDate'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Minimum Quantity"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.minimumQuantity'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Unit of Measure Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitOfMeasureCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Amount Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.amountType'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Unit Price"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitPrice'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Cost Factor"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.costFactor'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Unit Cost"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitCost'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Line Discount %"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.lineDiscount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Allow Line Disc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.allowLineDisc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Allow Invoice Disc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.allowInvoiceDisc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Price Includes VAT"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.priceIncludesVAT'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("VAT Bus. Posting Gr. (Price)"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vatBusPostingGrPrice'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("VAT Prod. Posting Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vatProdPostingGroup'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(PriceListLine, PriceListLine.FieldNo("Line Amount"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.lineAmount'), true) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldValue(var PriceListLine: Record "Price List Line"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(PriceListLine, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(PriceListLine);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var PriceListLine: Record "Price List Line"; PriceListCode: Text; PriceListLineNo: Integer; PriceListLineId: text)
    begin
        PriceListLine.Init();
        PriceListLine."Price List Code" := PriceListCode;
        PriceListLine."Line Amount" := PriceListLineNo;
        IF PriceListLineId <> '' THEN begin
            IF Evaluate(PriceListLine.SystemId, PriceListLineId) Then
                PriceListLine.Insert(false, true)
            Else
                PriceListLine.Insert(false);
        end else
            PriceListLine.Insert(false);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

}
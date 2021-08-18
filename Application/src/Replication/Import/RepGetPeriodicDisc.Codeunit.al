codeunit 6014656 "NPR Rep. Get Periodic Disc." implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetPeriodicDiscounts_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetPeriodicDiscounts(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetPeriodicDiscounts(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        PeriodicDiscount: Record "NPR Period Discount";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        DiscountCode: Code[20];
        DiscountId: Text;
        JArrayLines: JsonArray;
        JTokenLine: JsonToken;
        i: Integer;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        DiscountCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(DiscountCode));
        DiscountId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.systemId');

        IF DiscountId <> '' then
            IF PeriodicDiscount.GetBySystemId(DiscountId) then begin
                RecFoundBySystemId := true;
                If (PeriodicDiscount.Code <> DiscountCode) then // rename!
                    if NOT PeriodicDiscount.Rename(DiscountCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT PeriodicDiscount.Get(DiscountCode) then
                InsertNewRec(PeriodicDiscount, DiscountCode, DiscountId);

        IF CheckFieldsChanged(PeriodicDiscount, JToken) then
            PeriodicDiscount.Modify(true);

        // handle Period Discount Lines
        IF ReplicationAPI.GetJsonArrayFromJsonToken(JToken, '$.periodDiscountLines', JArrayLines) then begin
            for i := 0 to JArrayLines.Count - 1 do begin
                JArrayLines.Get(i, JTokenLine);
                HandleArrayElementEntityLine(JTokenLine);
            end;
        end;

    end;

    local procedure HandleArrayElementEntityLine(JToken: JsonToken)
    var
        PeriodicDiscountLine: Record "NPR Period Discount Line";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        DiscountCode: Code[20];
        ItemNo: Code[20];
        VariantCode: Code[10];
        DiscountLineId: Text;
    begin
        DiscountCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(DiscountCode));
        ItemNo := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.itemNo'), 1, MaxStrLen(ItemNo));
        VariantCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCode'), 1, MaxStrLen(VariantCode));
        DiscountLineId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.systemId');

        IF PeriodicDiscountLine.GetBySystemId(DiscountLineId) then begin
            RecFoundBySystemId := true;
            If (PeriodicDiscountLine.Code <> DiscountCode) OR (PeriodicDiscountLine."Item No." <> ItemNo) OR (PeriodicDiscountLine."Variant Code" <> VariantCode) then // rename!
                if NOT PeriodicDiscountLine.Rename(DiscountCode, ItemNo, VariantCode) then // maybe another rec with same pk already exists...
                    RecFoundBySystemId := false;
        end;

        IF Not RecFoundBySystemId then
            IF NOT PeriodicDiscountLine.Get(DiscountCode, ItemNo, VariantCode) then
                InsertNewRecLine(PeriodicDiscountLine, DiscountCode, ItemNo, VariantCode, DiscountLineId);

        IF CheckFieldsChangedLine(PeriodicDiscountLine, JToken) then
            PeriodicDiscountLine.Modify(true);
    end;

    local procedure CheckFieldsChanged(var PeriodicDiscount: Record "NPR Period Discount"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Block Custom Disc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.blockCustomDisc'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Created Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.createdDate'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Customer Disc. Group Filter"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.customerDiscGroupFilter'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Starting Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.startingDate'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Starting Time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.startingTime'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Ending Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.endingDate'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Ending Time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.endingTime'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Global Dimension 1 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.globalDimension1Code'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Global Dimension 2 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.globalDimension2Code'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Location Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.locationCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("No. Series"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.noSeries'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Period Description"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.periodDescription'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo("Period Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.periodType'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo(Monday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.monday'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo(Tuesday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.tuesday'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo(Wednesday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.wednesday'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo(Thursday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.thursday'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo(Friday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.friday'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo(Saturday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.saturday'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo(Sunday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.sunday'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(PeriodicDiscount, PeriodicDiscount.FieldNo(Status), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.status'), false) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldsChangedLine(var PeriodicDiscountLine: Record "NPR Period Discount Line"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Starting Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.startingDate'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Starting Time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.startingTime'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Ending Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.endingDate'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Ending Time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.endingTime'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo(Priority), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.priority'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Campaign Profit"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.campaignProfit'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Campaign Unit Cost"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.campaignUnitCost'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Campaign Unit Price"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.campaignUnitPrice'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Cross-Reference No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.crossReferenceNo'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Discount %"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.discount'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Discount Amount"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.discountAmount'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Distribution Item"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.distributionItem'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Internet Special Id"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.internetSpecialId'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo(Profit), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.profit'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo(Status), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.status'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Unit Cost Purchase"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitCostPurchase'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Unit Price"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitPrice'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Unit Price Incl. VAT"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitPriceInclVAT'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Vendor Item No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vendorItemNo'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(PeriodicDiscountLine, PeriodicDiscountLine.FieldNo("Vendor No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vendorNo'), false) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var PeriodicDiscount: Record "NPR Period Discount"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(PeriodicDiscount, RecRef) then
            exit(false);

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) THEN begin
            RecRef.SetTable(PeriodicDiscount);
            Exit(true);
        end;
    end;

    local procedure CheckFieldValueLine(var PeriodicDiscountLine: Record "NPR Period Discount Line"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(PeriodicDiscountLine, RecRef) then
            exit(false);

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) THEN begin
            RecRef.SetTable(PeriodicDiscountLine);
            Exit(true);
        end;
    end;

    local procedure InsertNewRec(var PeriodicDiscount: Record "NPR Period Discount"; DiscountCode: Code[20]; DiscountId: text)
    begin
        PeriodicDiscount.Init();
        PeriodicDiscount.Code := DiscountCode;
        IF DiscountId <> '' THEN begin
            IF Evaluate(PeriodicDiscount.SystemId, DiscountId) Then
                PeriodicDiscount.Insert(false, true)
            Else
                PeriodicDiscount.Insert(false);
        end else
            PeriodicDiscount.Insert(false);
    end;

    local procedure InsertNewRecLine(var PeriodicDiscountLine: Record "NPR Period Discount Line"; DiscountCode: Code[20]; ItemCode: Code[20]; VariantCode: Code[10]; DiscountLineId: text)
    begin
        PeriodicDiscountLine.Init();
        PeriodicDiscountLine.Code := DiscountCode;
        PeriodicDiscountLine."Item No." := ItemCode;
        PeriodicDiscountLine."Variant Code" := VariantCode;
        IF DiscountLineId <> '' THEN begin
            IF Evaluate(PeriodicDiscountLine.SystemId, DiscountLineId) Then
                PeriodicDiscountLine.Insert(false, true)
            Else
                PeriodicDiscountLine.Insert(false);
        end else
            PeriodicDiscountLine.Insert(false);
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

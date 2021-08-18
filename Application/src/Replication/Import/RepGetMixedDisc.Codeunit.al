codeunit 6014657 "NPR Rep. Get Mixed Disc." implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetMixedDiscounts_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetMixedDiscounts(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetMixedDiscounts(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        MixedDiscount: Record "NPR Mixed Discount";
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
            IF MixedDiscount.GetBySystemId(DiscountId) then begin
                RecFoundBySystemId := true;
                If (MixedDiscount.Code <> DiscountCode) then // rename!
                    if NOT MixedDiscount.Rename(DiscountCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT MixedDiscount.Get(DiscountCode) then
                InsertNewRec(MixedDiscount, DiscountCode, DiscountId);

        IF CheckFieldsChanged(MixedDiscount, JToken) then
            MixedDiscount.Modify(true);

        // handle mixedDiscountTimeIntervals
        IF ReplicationAPI.GetJsonArrayFromJsonToken(JToken, '$.mixedDiscountTimeIntervals', JArrayLines) then begin
            for i := 0 to JArrayLines.Count - 1 do begin
                JArrayLines.Get(i, JTokenLine);
                HandleArrayElementEntityTimeInterval(JTokenLine);
            end;
        end;
        Clear(JArrayLines);
        Clear(JTokenLine);

        // handle mixedDiscountLevels
        IF ReplicationAPI.GetJsonArrayFromJsonToken(JToken, '$.mixedDiscountLevels', JArrayLines) then begin
            for i := 0 to JArrayLines.Count - 1 do begin
                JArrayLines.Get(i, JTokenLine);
                HandleArrayElementEntityLevel(JTokenLine);
            end;
        end;
        Clear(JArrayLines);
        Clear(JTokenLine);

        // handle Period Discount Lines
        IF ReplicationAPI.GetJsonArrayFromJsonToken(JToken, '$.mixedDiscountLines', JArrayLines) then begin
            for i := 0 to JArrayLines.Count - 1 do begin
                JArrayLines.Get(i, JTokenLine);
                HandleArrayElementEntityLine(JTokenLine);
            end;
        end;

    end;

    local procedure HandleArrayElementEntityLine(JToken: JsonToken)
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        DiscountCode: Code[20];
        GroupingType: Enum "NPR Disc. Grouping Type";
        No: Code[20];
        VariantCode: Code[10];
        DiscountLineId: Text;
    begin
        DiscountCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(DiscountCode));
        IF Evaluate(GroupingType, ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.discGroupingType')) then;
        No := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.no'), 1, MaxStrLen(No));
        VariantCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.variantCode'), 1, MaxStrLen(VariantCode));
        DiscountLineId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.systemId');

        IF MixedDiscountLine.GetBySystemId(DiscountLineId) then begin
            RecFoundBySystemId := true;
            If (MixedDiscountLine.Code <> DiscountCode) OR (MixedDiscountLine."No." <> No) OR
             (MixedDiscountLine."Disc. Grouping Type" <> GroupingType) OR (MixedDiscountLine."Variant Code" <> VariantCode) then // rename!
                if NOT MixedDiscountLine.Rename(DiscountCode, GroupingType, No, VariantCode) then // maybe another rec with same pk already exists...
                    RecFoundBySystemId := false;
        end;

        IF Not RecFoundBySystemId then
            IF NOT MixedDiscountLine.Get(DiscountCode, GroupingType, No, VariantCode) then
                InsertNewRecLine(MixedDiscountLine, DiscountCode, GroupingType, No, VariantCode, DiscountLineId);

        IF CheckFieldsChangedLine(MixedDiscountLine, JToken) then
            MixedDiscountLine.Modify(true);
    end;

    local procedure HandleArrayElementEntityLevel(JToken: JsonToken)
    var
        MixedDiscountLevel: Record "NPR Mixed Discount Level";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        DiscountCode: Code[20];
        DiscountQty: Decimal;
        DiscountLevelId: Text;
    begin
        DiscountCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.mixedDiscountCode'), 1, MaxStrLen(DiscountCode));
        IF Evaluate(DiscountQty, ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.quantity')) then;
        DiscountLevelId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.systemId');

        IF MixedDiscountLevel.GetBySystemId(DiscountLevelId) then begin
            RecFoundBySystemId := true;
            If (MixedDiscountLevel."Mixed Discount Code" <> DiscountCode) OR (MixedDiscountLevel.Quantity <> DiscountQty) then // rename!
                if NOT MixedDiscountLevel.Rename(DiscountCode, DiscountQty) then // maybe another rec with same pk already exists...
                    RecFoundBySystemId := false;
        end;

        IF Not RecFoundBySystemId then
            IF NOT MixedDiscountLevel.Get(DiscountCode, DiscountQty) then
                InsertNewRecLevel(MixedDiscountLevel, DiscountCode, DiscountQty, DiscountLevelId);

        IF CheckFieldsChangedLevel(MixedDiscountLevel, JToken) then
            MixedDiscountLevel.Modify(true);
    end;

    local procedure HandleArrayElementEntityTimeInterval(JToken: JsonToken)
    var
        MixedDiscountTimeInterval: Record "NPR Mixed Disc. Time Interv.";
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        DiscountCode: Code[20];
        LineNo: Integer;
        DiscountTimeIntervalId: Text;
    begin
        DiscountCode := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.mixCode'), 1, MaxStrLen(DiscountCode));
        IF Evaluate(LineNo, ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.lineNo')) then;
        DiscountTimeIntervalId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.systemId');

        IF MixedDiscountTimeInterval.GetBySystemId(DiscountTimeIntervalId) then begin
            RecFoundBySystemId := true;
            If (MixedDiscountTimeInterval."Mix Code" <> DiscountCode) OR (MixedDiscountTimeInterval."Line No." <> LineNo) then // rename!
                if NOT MixedDiscountTimeInterval.Rename(DiscountCode, LineNo) then // maybe another rec with same pk already exists...
                    RecFoundBySystemId := false;
        end;

        IF Not RecFoundBySystemId then
            IF NOT MixedDiscountTimeInterval.Get(DiscountCode, LineNo) then
                InsertNewRecTimeInterval(MixedDiscountTimeInterval, DiscountCode, LineNo, DiscountTimeIntervalId);

        IF CheckFieldsChangedTimeInterval(MixedDiscountTimeInterval, JToken) then
            MixedDiscountTimeInterval.Modify(true);
    end;

    local procedure CheckFieldsChanged(var MixedDiscount: Record "NPR Mixed Discount"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Mix Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.mixType'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo(Lot), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.lot'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Min. Quantity"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.minQuantity'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Max. Quantity"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.maxQuantity'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo(Status), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.status'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("No. Serie"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.noSerie'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Discount Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.discountType'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Starting date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.startingdate'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Starting time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.startingtime'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Ending date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.endingdate'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Ending time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.endingtime'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Global Dimension 1 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.globalDimension1Code'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Global Dimension 2 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.globalDimension2Code'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Actual Discount Amount"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.actualDiscountAmount'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Actual Item Qty."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.actualItemQty'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Block Custom Discount"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.blockCustomDiscount'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Campaign Ref."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.campaignRef'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Created the"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.createdthe'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Item Discount %"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.itemDiscount'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Item Discount Qty."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.itemDiscountQty'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Total Amount"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.totalAmount'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Total Amount Excl. VAT"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.totalAmountExclVAT'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Total Discount %"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.totalDiscount'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(MixedDiscount, MixedDiscount.FieldNo("Total Discount Amount"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.totalDiscountAmount'), false) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldsChangedLine(var MixedDiscountLine: Record "NPR Mixed Discount Line"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo("Cross-Reference No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.crossReferenceNo'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo("Description 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.description2'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo("Starting Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.startingDate'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo("Starting Time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.startingTime'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo("Ending Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.endingDate'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo("Ending Time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.endingTime'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo(Priority), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.priority'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo(Quantity), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.quantity'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo(Status), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.status'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo("Vendor Item No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vendorItemNo'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLine(MixedDiscountLine, MixedDiscountLine.FieldNo("Vendor No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vendorNo'), false) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldsChangedLevel(var MixedDiscountLevel: Record "NPR Mixed Discount Level"; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValueLevel(MixedDiscountLevel, MixedDiscountLevel.FieldNo("Discount %"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.discount'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLevel(MixedDiscountLevel, MixedDiscountLevel.FieldNo("Discount Amount"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.discountAmount'), false) then
            FieldsChanged := true;

        IF CheckFieldValueLevel(MixedDiscountLevel, MixedDiscountLevel.FieldNo("Multiple Of"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.multipleOf'), false) then
            FieldsChanged := true;
    end;

    local procedure CheckFieldsChangedTimeInterval(var MixedDiscountTimeInterval: Record "NPR Mixed Disc. Time Interv."; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValueTimeInterval(MixedDiscountTimeInterval, MixedDiscountTimeInterval.FieldNo("Start Time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.startTime'), false) then
            FieldsChanged := true;

        IF CheckFieldValueTimeInterval(MixedDiscountTimeInterval, MixedDiscountTimeInterval.FieldNo("End Time"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.endTime'), false) then
            FieldsChanged := true;

        IF CheckFieldValueTimeInterval(MixedDiscountTimeInterval, MixedDiscountTimeInterval.FieldNo("Period Description"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.periodDescription'), false) then
            FieldsChanged := true;

        IF CheckFieldValueTimeInterval(MixedDiscountTimeInterval, MixedDiscountTimeInterval.FieldNo("Period Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.periodType'), false) then
            FieldsChanged := true;

        IF CheckFieldValueTimeInterval(MixedDiscountTimeInterval, MixedDiscountTimeInterval.FieldNo(Monday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.monday'), false) then
            FieldsChanged := true;

        IF CheckFieldValueTimeInterval(MixedDiscountTimeInterval, MixedDiscountTimeInterval.FieldNo(Tuesday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.tuesday'), false) then
            FieldsChanged := true;

        IF CheckFieldValueTimeInterval(MixedDiscountTimeInterval, MixedDiscountTimeInterval.FieldNo(Wednesday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.wednesday'), false) then
            FieldsChanged := true;

        IF CheckFieldValueTimeInterval(MixedDiscountTimeInterval, MixedDiscountTimeInterval.FieldNo(Thursday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.thursday'), false) then
            FieldsChanged := true;

        IF CheckFieldValueTimeInterval(MixedDiscountTimeInterval, MixedDiscountTimeInterval.FieldNo(Friday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.friday'), false) then
            FieldsChanged := true;

        IF CheckFieldValueTimeInterval(MixedDiscountTimeInterval, MixedDiscountTimeInterval.FieldNo(Saturday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.saturday'), false) then
            FieldsChanged := true;

        IF CheckFieldValueTimeInterval(MixedDiscountTimeInterval, MixedDiscountTimeInterval.FieldNo(Sunday), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.sunday'), false) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldValue(var MixedDiscount: Record "NPR Mixed Discount"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(MixedDiscount, RecRef) then
            exit(false);

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) THEN begin
            RecRef.SetTable(MixedDiscount);
            Exit(true);
        end;
    end;

    local procedure CheckFieldValueLine(var MixedDiscountLine: Record "NPR Mixed Discount Line"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(MixedDiscountLine, RecRef) then
            exit(false);

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) THEN begin
            RecRef.SetTable(MixedDiscountLine);
            Exit(true);
        end;
    end;

    local procedure CheckFieldValueLevel(var MixedDiscountLevel: Record "NPR Mixed Discount Level"; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(MixedDiscountLevel, RecRef) then
            exit(false);

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) THEN begin
            RecRef.SetTable(MixedDiscountLevel);
            Exit(true);
        end;
    end;

    local procedure CheckFieldValueTimeInterval(var MixedDiscountTimeInterval: Record "NPR Mixed Disc. Time Interv."; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(MixedDiscountTimeInterval, RecRef) then
            exit(false);

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) THEN begin
            RecRef.SetTable(MixedDiscountTimeInterval);
            Exit(true);
        end;
    end;

    local procedure InsertNewRec(var MixedDiscount: Record "NPR Mixed Discount"; DiscountCode: Code[20]; DiscountId: text)
    begin
        MixedDiscount.Init();
        MixedDiscount.Code := DiscountCode;
        IF DiscountId <> '' THEN begin
            IF Evaluate(MixedDiscount.SystemId, DiscountId) Then
                MixedDiscount.Insert(false, true)
            Else
                MixedDiscount.Insert(false);
        end else
            MixedDiscount.Insert(false);
    end;

    local procedure InsertNewRecLine(var MixedDiscountLine: Record "NPR Mixed Discount Line"; DiscountCode: Code[20]; GroupingType: Enum "NPR Disc. Grouping Type"; No: Code[20]; VariantCode: Code[10]; DiscountLineId: text)
    begin
        MixedDiscountLine.Init();
        MixedDiscountLine.Code := DiscountCode;
        MixedDiscountLine."Disc. Grouping Type" := GroupingType;
        MixedDiscountLine."No." := No;
        MixedDiscountLine."Variant Code" := VariantCode;
        IF DiscountLineId <> '' THEN begin
            IF Evaluate(MixedDiscountLine.SystemId, DiscountLineId) Then
                MixedDiscountLine.Insert(false, true)
            Else
                MixedDiscountLine.Insert(false);
        end else
            MixedDiscountLine.Insert(false);
    end;

    local procedure InsertNewRecLevel(var MixedDiscountLevel: Record "NPR Mixed Discount Level"; DiscountCode: Code[20]; DiscountQty: Decimal; DiscountLevelId: text)
    begin
        MixedDiscountLevel.Init();
        MixedDiscountLevel."Mixed Discount Code" := DiscountCode;
        MixedDiscountLevel.Quantity := DiscountQty;
        IF DiscountLevelId <> '' THEN begin
            IF Evaluate(MixedDiscountLevel.SystemId, DiscountLevelId) Then
                MixedDiscountLevel.Insert(false, true)
            Else
                MixedDiscountLevel.Insert(false);
        end else
            MixedDiscountLevel.Insert(false);
    end;

    local procedure InsertNewRecTimeInterval(var MixedDiscountTimeInterval: Record "NPR Mixed Disc. Time Interv."; DiscountCode: Code[20]; LineNo: Integer; DiscountTimeIntervalId: text)
    begin
        MixedDiscountTimeInterval.Init();
        MixedDiscountTimeInterval."Mix Code" := DiscountCode;
        MixedDiscountTimeInterval."Line No." := LineNo;
        IF DiscountTimeIntervalId <> '' THEN begin
            IF Evaluate(MixedDiscountTimeInterval.SystemId, DiscountTimeIntervalId) Then
                MixedDiscountTimeInterval.Insert(false, true)
            Else
                MixedDiscountTimeInterval.Insert(false);
        end else
            MixedDiscountTimeInterval.Insert(false);
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

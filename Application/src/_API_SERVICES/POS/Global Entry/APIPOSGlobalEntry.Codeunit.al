#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248189 "NPR API POS Global Entry"
{
    Access = Internal;

    procedure InsertPosSalesEntries(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
        TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary;
        TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary;
        TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary;
        NpGpPOSSalesInitMgt: Codeunit "NPR NpGp POS Sales Init Mgt.";
        Json: Codeunit "NPR JSON Builder";
        InsertedSystemId: Guid;
    begin
        if not ParseRequest(Request, TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry, TempNpGpPOSPaymentLine, Response) then
            exit(Response);

        InsertedSystemId := NpGpPOSSalesInitMgt.InsertPOSSalesEntry(TempNpGpPOSSalesEntry, TempNpGpPOSSalesLine, TempNpGpPOSInfoPOSEntry, TempNpGpPOSPaymentLine);

        exit(Response.RespondOK(Json.AddProperty('id', InsertedSystemId)));
    end;

    local procedure ParseRequest(var Request: Codeunit "NPR API Request"; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonToken;
        Token: JsonToken;
    begin
        Body := Request.BodyJson();
        if not InsertPOSSalesEntry(Body, TempNpGpPOSSalesEntry, Response) then
            exit(false);
        if JsonHelper.GetJsonToken(Body, 'salesLines', Token) then
            if not InsertPOSSalesLines(Token, TempNpGpPOSSalesEntry."Entry No.", TempNpGpPOSSalesLine, Response) then
                exit(false);
        if JsonHelper.GetJsonToken(Body, 'paymentLines', Token) then
            if not InsertPOSPaymentLines(Token, TempNpGpPOSSalesEntry, TempNpGpPOSPaymentLine, Response) then
                exit(false);
        if JsonHelper.GetJsonToken(Body, 'posInfos', Token) then
            if not InsertPOSInfoEntries(Token, TempNpGpPOSSalesEntry."Entry No.", TempNpGpPOSInfoPOSEntry, Response) then
                exit(false);

        exit(true);
    end;

    local procedure InsertPOSSalesEntry(Body: JsonToken; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        RecRef: RecordRef;
        ExtensionFields: JsonToken;
    begin
        TempNpGpPOSSalesEntry.Init();
#pragma warning disable AA0139
        TempNpGpPOSSalesEntry."POS Store Code" := JsonHelper.GetJCode(Body, 'posStore', true);
        TempNpGpPOSSalesEntry."POS Unit No." := JsonHelper.GetJCode(Body, 'posUnit', true);
        TempNpGpPOSSalesEntry."Document No." := JsonHelper.GetJCode(Body, 'documentNo', true);
        if not IsUnique(TempNpGpPOSSalesEntry) then begin
            Response.CreateErrorResponse(Enum::"NPR API Error Code"::globalsale_duplicate_key, StrSubstNo('Duplicate entry: Global Sale posStore=%1, posUnit=%2, documentNo=%3 already exist.', TempNpGpPOSSalesEntry."POS Store Code", TempNpGpPOSSalesEntry."POS Unit No.", TempNpGpPOSSalesEntry."Document No."));
            exit(false);
        end;
        TempNpGpPOSSalesEntry."Entry Time" := TextToDatetime(JsonHelper.GetJText(Body, 'entryTime', true));
        Evaluate(TempNpGpPOSSalesEntry."Entry Type", JsonHelper.GetJText(Body, 'entryType', true));
        if not (TempNpGpPOSSalesEntry."Entry Type" in [TempNpGpPOSSalesEntry."Entry Type"::"Direct Sale", TempNpGpPOSSalesEntry."Entry Type"::"Credit Sale"]) then begin
            Response.RespondBadRequest(StrSubstNo('Invalid value for entryType. Options are %1 and %2', TempNpGpPOSSalesEntry."Entry Type"::"Direct Sale", TempNpGpPOSSalesEntry."Entry Type"::"Credit Sale"));
            exit(false);
        end;
        TempNpGpPOSSalesEntry."Posting Date" := JsonHelper.GetJDate(Body, 'postingDate', true);
        TempNpGpPOSSalesEntry."Fiscal No." := JsonHelper.GetJText(Body, 'fiscalNumber', true);
        TempNpGpPOSSalesEntry."Sales Amount" := JsonHelper.GetJDecimal(Body, 'salesAmount', true);
        TempNpGpPOSSalesEntry."Discount Amount" := JsonHelper.GetJDecimal(Body, 'discountAmount', true);
        TempNpGpPOSSalesEntry."Total Amount" := JsonHelper.GetJDecimal(Body, 'totalAmountExclVAT', true);
        TempNpGpPOSSalesEntry."Total Amount Incl. Tax" := JsonHelper.GetJDecimal(Body, 'totalAmountInclVAT', true);
        TempNpGpPOSSalesEntry."Total Tax Amount" := JsonHelper.GetJDecimal(Body, 'totalVATAmount', true);

        TempNpGpPOSSalesEntry."Original Company" := JsonHelper.GetJText(Body, 'company', false);
        TempNpGpPOSSalesEntry."Customer No." := JsonHelper.GetJText(Body, 'customerNo', false);
        TempNpGpPOSSalesEntry."Salesperson Code" := JsonHelper.GetJText(Body, 'salesperson', false);
        TempNpGpPOSSalesEntry."Currency Code" := JsonHelper.GetJText(Body, 'currencyCode', false);
        TempNpGpPOSSalesEntry."Currency Factor" := JsonHelper.GetJDecimal(Body, 'currencyFactor', false);
        if TempNpGpPOSSalesEntry."Currency Factor" = 0 then
            TempNpGpPOSSalesEntry."Currency Factor" := 1;
        if JsonHelper.GetJsonToken(Body, 'extensionFields', ExtensionFields) then begin
            if (not ExtensionFields.IsArray()) then begin
                Response.RespondBadRequest('The extensionFields property must be an array.');
                exit(false);
            end;
            RecRef.GetTable(TempNpGpPOSSalesEntry);
            ApplyExtensionFields(RecRef, ExtensionFields.AsArray());
            RecRef.SetTable(TempNpGpPOSSalesEntry);
        end;
#pragma warning restore
        TempNpGpPOSSalesEntry.Insert(false);
        exit(true);
    end;

    local procedure InsertPOSSalesLines(SalesLines: JsonToken; POSSalesEntryNo: Integer; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        SalesLine: JsonToken;
    begin
        if (not SalesLines.IsArray()) then begin
            Response.RespondBadRequest('The salesLines property must be an array.');
            exit(false);
        end;
        foreach SalesLine in SalesLines.AsArray() do
            if not InsertPOSSalesLine(SalesLine, POSSalesEntryNo, TempNpGpPOSSalesLine, Response) then
                exit(false);
        exit(true);
    end;

    local procedure InsertPOSSalesLine(SalesLine: JsonToken; POSSalesEntryNo: Integer; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        RecRef: RecordRef;
        ExtensionFields: JsonToken;
    begin
        TempNpGpPOSSalesLine.Init();
        TempNpGpPOSSalesLine."POS Entry No." := POSSalesEntryNo;
        TempNpGpPOSSalesLine."Line No." := JsonHelper.GetJInteger(SalesLine, 'lineNo', true);
        Evaluate(TempNpGpPOSSalesLine.Type, JsonHelper.GetJText(SalesLine, 'type', true));
#pragma warning disable AA0139
        TempNpGpPOSSalesLine."No." := JsonHelper.GetJText(SalesLine, 'code', false);
        TempNpGpPOSSalesLine.Quantity := JsonHelper.GetJDecimal(SalesLine, 'quantity', true);
        TempNpGpPOSSalesLine."Quantity (Base)" := JsonHelper.GetJDecimal(SalesLine, 'baseQuantity', true);
        if TempNpGpPOSSalesLine.Quantity <> 0 then
            TempNpGpPOSSalesLine."Qty. per Unit of Measure" := TempNpGpPOSSalesLine."Quantity (Base)" / TempNpGpPOSSalesLine.Quantity;
        TempNpGpPOSSalesLine."Unit Price" := JsonHelper.GetJDecimal(SalesLine, 'unitPrice', true);
        TempNpGpPOSSalesLine."VAT %" := JsonHelper.GetJDecimal(SalesLine, 'vatPct', true);
        TempNpGpPOSSalesLine."Line Discount %" := JsonHelper.GetJDecimal(SalesLine, 'lineDiscountPct', true);
        TempNpGpPOSSalesLine."Line Discount Amount Excl. VAT" := JsonHelper.GetJDecimal(SalesLine, 'lineDiscountAmountExclVAT', true);
        TempNpGpPOSSalesLine."Line Discount Amount Incl. VAT" := JsonHelper.GetJDecimal(SalesLine, 'lineDiscountAmountInclVAT', true);
        TempNpGpPOSSalesLine."Line Amount" := JsonHelper.GetJDecimal(SalesLine, 'lineAmount', true);
        TempNpGpPOSSalesLine."Amount Excl. VAT" := JsonHelper.GetJDecimal(SalesLine, 'amountExclVAT', true);
        TempNpGpPOSSalesLine."Amount Incl. VAT" := JsonHelper.GetJDecimal(SalesLine, 'amountInclVAT', true);
        TempNpGpPOSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)" := JsonHelper.GetJDecimal(SalesLine, 'lineDiscountAmountExclVATLCY', true);
        TempNpGpPOSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)" := JsonHelper.GetJDecimal(SalesLine, 'lineDiscountAmountInclVATLCY', true);
        TempNpGpPOSSalesLine."Amount Excl. VAT (LCY)" := JsonHelper.GetJDecimal(SalesLine, 'amountExclVATLCY', true);
        TempNpGpPOSSalesLine."Amount Incl. VAT (LCY)" := JsonHelper.GetJDecimal(SalesLine, 'amountInclVATLCY', true);

        TempNpGpPOSSalesLine."Currency Code" := JsonHelper.GetJText(SalesLine, 'currencyCode', false);
        TempNpGpPOSSalesLine."Global Reference" := JsonHelper.GetJText(SalesLine, 'globalReference', false);
        TempNpGpPOSSalesLine."Unit of Measure Code" := JsonHelper.GetJText(SalesLine, 'unitOfMeasureCode', false);
        TempNpGpPOSSalesLine."Variant Code" := JsonHelper.GetJText(SalesLine, 'variantCode', false);
        TempNpGpPOSSalesLine."Cross-Reference No." := JsonHelper.GetJText(SalesLine, 'referenceNumber', false);
        TempNpGpPOSSalesLine."BOM Item No." := JsonHelper.GetJText(SalesLine, 'bomItemCode', false);
        TempNpGpPOSSalesLine."Location Code" := JsonHelper.GetJText(SalesLine, 'locationCode', false);
        TempNpGpPOSSalesLine.Description := JsonHelper.GetJText(SalesLine, 'description', false);
        TempNpGpPOSSalesLine."Description 2" := JsonHelper.GetJText(SalesLine, 'description2', false);
#pragma warning restore
        if JsonHelper.GetJsonToken(SalesLine, 'extensionFields', ExtensionFields) then begin
            if (not ExtensionFields.IsArray()) then begin
                Response.RespondBadRequest('The extensionFields property must be an array.');
                exit(false);
            end;
            RecRef.GetTable(TempNpGpPOSSalesLine);
            ApplyExtensionFields(RecRef, ExtensionFields.AsArray());
            RecRef.SetTable(TempNpGpPOSSalesLine);
        end;

        TempNpGpPOSSalesLine.Insert(false);
        exit(true);
    end;

    local procedure InsertPOSPaymentLines(PaymentLines: JsonToken; TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        PaymentLine: JsonToken;
    begin
        if (not PaymentLines.IsArray()) then begin
            Response.RespondBadRequest('The paymentLines property must be an array.');
            exit(false);
        end;
        foreach PaymentLine in PaymentLines.AsArray() do
            if not InsertPOSPaymentLine(PaymentLine, TempNpGpPOSSalesEntry, TempNpGpPOSPaymentLine, Response) then
                exit(false);
        exit(true);
    end;

    local procedure InsertPOSPaymentLine(PaymentLine: JsonToken; TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        RecRef: RecordRef;
        ExtensionFields: JsonToken;
    begin
        TempNpGpPOSPaymentLine.Init();
        TempNpGpPOSPaymentLine."POS Entry No." := TempNpGpPOSSalesEntry."Entry No.";
        TempNpGpPOSPaymentLine."Line No." := JsonHelper.GetJInteger(PaymentLine, 'lineNo', true);
#pragma warning disable AA0139
        TempNpGpPOSPaymentLine."POS Payment Method Code" := JsonHelper.GetJText(PaymentLine, 'paymentMethod', true);
        TempNpGpPOSPaymentLine."Amount (LCY)" := JsonHelper.GetJDecimal(PaymentLine, 'amountLCY', true);
        TempNpGpPOSPaymentLine."Payment Amount" := JsonHelper.GetJDecimal(PaymentLine, 'amount', true);
        TempNpGpPOSPaymentLine."Document No." := JsonHelper.GetJCode(PaymentLine, 'documentNo', false);
        if TempNpGpPOSPaymentLine."Document No." = '' then
            TempNpGpPOSPaymentLine."Document No." := TempNpGpPOSSalesEntry."Document No.";
        TempNpGpPOSPaymentLine.Description := JsonHelper.GetJText(PaymentLine, 'description', false);
        TempNpGpPOSPaymentLine."Currency Code" := JsonHelper.GetJText(PaymentLine, 'currencyCode', false);
#pragma warning restore
        if JsonHelper.GetJsonToken(PaymentLine, 'extensionFields', ExtensionFields) then begin
            if (not ExtensionFields.IsArray()) then begin
                Response.RespondBadRequest('The extensionFields property must be an array.');
                exit(false);
            end;
            RecRef.GetTable(TempNpGpPOSPaymentLine);
            ApplyExtensionFields(RecRef, ExtensionFields.AsArray());
            RecRef.SetTable(TempNpGpPOSPaymentLine);
        end;
        TempNpGpPOSPaymentLine.Insert(false);
        exit(true);
    end;

    local procedure InsertPOSInfoEntries(POSInfos: JsonToken; POSSalesEntryNo: Integer; var TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        POSInfo: JsonToken;
    begin
        if (not POSInfos.IsArray()) then begin
            Response.RespondBadRequest('The posInfos property must be an array.');
            exit(false);
        end;
        foreach POSInfo in POSInfos.AsArray() do
            if not InsertPOSInfoEntry(POSInfo, POSSalesEntryNo, TempNpGpPOSInfoPOSEntry, Response) then
                exit(false);
        exit(true);
    end;

    local procedure InsertPOSInfoEntry(POSInfo: JsonToken; POSSalesEntryNo: Integer; var TempNpGpPOSInfoPOSEntry: Record "NPR NpGp POS Info POS Entry" temporary; var Response: Codeunit "NPR API Response"): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
        RecRef: RecordRef;
        ExtensionFields: JsonToken;
    begin
        TempNpGpPOSInfoPOSEntry.Init();
        TempNpGpPOSInfoPOSEntry."POS Entry No." := POSSalesEntryNo;
        TempNpGpPOSInfoPOSEntry."Entry No." := JsonHelper.GetJInteger(POSInfo, 'lineNo', true);
#pragma warning disable AA0139
        TempNpGpPOSInfoPOSEntry."POS Info Code" := JsonHelper.GetJText(POSInfo, 'infoCode', false);
        TempNpGpPOSInfoPOSEntry."No." := JsonHelper.GetJText(POSInfo, 'code', false);
        TempNpGpPOSInfoPOSEntry."Sales Line No." := JsonHelper.GetJInteger(POSInfo, 'saleLineNo', false);
        TempNpGpPOSInfoPOSEntry."POS Info" := JsonHelper.GetJText(POSInfo, 'description', false);
        TempNpGpPOSInfoPOSEntry.Quantity := JsonHelper.GetJDecimal(POSInfo, 'quantity', false);
        TempNpGpPOSInfoPOSEntry.Price := JsonHelper.GetJDecimal(POSInfo, 'price', false);
        TempNpGpPOSInfoPOSEntry."Net Amount" := JsonHelper.GetJDecimal(POSInfo, 'netAmount', false);
        TempNpGpPOSInfoPOSEntry."Gross Amount" := JsonHelper.GetJDecimal(POSInfo, 'grossAmount', false);
        TempNpGpPOSInfoPOSEntry."Discount Amount" := JsonHelper.GetJDecimal(POSInfo, 'discountAmount', false);
#pragma warning restore

        if JsonHelper.GetJsonToken(POSInfo, 'extensionFields', ExtensionFields) then begin
            if (not ExtensionFields.IsArray()) then begin
                Response.RespondBadRequest('The extensionFields property must be an array.');
                exit(false);
            end;
            RecRef.GetTable(TempNpGpPOSInfoPOSEntry);
            ApplyExtensionFields(RecRef, ExtensionFields.AsArray());
            RecRef.SetTable(TempNpGpPOSInfoPOSEntry);
        end;
        TempNpGpPOSInfoPOSEntry.Insert(false);
        exit(true);
    end;

    local procedure IsUnique(var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary): Boolean
    var
        NpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry";
    begin
        NpGpPOSSalesEntry.SetRange("POS Store Code", TempNpGpPOSSalesEntry."POS Store Code");
        NpGpPOSSalesEntry.SetRange("POS Unit No.", TempNpGpPOSSalesEntry."POS Unit No.");
        NpGpPOSSalesEntry.SetRange("Document No.", TempNpGpPOSSalesEntry."Document No.");
        exit(NpGpPOSSalesEntry.IsEmpty);
    end;

    local procedure ApplyExtensionFields(var RecRef: RecordRef; ExtensionFields: JsonArray)
    var
        APIPOSGlobalEntryExt: Codeunit "NPR API POS Global Entry Ext";
        Token: JsonToken;
        ExtensionData: Dictionary of [Integer, JsonToken];
        FieldId: Integer;
    begin
        foreach Token in ExtensionFields do
            AddExtensionData(Token, ExtensionData);
        APIPOSGlobalEntryext.OnBeforeApplyExtensionFields(RecRef, ExtensionData);
        foreach FieldId in ExtensionData.Keys() do
            ApplyExtensionField(RecRef, FieldId, ExtensionData.Get(FieldId));
    end;

    local procedure AddExtensionData(ExtensionField: JsonToken; var ExtensionData: Dictionary of [Integer, JsonToken])
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Token: JsonToken;
    begin
        if JsonHelper.GetJsonToken(ExtensionField, 'fieldValue', Token) then;
        ExtensionData.Add(JsonHelper.GetJInteger(ExtensionField, 'fieldId', true), Token);
    end;

    local procedure ApplyExtensionField(var RecRef: RecordRef; FieldId: Integer; ExtensionValue: JsonToken)
    var
        ConvertHelper: Codeunit "NPR Convert Helper";
        FldRef: FieldRef;
    begin
        if not ExtensionValue.IsValue then
            exit;
        FldRef := RecRef.Field(FieldId);
        ConvertHelper.JValueToFieldRef(ExtensionValue.AsValue(), FldRef, TextEncoding::UTF8);
    end;

    local procedure TextToDatetime(TextValue: Text): DateTime
    var
        DateTimeValue: DateTime;
    begin
        Evaluate(DateTimeValue, TextValue);
        exit(DateTimeValue);
    end;

}
#endif
codeunit 6014686 "NPR Rep. Get Currencies" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetCurrencies_%1', Comment = '%1=Current Date and Time';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetCurrencies(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetCurrencies(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
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
        Currency: Record Currency;
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        CurrencyCode: Code[10];
        CurrencyId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        CurrencyCode := CopyStr(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.code'), 1, MaxStrLen(CurrencyCode));
        CurrencyId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF CurrencyId <> '' then
            IF Currency.GetBySystemId(CurrencyId) then begin
                RecFoundBySystemId := true;
                If Currency."Code" <> CurrencyCode then // rename!
                    if NOT Currency.Rename(CurrencyCode) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT Currency.Get(CurrencyCode) then
                InsertNewRec(Currency, CurrencyCode, CurrencyId);

        IF CheckFieldsChanged(Currency, JToken) then
            Currency.Modify(true);
    end;

    local procedure CheckFieldsChanged(var Currency: Record Currency; JToken: JsonToken) FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        IF CheckFieldValue(Currency, Currency.FieldNo(Description), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Last Date Modified"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.lastDateModified'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Last Date Adjusted"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.lastDateAdjusted'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo(Symbol), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.symbol'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("ISO Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.isoCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("ISO Numeric Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.isoNumericCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Unrealized Gains Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unrealizedGainsAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Realized Gains Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.realizedGainsAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Unrealized Losses Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unrealizedLossesAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Realized Losses Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.realizedLossesAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Invoice Rounding Precision"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.invoiceRoundingPrecision'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Invoice Rounding Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.invoiceRoundingType'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Amount Rounding Precision"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.amountRoundingPrecision'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Unit-Amount Rounding Precision"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitAmountRoundingPrecision'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Amount Decimal Places"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.amountDecimalPlaces'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Unit-Amount Decimal Places"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.unitAmountDecimalPlaces'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Realized G/L Gains Account"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.realizedGLGainsAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Realized G/L Losses Account"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.realizedGLLossesAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Appln. Rounding Precision"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.applnRoundingPrecision'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("EMU Currency"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.emuCurrency'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Currency Factor"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.currencyFactor'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Residual Gains Account"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.residualGainsAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Residual Losses Account"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.residualLossesAccount'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Conv. LCY Rndg. Debit Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.convLCYRndgDebitAcc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Conv. LCY Rndg. Credit Acc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.convLCYRndgCreditAcc'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Max. VAT Difference Allowed"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.maxVATDifferenceAllowed'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("VAT Rounding Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vatRoundingType'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Payment Tolerance %"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.paymentTolerancePercent'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Currency, Currency.FieldNo("Max. Payment Tolerance Amount"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.maxPaymentToleranceAmount'), true) then
            FieldsChanged := true;

    end;

    local procedure CheckFieldValue(var Currency: Record Currency; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(Currency, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(Currency);
            exit(true);
        end;
    end;

    local procedure InsertNewRec(var Currency: Record Currency; CurrencyCode: Code[10]; CurrencyId: text)
    begin
        Currency.Init();
        Currency.Code := CurrencyCode;
        IF CurrencyId <> '' THEN begin
            IF Evaluate(Currency.SystemId, CurrencyId) Then
                Currency.Insert(false, true)
            Else
                Currency.Insert(false);
        end else
            Currency.Insert(false);
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
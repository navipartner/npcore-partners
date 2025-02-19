#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248216 "NPR API External POS Sale" implements "NPR API Request Handler"
{
    Access = Internal;

    procedure Handle(var Request: codeunit "NPR API Request"): codeunit "NPR API Response"
    begin
        case true of
            /**
             * Until we have pagination helpers in place, we will leave the list endpoint out
             *
             * Request.Match('GET', '/externalpos/sales'):
             *     exit(ListSales());
             */
            Request.Match('GET', '/externalpos/sales/:saleId'):
                exit(GetSale(Request));
            Request.Match('POST', '/externalpos/sales'):
                exit(CreateSale(Request));
        end;
    end;

    /**
     * Until we have pagination helpers in place, we will leave the list endpoint out
     *
    local procedure ListSales() Response: Codeunit "NPR API Response"
    var
        ExternalPOSSale: Record "NPR External POS Sale";
        Json: Codeunit "NPR Json Builder";
    begin
        // TODO: Change to use the optional cache clear included in PR
        // https://github.com/navipartner/npcore/pull/8009
        SelectLatestVersion();

        Json.StartArray();

        SetLoadFieldsOnSale(ExternalPOSSale);
        ExternalPOSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        if (ExternalPOSSale.FindSet()) then
            repeat
                Json.AddObject(SaleToJson(Json, ExternalPOSSale));
            until ExternalPOSSale.Next() = 0;
        Json.EndArray();

        exit(Response.RespondOK(Json.BuildAsArray()));
    end;
    */

    internal procedure GetSale(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        ExternalPOSSale: Record "NPR External POS Sale";
        Json: Codeunit "NPR Json Builder";
        saleId: Text;
    begin
        saleId := Request.Paths().Get(3);
        if (saleId = '') then
            exit(Response.RespondBadRequest('Missing required path parameter: saleId'));

        // TODO: Change to use the optional cache clear included in PR
        // https://github.com/navipartner/npcore/pull/8009
        SelectLatestVersion();

        SetLoadFieldsOnSale(ExternalPOSSale);
        ExternalPOSSale.ReadIsolation := IsolationLevel::ReadCommitted;
        if (not ExternalPOSSale.GetBySystemId(saleId)) then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(SaleToJson(Json, ExternalPOSSale)));
    end;

    internal procedure CreateSale(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        CreateJson: JsonObject;
        Success: Boolean;
        TryCreateSale: Codeunit "NPR Try Create Ext POS Sale";
    begin
        CreateJson := Request.BodyJson().AsObject();

        if (not VerifyRequest(CreateJson, Response)) then
            exit(Response);

        TryCreateSale.SetParameters(CreateJson, Response);
        Success := TryCreateSale.Run();

        if (Response.IsInitialized()) then
            exit(Response);

        if (not Success) then
            Error(GetLastErrorText());

        Error('An unknown internal error occured, the response was not properly initialized, yet the system did not throw any errors.');
    end;

    local procedure VerifyRequest(RequestJson: JsonObject; var Response: Codeunit "NPR API Response"): Boolean
    var
        BufDateTime: DateTime;
        BufText: Text;
        BufBool: Boolean;
        BufDec: Decimal;
        TempJToken: JsonToken;
        TempJObject: JsonObject;
    begin
        if not (
            CheckRequiredField(RequestJson, 'startedAt', BufDateTime, Response) and
            CheckRequiredField(RequestJson, 'posStore', BufText, Response) and
            CheckRequiredField(RequestJson, 'posUnit', BufText, Response) and
            CheckRequiredField(RequestJson, 'pricesIncludeVAT', BufBool, Response)
        ) then
            exit(false);

        if not (
            RequestJson.SelectToken('saleLines', TempJToken) and
            TempJToken.IsArray()
        ) then begin
            Response.RespondBadRequest('''saleLines'' must be included in the request and be an array.');
            exit(false);
        end;

        foreach TempJToken in TempJToken.AsArray() do begin
            if (not TempJToken.IsObject()) then begin
                Response.RespondBadRequest('Each element in ''saleLines'' must be an object.');
                exit(false);
            end;

            TempJObject := TempJToken.AsObject();
            if not (
                CheckRequiredField(TempJObject, 'type', BufText, Response) and
                CheckRequiredField(TempJObject, 'code', BufText, Response) and
                CheckRequiredField(TempJObject, 'qty', BufDec, Response) and
                CheckRequiredField(TempJObject, 'unitPrice', BufDec, Response) and
                CheckRequiredField(TempJObject, 'amountIncludingVAT', BufDec, Response) and
                CheckRequiredField(TempJObject, 'discountAmount', BufDec, Response) and
                CheckRequiredField(TempJObject, 'description', BufText, Response)
            ) then
                exit(false);
        end;

        if not (
            RequestJson.SelectToken('paymentLines', TempJToken) and
            TempJToken.IsArray()
        ) then begin
            Response.RespondBadRequest('''paymentLines'' must be included in the request and be an array.');
            exit(false);
        end;

        foreach TempJToken in TempJToken.AsArray() do begin
            if (not TempJToken.IsObject()) then begin
                Response.RespondBadRequest('Each element in ''paymentLines'' must be an object.');
                exit(false);
            end;

            TempJObject := TempJToken.AsObject();
            if not (
                CheckRequiredField(TempJObject, 'paymentMethodCode', BufText, Response) and
                CheckRequiredField(TempJObject, 'description', BufText, Response) and
                CheckRequiredField(TempJObject, 'amountIncludingVAT', BufDec, Response)
            ) then
                exit(false);

            /**
             * If the caller provided `additionalEftData` we must verify that they
             * included all the required fields of that object.
             */
            if (TempJObject.SelectToken('additionalEftData', TempJToken)) then begin
                if (not TempJToken.IsObject()) then begin
                    Response.RespondBadRequest('''additionalEftData'' must be an object.');
                    exit(false);
                end;

                TempJObject := TempJToken.AsObject();
                if not (
                    CheckRequiredField(TempJObject, 'eftType', BufText, Response) and
                    CheckRequiredField(TempJObject, 'eftData', BufText, Response)
                ) then
                    exit(false);
            end;
        end;

        exit(true);
    end;

    local procedure CheckRequiredField(RequestJson: JsonObject; FieldName: Text; VariantType: Variant; var Response: Codeunit "NPR API Response"): Boolean
    var
        TempJToken: JsonToken;
        TempJValue: JsonValue;
    begin
        if (not RequestJson.SelectToken(FieldName, TempJToken)) then begin
            Response.RespondBadRequest(StrSubstNo('''%1'' must be included in the request.', FieldName));
            exit(false);
        end;

        if (not TempJToken.IsValue()) then begin
            Response.RespondBadRequest(StrSubstNo('''%1'' value is malformed.'));
            exit(false);
        end;

        TempJValue := TempJToken.AsValue();

        if ((TempJValue.IsNull()) or (TempJValue.IsUndefined())) then begin
            Response.RespondBadRequest(StrSubstNo('''%1'' value must not be null, undefined, or otherwise empty.'));
            exit(false);
        end;

        if (not TryValueAsVariant(TempJValue, VariantType)) then begin
            Response.RespondBadRequest(StrSubstNo('''%1'' value is not in the correct format.', FieldName));
            exit(false);
        end;

        exit(true);
    end;

    [TryFunction]
    local procedure TryValueAsVariant(Value: JsonValue; var Variant: Variant)
    begin
        case true of
            Variant.IsBigInteger():
                Variant := Value.AsBigInteger();
            Variant.IsBoolean():
                Variant := Value.AsBoolean();
            Variant.IsCode():
                Variant := Value.AsCode();
            Variant.IsDate():
                Variant := Value.AsDate();
            Variant.IsDateTime():
                Variant := Value.AsDateTime();
            Variant.IsDecimal():
                Variant := Value.AsDecimal();
            Variant.IsGuid():
                Evaluate(Variant, Value.AsText());
            Variant.IsInteger():
                Variant := Value.AsInteger();
            Variant.IsText():
                Variant := Value.AsText();
            Variant.IsTime():
                Variant := Value.AsTime();
        end;
    end;

    local procedure SetLoadFieldsOnSale(var ExternalPOSSale: Record "NPR External POS Sale")
    begin
        ExternalPOSSale.SetLoadFields(
            ExternalPOSSale."Entry No.",
            ExternalPOSSale.Date,
            ExternalPOSSale."Start Time",
            ExternalPOSSale."POS Store Code",
            ExternalPOSSale."Register No.",
            ExternalPOSSale."Sales Ticket No.",
            ExternalPOSSale."Salesperson Code",
            ExternalPOSSale."Customer No.",
            ExternalPOSSale."Prices Including VAT",
            ExternalPOSSale."External Document No.",
            ExternalPOSSale."Converted To POS Entry",
            ExternalPOSSale."POS Entry System Id",
            ExternalPOSSale.SystemId
        );
    end;

    #region JSON serialization
    internal procedure SaleToJson(var Json: Codeunit "NPR Json Builder"; ExternalPOSSale: Record "NPR External POS Sale"): Codeunit "NPR Json Builder"
    var
        ExternalPOSSaleLine: Record "NPR External POS Sale Line";
        Customer: Record Customer;
    begin
        Json.StartObject()
            .AddProperty('saleId', Format(ExternalPOSSale.SystemId, 0, 4).ToLower())
            .AddProperty('startedAt', CreateDateTime(ExternalPOSSale.Date, ExternalPOSSale."Start Time"))
            .AddProperty('posStore', ExternalPOSSale."POS Store Code")
            .AddProperty('posUnit', ExternalPOSSale."Register No.")
            .AddProperty('receiptNo', ExternalPOSSale."Sales Ticket No.")
            .AddProperty('salespersonCode', ExternalPOSSale."Salesperson Code");
        if (ExternalPOSSale."Customer No." <> '') then begin
            Customer.SetLoadFields("No.", SystemId);
            if (Customer.Get(ExternalPOSSale."Customer No.")) then
                Json.AddProperty('customerId', Format(Customer.SystemId, 0, 4).ToLower());
        end;
        Json.AddProperty('pricesIncludeVAT', ExternalPOSSale."Prices Including VAT");
        if (ExternalPOSSale."External Document No." <> '') then
            Json.AddProperty('externalDocumentNo', ExternalPOSSale."External Document No.");
        Json.AddProperty('convertedToPOSEntry', ExternalPOSSale."Converted To POS Entry");
        if (not IsNullGuid(ExternalPOSSale."POS Entry System Id")) then
            Json.AddProperty('posEntrySystemId', Format(ExternalPOSSale."POS Entry System Id", 0, 4).ToLower());

        Json.StartArray('saleLines');
        ExternalPOSSaleLine.ReadIsolation := IsolationLevel::ReadCommitted;
        ExternalPOSSaleLine.SetRange("External POS Sale Entry No.", ExternalPOSSale."Entry No.");
        ExternalPOSSaleLine.SetFilter("Line Type", '<>%1', Enum::"NPR POS Sale Line Type"::"POS Payment");
        if (ExternalPOSSaleLine.FindSet()) then
            repeat
                Json.AddObject(SaleLineToJson(Json, ExternalPOSSaleLine));
            until ExternalPOSSaleLine.Next() = 0;
        Json.EndArray();

        Json.StartArray('paymentLines');
        ExternalPOSSaleLine.SetFilter("Line Type", '=%1', Enum::"NPR POS Sale Line Type"::"POS Payment");
        if (ExternalPOSSaleLine.FindSet()) then
            repeat
                Json.AddObject(PaymentLineToJson(Json, ExternalPOSSaleLine));
            until ExternalPOSSaleLine.Next() = 0;
        Json.EndArray();

        Json.EndObject();
        exit(Json);
    end;

    internal procedure SaleLineToJson(var Json: Codeunit "NPR Json Builder"; ExternalPOSSaleLine: Record "NPR External POS Sale Line"): Codeunit "NPR Json Builder"
    begin
        Json.StartObject()
            .AddProperty('lineId', Format(ExternalPOSSaleLine.SystemId, 0, 4).ToLower())
            .AddProperty('type', ExternalPOSSaleLine."Line Type".Names().Get(ExternalPOSSaleLine."Line Type".Ordinals().IndexOf(ExternalPOSSaleLine."Line Type".AsInteger())))
            .AddProperty('code', ExternalPOSSaleLine."No.");
        if (ExternalPOSSaleLine."Variant Code" <> '') then
            Json.AddProperty('variantCode', ExternalPOSSaleLine."Variant Code");
        Json.AddProperty('qty', ExternalPOSSaleLine.Quantity)
            .AddProperty('unitPrice', ExternalPOSSaleLine."Unit Price")
            .AddProperty('vatPercent', ExternalPOSSaleLine."VAT %")
            .AddProperty('amount', ExternalPOSSaleLine.Amount)
            .AddProperty('amountIncludingVAT', ExternalPOSSaleLine."Amount Including VAT");
        if (ExternalPOSSaleLine."Discount Type" <> ExternalPOSSaleLine."Discount Type"::" ") then
            Json.AddProperty('discountType', FormatDiscountType(ExternalPOSSaleLine."Discount Type"));
        Json.AddProperty('discountAmount', ExternalPOSSaleLine."Discount Amount");
        if (ExternalPOSSaleLine."Unit of Measure Code" <> '') then
            Json.AddProperty('unitOfMeasureCode', ExternalPOSSaleLine."Unit of Measure Code");
        Json.AddProperty('description', ExternalPOSSaleLine.Description);
        if (ExternalPOSSaleLine."Description 2" <> '') then
            Json.AddProperty('description2', ExternalPOSSaleLine."Description 2");
        if (ExternalPOSSaleLine."Return Reason Code" <> '') then
            Json.AddProperty('returnReasonCode', ExternalPOSSaleLine."Return Reason Code");
        Json.EndObject();
        exit(Json);
    end;

    internal procedure PaymentLineToJson(var Json: Codeunit "NPR Json Builder"; ExternalPOSSaleLine: Record "NPR External POS Sale Line"): Codeunit "NPR Json Builder"
    begin
        Json.StartObject()
            .AddProperty('lineId', Format(ExternalPOSSaleLine.SystemId, 0, 4).ToLower())
            .AddProperty('paymentMethodCode', ExternalPOSSaleLine."No.")
            .AddProperty('description', ExternalPOSSaleLine.Description)
            .AddProperty('amountIncludingVAT', ExternalPOSSaleLine."Amount Including VAT");
        if (ExternalPOSSaleLine."Currency Amount" <> 0) then
            Json.AddProperty('currencyAmount', ExternalPOSSaleLine."Currency Amount");
        Json.EndObject();
        exit(Json);
    end;

    local procedure FormatDiscountType(DiscountType: Option " ",Campaign,Mix,Quantity,Manual,"BOM List",,Rounding,Combination,Customer): Text
    begin
        case DiscountType of
            DiscountType::Campaign:
                exit('Campaign');
            DiscountType::Mix:
                exit('Mix');
            DiscountType::Quantity:
                exit('Quantity');
            DiscountType::Manual:
                exit('Manual');
            DiscountType::"BOM List":
                exit('BOM List');
            DiscountType::Rounding:
                exit('Rounding');
            DiscountType::Combination:
                exit('Combination');
            DiscountType::Customer:
                exit('Customer');
        end;
    end;
    #endregion
}
#endif
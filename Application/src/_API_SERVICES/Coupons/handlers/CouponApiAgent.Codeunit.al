#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248530 "NPR CouponApiAgent"
{
    Access = Internal;

    #region API functions
    internal procedure CreateCoupon(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        RequestJson: JsonObject;
        Json: Codeunit "NPR JSON Builder";
    begin
        RequestJson := Request.BodyJson().AsObject();
        if not VerifyCreateRequest(RequestJson, Response) then
            exit(Response);

        CreateCoupon(RequestJson.AsToken(), Json);
        exit(Response.RespondOK(Json));
    end;

    internal procedure GetCoupon(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NPRNpDcCoupon: Record "NPR NpDc Coupon";
        Json: Codeunit "NPR Json Builder";
        CouponId: Text;
    begin
        CouponId := Request.Paths().Get(2);
        if CouponId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: couponId'));

        if not NPRNpDcCoupon.GetBySystemId(CouponId) then
            exit(Response.RespondBadRequest('Coupon not found'));

        Json.StartObject('');
        CoupontoJson(NPRNpDcCoupon, 'coupon', Json);
        Json.EndObject();

        exit(Response.RespondOK(Json));
    end;

    internal procedure DeleteCoupon(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NPRNpDcCoupon: Record "NPR NpDc Coupon";
        RequestJson: JsonObject;
        TempJToken: JsonToken;
        CouponId: Text;
        ReasonText: Text;
    begin
        CouponId := Request.Paths().Get(2);
        if CouponId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: couponId'));

        if not NPRNpDcCoupon.GetBySystemId(CouponId) then
            exit(Response.RespondBadRequest('Coupon not found'));

        RequestJson := Request.BodyJson().AsObject();

        if not RequestJson.SelectToken('reason', TempJToken) then
            exit(Response.RespondBadRequest('Missing required element: reason'));

        ReasonText := TempJToken.AsValue().AsText();
        if ReasonText = '' then
            exit(Response.RespondBadRequest('Reason must be included in the request.'));

        NPRNpDcCoupon.Delete(true);
        exit(Response.RespondOK('deleted'));
    end;

    local procedure VerifyCreateRequest(RequestJson: JsonObject; var Response: Codeunit "NPR API Response"): Boolean
    var
        TempText: Text;
    begin
        if not VerifyRequiredField(RequestJson, 'couponType', TempText, Response) then
            exit(false);

        exit(true);
    end;

    local procedure VerifyRequiredField(RequestJson: JsonObject; FieldName: Text; VariantDataType: Variant; var Response: Codeunit "NPR API Response"): Boolean
    var
        TempJToken: JsonToken;
    begin
        if not RequestJson.SelectToken(FieldName, TempJToken) then begin
            Response.RespondBadRequest(StrSubstNo('''%1'' must be included in the request.', FieldName));
            exit(false);
        end;

        if (TempJToken.AsValue().IsNull()) or (TempJToken.AsValue().IsUndefined) then begin
            Response.RespondBadRequest(StrSubstNo('''%1'' cannot be null.', FieldName));
            exit(false);
        end;

        if (not TryValueAsVariant(TempJToken.AsValue(), VariantDataType)) then begin
            Response.RespondBadRequest(StrSubstNo('''%1'' value is not in the correct format.', FieldName));
            exit(false);
        end;

        exit(true);
    end;

    [TryFunction]
    local procedure TryValueAsVariant(Value: JsonValue; var Variant: Variant)
    begin
        case true of
            Variant.IsText():
                Variant := Value.AsText();
            Variant.IsDecimal():
                Variant := Value.AsDecimal();
            Variant.IsInteger():
                Variant := Value.AsInteger();
        end;
    end;

    local procedure CreateCoupon(RequestJson: JsonToken; var Json: Codeunit "NPR JSON Builder")
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        JsonHelper: Codeunit "NPR Json Helper";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        CustomerNo: Code[20];
    begin
        Coupon.Init();
        Coupon.Validate("Coupon Type", CopyStr(JsonHelper.GetJCode(RequestJson, 'couponType', true), 1, MaxStrLen(Coupon."Coupon Type")));
        Coupon."No." := '';
        CustomerNo := CopyStr(JsonHelper.GetJCode(RequestJson, 'customerNo', true), 1, MaxStrLen(Coupon."Customer No."));
        if CustomerNo <> '' then
            Coupon.Validate("Customer No.", CustomerNo);
        Coupon.Insert(true);
        CouponType.Get(Coupon."Coupon Type");
        CouponType.TestField(Enabled, true);

        CouponMgt.PostIssueCoupon(Coupon);
        CoupontoJson(Coupon, 'coupon', Json);
    end;

    local procedure CoupontoJson(Coupon: Record "NPR NpDc Coupon"; JsonObjectName: Text; var Json: Codeunit "NPR Json Builder")
    begin
        Coupon.CalcFields(Open);
        Json.StartObject(JsonObjectName)
            .AddProperty('id', Format(Coupon.SystemId, 0, 4).ToLower())
            .AddProperty('no', Coupon."No.")
            .AddProperty('coupontype', Format(Coupon."Coupon Type"))
            .AddProperty('description', Coupon.Description)
            .AddProperty('referenceNo', Coupon."Reference No.");
        if Coupon.Open then
            Json.AddProperty('status', 'ACTIVE')
        else
            Json.AddProperty('status', 'CONSUMED');
        if Coupon."Discount Type" = Coupon."Discount Type"::"Discount %" then
            Json.AddProperty('discountType', 'PERCENTAGE')
        else
            Json.AddProperty('discountType', 'AMOUNT');
        Json.AddProperty('validFrom', Coupon."Starting Date");
        Json.AddProperty('maxUsesPerSale', Coupon."Max Use per Sale");
        Json.AddProperty('issueDate', Coupon."Issue Date");
        if Coupon."Discount Type" = Coupon."Discount Type"::"Discount %" then
            Json.AddProperty('discountPercent', Coupon."Discount %")
        else
            Json.AddProperty('discountAmount', Coupon."Discount Amount");
        Json.AddProperty('maxDiscountAmount', Coupon."Max. Discount Amount");
        Json.AddProperty('validUntil', Coupon."Ending Date");
        Json.AddProperty('customerNo', Coupon."Customer No.");
        Json.AddProperty('remainingQuantity', Coupon."Remaining Quantity");
        Json.EndObject();
    end;

    #endregion
}
#endif
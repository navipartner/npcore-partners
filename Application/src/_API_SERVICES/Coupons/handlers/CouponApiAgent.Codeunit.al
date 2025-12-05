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

    internal procedure ApplyCouponDiscount(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TempPOSSaleLine: Record "NPR POS Sale Line" temporary;
        TempSalePOS: Record "NPR POS Sale" temporary;
        TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary;
        Json: Codeunit "NPR JSON Builder";
        JsonHelper: Codeunit "NPR Json Helper";
        NpDcNonPOSApplicationMgt: Codeunit "NPR NpDc Non-POS App. Mgt.";
        DocumentNo: Text;
        RequestJson: JsonObject;
        RequestBody: JsonToken;
    begin
        RequestJson := Request.BodyJson().AsObject();
        if not VerifyDocumentNoRequest(RequestJson, Response) then
            exit(Response);

        RequestBody := Request.BodyJson();
        DocumentNo := JsonHelper.GetJText(RequestBody, 'documentNo', true);

        ParseSaleLinesFromRequest(TempPOSSaleLine, RequestBody);
        ParseCouponsLinesFromRequest(DocumentNo, TempNpDcExtCouponBuffer, RequestBody);

        InsertTempPOSSale(TempSalePOS, DocumentNo);
        NpDcNonPOSApplicationMgt.ApplyDiscount(TempSalePOS, TempPOSSaleLine, TempNpDcExtCouponBuffer, NpDcNonPOSApplicationMgt);
        BuildApplyDiscountCouponResponse(DocumentNo, TempPOSSaleLine, Json);

        exit(Response.RespondOK(Json));
    end;

    internal procedure CheckCoupon(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        Json: Codeunit "NPR JSON Builder";
        CouponId: Text;
    begin
        CouponId := Request.Paths().Get(3);
        if CouponId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: couponId'));

        if (not FindCouponById(CouponId, NpDcCoupon, Response)) then
            exit(Response);

        BuildCheckCouponResponse(NpDcCoupon, Json);
        exit(Response.RespondOK(Json));
    end;

    internal procedure FindCoupons(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        if (Request.QueryParams().ContainsKey('customerNo')) then
            NpDcCoupon.SetFilter("Customer No.", '=%1', CopyStr(UpperCase(Request.QueryParams().Get('customerNo')), 1, MaxStrLen(NpDcCoupon."Customer No.")));

        if (Request.QueryParams().ContainsKey('referenceNo')) then
            NpDcCoupon.SetFilter("Reference No.", '=%1', CopyStr(Request.QueryParams().Get('referenceNo'), 1, MaxStrLen(NpDcCoupon."Reference No.")));

        ResponseJson.StartObject('');
        ResponseJson.StartArray('coupons');
        if NpDcCoupon.FindSet() then begin
            repeat
                CoupontoJson(NpDcCoupon, 'coupon', ResponseJson);
            until NpDcCoupon.Next() = 0;
        end;
        ResponseJson.EndArray().EndObject();
        exit(Response.RespondOK(ResponseJson));
    end;

    internal procedure ReserveCoupon(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        Json: Codeunit "NPR JSON Builder";
        RequestJson: JsonObject;
        CouponId: Text;
    begin
        CouponId := Request.Paths().Get(2);
        if CouponId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: couponId'));

        RequestJson := Request.BodyJson().AsObject();
        if not VerifyDocumentNoRequest(RequestJson, Response) then
            exit(Response);

        if (not FindCouponById(CouponId, NpDcCoupon, Response)) then
            exit(Response);

        ReserveCoupon(NpDcCoupon, RequestJson.AsToken(), Json);

        exit(Response.RespondOK(Json));
    end;

    internal procedure CancelCouponReservation(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        Json: Codeunit "NPR JSON Builder";
        CouponId: Text;
        DocumentNo: Text;
    begin
        DocumentNo := Request.Paths().Get(3);
        if DocumentNo = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: documentNo'));

        CouponId := Request.Paths().Get(4);
        if CouponId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: couponId'));

        if (not NpDcCoupon.GetBySystemId(CouponId)) then
            exit(Response.RespondBadRequest('Coupon Id not found'));

        if NpDcCoupon."Reference No." = '' then
            exit(Response.RespondBadRequest('Invalid coupon reference number'));

        RemoveCouponReservation(NpDcCoupon, DocumentNo, Json);

        exit(Response.RespondOK(Json));
    end;

    internal procedure ReserveCoupon(NpDcCoupon: Record "NPR NpDc Coupon"; RequestJToken: JsonToken; var Json: Codeunit "NPR JSON Builder")
    var
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
        TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary;
        NpDcNonPOSAppMgt: Codeunit "NPR NpDc Non-POS App. Mgt.";
        JsonHelper: Codeunit "NPR Json Helper";
        DocumentNo: Text;
        LineNo: Integer;
    begin
        DocumentNo := JsonHelper.GetJText(RequestJToken, 'documentNo', true);

        RemoveReservationForCoupon(NpDcExtCouponSalesLine, NpDcCoupon."Reference No.", DocumentNo);

        NpDcExtCouponSalesLine.Reset();
        NpDcExtCouponSalesLine.SetRange("External Document No.", DocumentNo);
        if NpDcExtCouponSalesLine.FindLast() then;
        LineNo := NpDcExtCouponSalesLine."Line No." + 10000;
        NpDcExtCouponSalesLine.Init();
        NpDcExtCouponSalesLine."External Document No." := CopyStr(DocumentNo, 1, MaxStrLen(NpDcExtCouponSalesLine."External Document No."));
        NpDcExtCouponSalesLine."Line No." := LineNo;
        NpDcExtCouponSalesLine."Coupon No." := NpDcCoupon."No.";
        NpDcExtCouponSalesLine."Coupon Type" := NpDcCoupon."Coupon Type";
        NpDcExtCouponSalesLine.Description := NpDcCoupon.Description;
        NpDcExtCouponSalesLine."Reference No." := NpDcCoupon."Reference No.";
        NpDcExtCouponSalesLine.Insert();

        TempNpDcExtCouponBuffer.Init();
        TempNpDcExtCouponBuffer."Document No." := CopyStr(DocumentNo, 1, MaxStrLen(TempNpDcExtCouponBuffer."Document No."));
        NpDcNonPOSAppMgt.Coupon2Buffer(NpDcCoupon, TempNpDcExtCouponBuffer);
        TempNpDcExtCouponBuffer.Insert();

        BuildReserveResponse(TempNpDcExtCouponBuffer, Json);
    end;

    local procedure RemoveCouponReservation(NpDcCoupon: Record "NPR NpDc Coupon"; DocumentNo: Text; var Json: Codeunit "NPR JSON Builder")
    var
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
        TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary;
        NpDcNonPOSAppMgt: Codeunit "NPR NpDc Non-POS App. Mgt.";
    begin
        RemoveReservationForCoupon(NpDcExtCouponSalesLine, NpDcCoupon."Reference No.", DocumentNo);
        TempNpDcExtCouponBuffer.Init();
        TempNpDcExtCouponBuffer."Document No." := CopyStr(DocumentNo, 1, MaxStrLen(TempNpDcExtCouponBuffer."Document No."));
        NpDcNonPOSAppMgt.Coupon2Buffer(NpDcCoupon, TempNpDcExtCouponBuffer);
        TempNpDcExtCouponBuffer.Insert();
        BuildReserveResponse(TempNpDcExtCouponBuffer, Json);
    end;

    local procedure RemoveReservationForCoupon(var NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv."; ReferenceNo: Text; DocumentNo: Text)
    begin
        NpDcExtCouponSalesLine.SetRange("External Document No.", DocumentNo);
        NpDcExtCouponSalesLine.SetRange("Reference No.", ReferenceNo);
        if NpDcExtCouponSalesLine.FindFirst() then
            NpDcExtCouponSalesLine.Delete(true);
    end;

    local procedure BuildReserveResponse(TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary; var Json: Codeunit "NPR JSON Builder")
    begin
        Json.StartObject('');
        BuildReserveCouponAsJson(TempNpDcExtCouponBuffer, 'reservation', Json);
        Json.EndObject();
    end;

    local procedure ParseSaleLinesFromRequest(var TempPOSSaleLine: Record "NPR POS Sale Line" temporary; RequestBody: JsonToken)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        POSSalesLineJsonToken: JsonToken;
        POSSalesLinesJsonToken: JsonToken;
        POSSalesLinesNoArrayErr: Label 'The posSalesLines property is not an array.', Locked = true;
    begin
        POSSalesLinesJsonToken := JsonHelper.GetJsonToken(RequestBody, 'posSalesLines');

        if (not POSSalesLinesJsonToken.IsArray()) then
            Error(POSSalesLinesNoArrayErr);

        foreach POSSalesLineJsonToken in POSSalesLinesJsonToken.AsArray() do
            InsertPOSSalesLine(POSSalesLineJsonToken, TempPOSSaleLine);
    end;

    local procedure ParseCouponsLinesFromRequest(DocumentNo: Text; var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary; RequestBody: JsonToken)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        CouponJsonToken: JsonToken;
        CouponsJsonToken: JsonToken;
        LineNo: Integer;
        CouponsLinesNoArrayErr: Label 'The discountCoupons property is not an array.', Locked = true;
    begin
        CouponsJsonToken := JsonHelper.GetJsonToken(RequestBody, 'discountCoupons');

        if (not CouponsJsonToken.IsArray()) then
            Error(CouponsLinesNoArrayErr);

        foreach CouponJsonToken in CouponsJsonToken.AsArray() do
            InsertCouponLine(CouponJsonToken, TempNpDcExtCouponBuffer, DocumentNo, LineNo);
    end;

    local procedure InsertTempPOSSale(var TempSalePOS: Record "NPR POS Sale" temporary; DocumentNo: Text)
    begin
        TempSalePOS.Init();
        TempSalePOS."External Document No." := CopyStr(DocumentNo, 1, MaxStrLen(TempSalePOS."External Document No."));
        TempSalePOS.Insert();
    end;

    local procedure InsertPOSSalesLine(POSSalesLineJsonToken: JsonToken; var TempPOSSaleLine: Record "NPR POS Sale Line" temporary)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        TempPOSSaleLine.Reset();
        TempPOSSaleLine.Init();
        TempPOSSaleLine."Line Type" := TempPOSSaleLine."Line Type"::Item;
#pragma warning disable AA0139
        TempPOSSaleLine."Line No." := JsonHelper.GetJInteger(POSSalesLineJsonToken, 'lineNo', true);
        TempPOSSaleLine."No." := JsonHelper.GetJText(POSSalesLineJsonToken, 'itemNo', MaxStrLen(TempPOSSaleLine."No."), true, true);
        TempPOSSaleLine."Variant Code" := JsonHelper.GetJText(POSSalesLineJsonToken, 'variantCode', MaxStrLen(TempPOSSaleLine."Variant Code"), true, false);
        TempPOSSaleLine.Description := JsonHelper.GetJText(POSSalesLineJsonToken, 'description', MaxStrLen(TempPOSSaleLine.Description), true, false);
        TempPOSSaleLine."Description 2" := JsonHelper.GetJText(POSSalesLineJsonToken, 'description2', MaxStrLen(TempPOSSaleLine."Description 2"), true, false);
        TempPOSSaleLine."Unit Price" := JsonHelper.GetJDecimal(POSSalesLineJsonToken, 'unitPriceInclVat', true);
        TempPOSSaleLine.Quantity := JsonHelper.GetJDecimal(POSSalesLineJsonToken, 'quantity', true);
        TempPOSSaleLine."Unit of Measure Code" := JsonHelper.GetJText(POSSalesLineJsonToken, 'unitOfMeasure', MaxStrLen(TempPOSSaleLine."Unit of Measure Code"), true, false);
        TempPOSSaleLine."Discount %" := JsonHelper.GetJDecimal(POSSalesLineJsonToken, 'discountPct', false);
        TempPOSSaleLine."Discount Amount" := JsonHelper.GetJDecimal(POSSalesLineJsonToken, 'discountAmount', false);
        TempPOSSaleLine."VAT %" := JsonHelper.GetJDecimal(POSSalesLineJsonToken, 'vatPercent', true);
        TempPOSSaleLine."Amount Including VAT" := JsonHelper.GetJDecimal(POSSalesLineJsonToken, 'lineAmountInclVat', true);
        TempPOSSaleLine."Magento Brand" := JsonHelper.GetJText(POSSalesLineJsonToken, 'magentoBrand', MaxStrLen(TempPOSSaleLine."Magento Brand"), true, false);
#pragma warning restore AA0139

        if TempPOSSaleLine.Description = '' then
            if Item.Get(TempPOSSaleLine."No.") then
                TempPOSSaleLine.Description := Item.Description;

        if TempPOSSaleLine."Magento Brand" = '' then
            if Item.Get(TempPOSSaleLine."No.") then
                TempPOSSaleLine."Magento Brand" := Item."NPR Magento Brand";

        if (TempPOSSaleLine."Description 2" = '') and (TempPOSSaleLine."Variant Code" <> '') then
            if ItemVariant.Get(TempPOSSaleLine."No.", TempPOSSaleLine."Variant Code") then
                TempPOSSaleLine."Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen(TempPOSSaleLine."Description 2"));

        TempPOSSaleLine.Insert();
    end;

    local procedure InsertCouponLine(CouponJsonToken: JsonToken; var TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary; DocumentNo: Text; var LineNo: Integer)
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        TempNpDcExtCouponBuffer.Reset();
        TempNpDcExtCouponBuffer.Init();
        TempNpDcExtCouponBuffer."Document No." := CopyStr(DocumentNo, 1, MaxStrLen(TempNpDcExtCouponBuffer."Document No."));
        LineNo += 10000;
        TempNpDcExtCouponBuffer."Line No." := LineNo;
#pragma warning disable AA0139
        TempNpDcExtCouponBuffer."Reference No." := JsonHelper.GetJText(CouponJsonToken, 'referenceNo', MaxStrLen(TempNpDcExtCouponBuffer."Reference No."), true, true);
#pragma warning restore AA0139
        TempNpDcExtCouponBuffer.Insert();
    end;

    local procedure BuildApplyDiscountCouponResponse(DocumentNo: Text; var TempPOSSaleLine: Record "NPR POS Sale Line" temporary; var Json: Codeunit "NPR JSON Builder")
    begin
        Json.StartObject('');
        Json.AddProperty('documentNo', DocumentNo);
        Json.StartArray('posSalesLines');
        TempPOSSaleLine.Reset();
        if TempPOSSaleLine.FindSet() then
            repeat
                Json.StartObject('');
                Json.AddProperty('lineNo', TempPOSSaleLine."Line No.");
                Json.AddProperty('itemNo', TempPOSSaleLine."No.");
                Json.AddProperty('variantCode', TempPOSSaleLine."Variant Code");
                Json.AddProperty('description', TempPOSSaleLine.Description);
                Json.AddProperty('description2', TempPOSSaleLine."Description 2");
                Json.AddProperty('unitPriceInclVat', TempPOSSaleLine."Unit Price");
                Json.AddProperty('quantity', TempPOSSaleLine.Quantity);
                Json.AddProperty('unitOfMeasure', TempPOSSaleLine."Unit of Measure Code");
                Json.AddProperty('discountPct', TempPOSSaleLine."Discount %");
                Json.AddProperty('discountAmount', TempPOSSaleLine."Discount Amount");
                Json.AddProperty('vatPercent', TempPOSSaleLine."VAT %");
                Json.AddProperty('lineAmountInclVat', TempPOSSaleLine."Amount Including VAT");
                Json.AddProperty('magentoBrand', TempPOSSaleLine."Magento Brand");
                Json.EndObject();
            until TempPOSSaleLine.Next() = 0;
        Json.EndArray();
        Json.EndObject();
    end;

    local procedure BuildCheckCouponResponse(NpDcCoupon: Record "NPR NpDc Coupon"; var Json: Codeunit "NPR JSON Builder")
    begin
        NpDcCoupon.CalcFields(Open, "Remaining Quantity");
        Json.StartObject('');
        Json.AddProperty('couponId', Format(NpDcCoupon.SystemId, 0, 4).ToLower());
        Json.AddProperty('documentNo', NpDcCoupon."Issue External Document No.");
        Json.AddProperty('referenceNo', NpDcCoupon."Reference No.");
        Json.AddProperty('couponType', NpDcCoupon."Coupon Type");
        Json.AddProperty('description', NpDcCoupon.Description);
        Json.AddProperty('startingDate', NpDcCoupon."Starting Date");
        Json.AddProperty('endingDate', NpDcCoupon."Ending Date");
        Json.AddProperty('open', NpDcCoupon.Open);
        Json.AddProperty('maxUsePerSale', NpDcCoupon."Max Use per Sale");
        Json.AddProperty('remainingQuantity', NpDcCoupon."Remaining Quantity");
        Json.AddProperty('inUseQuantity', NpDcCoupon.CalcInUseQty());
        Json.EndObject();
    end;

    local procedure BuildReserveCouponAsJson(TempNpDcExtCouponBuffer: Record "NPR NpDc Ext. Coupon Buffer" temporary; JsonObjectName: Text; var Json: Codeunit "NPR Json Builder")
    begin
        Json.StartObject(JsonObjectName)
            .AddProperty('referenceNo', TempNpDcExtCouponBuffer."Reference No.")
            .AddProperty('documentNo', TempNpDcExtCouponBuffer."Document No.")
            .AddProperty('couponType', TempNpDcExtCouponBuffer."Coupon Type")
            .AddProperty('description', TempNpDcExtCouponBuffer.Description)
            .AddProperty('startingDate', TempNpDcExtCouponBuffer."Starting Date")
            .AddProperty('endingDate', TempNpDcExtCouponBuffer."Ending Date")
            .AddProperty('open', TempNpDcExtCouponBuffer.Open)
            .AddProperty('remainingQuantity', TempNpDcExtCouponBuffer."Remaining Quantity")
            .AddProperty('inUseQuantity', TempNpDcExtCouponBuffer."In-use Quantity");
    end;

    local procedure FindCouponById(CouponId: Text; var NpDcCoupon: Record "NPR NpDc Coupon"; var Response: Codeunit "NPR API Response"): Boolean
    begin
        if not NpDcCoupon.GetBySystemId(CouponId) then begin
            if not FindAndValidateArchiveCoupon(CouponId, Response) then
                exit(false);
        end else begin
            if not ValidateActiveCoupon(NpDcCoupon, Response) then
                exit(false);
        end;
        exit(true);
    end;

    internal procedure FindAndValidateArchiveCoupon(CouponId: Text; var Response: Codeunit "NPR API Response"): Boolean
    var
        NpDcArchCoupon: Record "NPR NpDc Arch. Coupon";
    begin
        if not NpDcArchCoupon.GetBySystemId(CouponId) then begin
            Response.RespondBadRequest('Not found, Invalid Reference number');
            exit(false);
        end;

        if (NpDcArchCoupon."Ending Date" < NpDcArchCoupon.SystemCreatedAt) and (NpDcArchCoupon."Ending Date" <> 0DT) then
            Response.RespondBadRequest('Coupon is expired and archived')
        else
            Response.RespondBadRequest('Coupon is archived');
        exit(false);
    end;

    internal procedure ValidateActiveCoupon(NpDcCoupon: Record "NPR NpDc Coupon"; var Response: Codeunit "NPR API Response"): Boolean
    var
        NpDcExtCouponSalesLine: Record "NPR NpDc Ext. Coupon Reserv.";
        NpDcCouponType: Record "NPR NpDc Coupon Type";
        CurrSaleCouponCount: Integer;
    begin
        NpDcCoupon.CalcFields(Open, "Remaining Quantity");

        if NpDcCouponType.Get(NpDcCoupon."Coupon Type") and (not NpDcCouponType.Enabled) then begin
            Response.RespondBadRequest('Coupon type is not enabled');
            exit(false);
        end;

        if NpDcCoupon."Starting Date" > CurrentDateTime then begin
            Response.RespondBadRequest('Coupon is not valid yet');
            exit(false);
        end;

        if (NpDcCoupon."Ending Date" < CurrentDateTime) and (NpDcCoupon."Ending Date" <> 0DT) then begin
            Response.RespondBadRequest('Coupon is expired');
            exit(false);
        end;

        if not NpDcCoupon.Open then begin
            Response.RespondBadRequest('Coupon is not open');
            exit(false);
        end;

        if NpDcCoupon."Remaining Quantity" < 1 then begin
            Response.RespondBadRequest('Coupon has no remaining quantity');
            exit(false);
        end;

        if NpDcCoupon.CalcInUseQty() >= NpDcCoupon."Remaining Quantity" then begin
            Response.RespondBadRequest('Coupon is being used');
            exit(false);
        end;

        NpDcExtCouponSalesLine.SetRange("Coupon No.", NpDcCoupon."No.");
        CurrSaleCouponCount := NpDcExtCouponSalesLine.Count();
        if NpDcCoupon."Max Use per Sale" < 1 then
            NpDcCoupon."Max Use per Sale" := 1;
        if CurrSaleCouponCount >= NpDcCoupon."Max Use per Sale" then begin
            Response.RespondBadRequest(StrSubstNo('Coupon max use per sale exceeded. Max use per sale is %1', NpDcCoupon."Max Use per Sale"));
            exit(false);
        end;

        exit(true);
    end;

    local procedure VerifyDocumentNoRequest(RequestJson: JsonObject; var Response: Codeunit "NPR API Response"): Boolean
    var
        TempText: Text;
    begin
        if not VerifyRequiredField(RequestJson, 'documentNo', TempText, Response) then
            exit(false);
        exit(true);
    end;

    local procedure CoupontoJson(Coupon: Record "NPR NpDc Coupon"; JsonObjectName: Text; var Json: Codeunit "NPR Json Builder")
    begin
        Coupon.CalcFields(Open, "Remaining Quantity");
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
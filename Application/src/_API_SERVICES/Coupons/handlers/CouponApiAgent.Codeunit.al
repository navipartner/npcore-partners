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

        CreateCoupon(Request.ApiVersion(), RequestJson.AsToken(), Json);
        exit(Response.RespondCreated(Json));
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

        if not GetActiveCoupon(CouponId, NPRNpDcCoupon, Response) then
            exit(Response);

        Json.StartObject('');
        CouponToJson(Request.ApiVersion(), NPRNpDcCoupon, 'coupon', Json);
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

        if not GetActiveCoupon(CouponId, NPRNpDcCoupon, Response) then
            exit(Response);

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

    local procedure CreateCoupon(VersionDate: Date; RequestJson: JsonToken; var Json: Codeunit "NPR JSON Builder")
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
        CouponToJson(VersionDate, Coupon, 'coupon', Json);
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
        State: Enum "NPR NpDc CouponState";
        CouponId: Text;
    begin
        CouponId := Request.Paths().Get(3);
        if (CouponId = '') then
            exit(Response.RespondBadRequest('Missing required path parameter: couponId'));

        if (not GetActiveCoupon(CouponId, NpDcCoupon, Response)) then
            exit(Response);

        State := InspectCoupon(NpDcCoupon, '');
        BuildCheckCouponResponse(NpDcCoupon, State, Json);
        exit(Response.RespondOK(Json));
    end;

    internal procedure FindCoupons(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        NpDcArchCoupon: Record "NPR NpDc Arch. Coupon";
        ResponseJson: Codeunit "NPR JSON Builder";
        CustomerNo: Text;
        ReferenceNo: Text;
        HasFilters: Boolean;
        IncludeArchived: Boolean;
    begin
        if (Request.QueryParams().ContainsKey('customerNo')) then begin
            CustomerNo := Request.QueryParams().Get('customerNo').Trim();
            if CustomerNo = '' then
                exit(Response.RespondBadRequest('''customerNo'' cannot be blank'));
            NpDcCoupon.SetFilter("Customer No.", '=%1', CopyStr(UpperCase(CustomerNo), 1, MaxStrLen(NpDcCoupon."Customer No.")));
            NpDcArchCoupon.SetFilter("Customer No.", '=%1', CopyStr(UpperCase(CustomerNo), 1, MaxStrLen(NpDcArchCoupon."Customer No.")));
            HasFilters := true;
        end;

        if (Request.QueryParams().ContainsKey('referenceNo')) then begin
            ReferenceNo := Request.QueryParams().Get('referenceNo').Trim();
            if ReferenceNo = '' then
                exit(Response.RespondBadRequest('''referenceNo'' cannot be blank'));
            NpDcCoupon.SetFilter("Reference No.", '=%1', UpperCase(CopyStr(ReferenceNo, 1, MaxStrLen(NpDcCoupon."Reference No."))));
            NpDcArchCoupon.SetFilter("Reference No.", '=%1', UpperCase(CopyStr(ReferenceNo, 1, MaxStrLen(NpDcArchCoupon."Reference No."))));
            HasFilters := true;
        end;

        if not HasFilters then
            exit(Response.RespondBadRequest('At least one filter must be provided.'));

        if (Request.QueryParams().ContainsKey('includeArchived')) then
            IncludeArchived := UpperCase(Request.QueryParams().Get('includeArchived').Trim()) = 'TRUE';

        ResponseJson.StartObject('');
        ResponseJson.StartArray('coupons');
        if NpDcCoupon.FindSet() then
            repeat
                CouponToJson(Request.ApiVersion(), NpDcCoupon, 'coupon', ResponseJson);
            until NpDcCoupon.Next() = 0;

        if IncludeArchived and NpDcArchCoupon.FindSet() then
            repeat
                ArchivedCouponToJson(Request.ApiVersion(), NpDcArchCoupon, 'coupon', ResponseJson);
            until NpDcArchCoupon.Next() = 0;

        ResponseJson.EndArray().EndObject();
        exit(Response.RespondOK(ResponseJson));
    end;

    internal procedure ReserveCoupon(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NpDcCoupon: Record "NPR NpDc Coupon";
        Json: Codeunit "NPR JSON Builder";
        JsonHelper: Codeunit "NPR Json Helper";
        RequestJson: JsonObject;
        RequestBody: JsonToken;
        CouponId: Text;
        DocumentNo: Text;
    begin
        CouponId := Request.Paths().Get(2);
        if (CouponId = '') then
            exit(Response.RespondBadRequest('Missing required path parameter: couponId'));

        RequestJson := Request.BodyJson().AsObject();
        if (not VerifyDocumentNoRequest(RequestJson, Response)) then
            exit(Response);

        if (not GetActiveCoupon(CouponId, NpDcCoupon, Response)) then
            exit(Response);

        RequestBody := Request.BodyJson();
        DocumentNo := JsonHelper.GetJText(RequestBody, 'documentNo', true);

        if (not IsCouponActive(NpDcCoupon, DocumentNo, Response)) then
            exit(Response);

        ReserveCoupon(NpDcCoupon, RequestJson.AsToken(), Json);

        exit(Response.RespondOK(Json));
    end;

    internal procedure RedeemCoupon(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Coupon: Record "NPR NpDc Coupon";
        ArchivedCoupon: Record "NPR NpDc Arch. Coupon";
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        JsonHelper: Codeunit "NPR Json Helper";
        Json: Codeunit "NPR JSON Builder";
        RequestJson: JsonObject;
        RequestBody: JsonToken;
        ReferenceNo: Text;
        DocumentNo: Text;
    begin
        RequestJson := Request.BodyJson().AsObject();
        if not VerifyRedeemRequest(RequestJson, Response) then
            exit(Response);

        RequestBody := Request.BodyJson();
        ReferenceNo := JsonHelper.GetJText(RequestBody, 'referenceNo', true).Trim();
        DocumentNo := JsonHelper.GetJText(RequestBody, 'documentNo', true).Trim();

        if (StrLen(ReferenceNo) > MaxStrLen(Coupon."Reference No.")) then
            exit(Response.RespondBadRequest(StrSubstNo('''referenceNo'' exceeds the maximum length of %1.', MaxStrLen(Coupon."Reference No."))));

        if (StrLen(ReferenceNo) = 0) then
            exit(Response.RespondBadRequest('''referenceNo'' cannot be blank'));

        if (StrLen(DocumentNo) > MaxStrLen(Coupon."Issue External Document No.")) then
            exit(Response.RespondBadRequest(StrSubstNo('''documentNo'' exceeds the maximum length of %1.', MaxStrLen(Coupon."Issue External Document No."))));

        if (StrLen(DocumentNo) = 0) then
            exit(Response.RespondBadRequest('''documentNo'' cannot be blank'));

        Coupon.SetCurrentKey("Reference No.");
        Coupon.SetFilter("Reference No.", '=%1', UpperCase(ReferenceNo));
        if (not Coupon.FindFirst()) then begin
            ArchivedCoupon.SetCurrentKey("Reference No.");
            ArchivedCoupon.SetFilter("Reference No.", '=%1', UpperCase(ReferenceNo));
            if (not ArchivedCoupon.IsEmpty()) then
                exit(Response.RespondBadRequest('Coupon is archived'));
            exit(Response.RespondBadRequest('Coupon not found'));
        end;

        if (not IsCouponActive(Coupon, DocumentNo, Response)) then
            exit(Response);

        CouponMgt.RedeemCoupon(Coupon, CopyStr(DocumentNo, 1, MaxStrLen(Coupon."Issue External Document No.")));

        BuildRedeemResponse(Coupon, DocumentNo, Json);
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

        if not GetActiveCoupon(CouponId, NpDcCoupon, Response) then
            exit(Response);

        if NpDcCoupon."Reference No." = '' then
            exit(Response.RespondBadRequest('Invalid coupon reference number'));

        // Cancel is idempotent: no-op silently when nothing matches. Callers reconcile via CheckCoupon.
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
        NpDcExtCouponSalesLine.SetFilter("External Document No.", '=%1', DocumentNo);
        NpDcExtCouponSalesLine.SetFilter("Reference No.", '=%1', ReferenceNo);
        NpDcExtCouponSalesLine.DeleteAll(true);
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

    local procedure BuildCheckCouponResponse(NpDcCoupon: Record "NPR NpDc Coupon"; State: Enum "NPR NpDc CouponState"; var Json: Codeunit "NPR JSON Builder")
    var
        NpDcExtCouponReservation: Record "NPR NpDc Ext. Coupon Reserv.";
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
        Json.AddProperty('state', StateToString(State));

        Json.StartArray('reservedByDocumentNos');
        NpDcExtCouponReservation.SetFilter("Coupon No.", '=%1', NpDcCoupon."No.");
        if NpDcExtCouponReservation.FindSet() then
            repeat
                Json.AddValue(NpDcExtCouponReservation."External Document No.");
            until NpDcExtCouponReservation.Next() = 0;
        Json.EndArray();

        Json.EndObject();
    end;

    local procedure StateToString(State: Enum "NPR NpDc CouponState"): Text
    begin
        case State of
            State::ACTIVE:
                exit('active');
            State::NOT_YET_VALID:
                exit('notYetValid');
            State::EXPIRED:
                exit('expired');
            State::CONSUMED:
                exit('consumed');
            State::EXHAUSTED:
                exit('exhausted');
            State::RESERVED:
                exit('reserved');
            State::MAX_PER_SALE_EXCEEDED:
                exit('maxPerSaleExceeded');
            State::TYPE_DISABLED:
                exit('typeDisabled');
        end;
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

    local procedure GetActiveCoupon(CouponId: Text; var Coupon: Record "NPR NpDc Coupon"; var Response: Codeunit "NPR API Response"): Boolean
    var
        ArchivedCoupon: Record "NPR NpDc Arch. Coupon";
    begin
        if (Coupon.GetBySystemId(CouponId)) then
            exit(true);

        if (ArchivedCoupon.GetBySystemId(CouponId)) then begin
            if (ArchivedCoupon."Ending Date" < ArchivedCoupon.SystemCreatedAt) and (ArchivedCoupon."Ending Date" <> 0DT) then
                Response.RespondBadRequest('Coupon is expired and archived')
            else
                Response.RespondBadRequest('Coupon is archived');
            exit(false);
        end;

        Response.RespondBadRequest('Coupon not found');
        exit(false);
    end;

    internal procedure InspectCoupon(Coupon: Record "NPR NpDc Coupon"; DocumentNo: Text) State: Enum "NPR NpDc CouponState"
    var
        CouponType: Record "NPR NpDc Coupon Type";
        ExtCouponReservation: Record "NPR NpDc Ext. Coupon Reserv.";
        CouponEntry: Record "NPR NpDc Coupon Entry";
        EffectiveInUseQty: Integer;
        OwnReservationCount: Integer;
    begin
        Coupon.CalcFields(Open, "Remaining Quantity");

        if (CouponType.Get(Coupon."Coupon Type") and (not CouponType.Enabled)) then
            exit(State::TYPE_DISABLED);

        if (Coupon."Starting Date" > CurrentDateTime()) then
            exit(State::NOT_YET_VALID);

        if ((Coupon."Ending Date" < CurrentDateTime()) and (Coupon."Ending Date" <> 0DT)) then
            exit(State::EXPIRED);

        if (not Coupon.Open) then
            exit(State::CONSUMED);

        if (Coupon."Remaining Quantity" < 1) then
            exit(State::EXHAUSTED);

        // Subtract caller's own reservations so they don't conflict with themselves on retry.
        EffectiveInUseQty := Coupon.CalcInUseQty();
        if (DocumentNo <> '') then begin
            ExtCouponReservation.SetFilter("Coupon No.", '=%1', Coupon."No.");
            ExtCouponReservation.SetFilter("External Document No.", '=%1', DocumentNo);
            OwnReservationCount := ExtCouponReservation.Count();
            EffectiveInUseQty -= OwnReservationCount;
        end;
        if (EffectiveInUseQty >= Coupon."Remaining Quantity") then
            exit(State::RESERVED);

        // MaxUsePerSale: count prior redemptions from this sale against the coupon's limit.
        if (DocumentNo <> '') then begin
            CouponEntry.SetFilter("Coupon No.", '=%1', Coupon."No.");
            CouponEntry.SetFilter("External Document No.", '=%1', DocumentNo);
            CouponEntry.SetFilter("Entry Type", '=%1', CouponEntry."Entry Type"::"Discount Application");
            if (CouponEntry.Count() >= EffectiveMaxUsePerSale(Coupon)) then
                exit(State::MAX_PER_SALE_EXCEEDED);
        end;

        exit(State::ACTIVE);
    end;

    local procedure EffectiveMaxUsePerSale(Coupon: Record "NPR NpDc Coupon"): Integer
    begin
        if (Coupon."Max Use per Sale" < 1) then
            exit(1);
        exit(Coupon."Max Use per Sale");
    end;

    local procedure IsCouponActive(Coupon: Record "NPR NpDc Coupon"; DocumentNo: Text; var Response: Codeunit "NPR API Response"): Boolean
    var
        State: Enum "NPR NpDc CouponState";
    begin
        State := InspectCoupon(Coupon, DocumentNo);
        case State of
            State::ACTIVE:
                exit(true);
            State::TYPE_DISABLED:
                Response.RespondBadRequest('Coupon type is not enabled');
            State::CONSUMED:
                Response.RespondBadRequest('Coupon is not open');
            State::NOT_YET_VALID:
                Response.RespondBadRequest('Coupon is not valid yet');
            State::EXPIRED:
                Response.RespondBadRequest('Coupon is expired');
            State::EXHAUSTED:
                Response.RespondBadRequest('Coupon has no remaining quantity');
            State::RESERVED:
                Response.RespondBadRequest('Coupon is already reserved by a different document number');
            State::MAX_PER_SALE_EXCEEDED:
                Response.RespondBadRequest(StrSubstNo('Coupon max use per sale exceeded. Max use per sale is %1', EffectiveMaxUsePerSale(Coupon)));
        end;
        exit(false);
    end;

    local procedure VerifyDocumentNoRequest(RequestJson: JsonObject; var Response: Codeunit "NPR API Response"): Boolean
    var
        TempText: Text;
    begin
        if not VerifyRequiredField(RequestJson, 'documentNo', TempText, Response) then
            exit(false);
        exit(true);
    end;

    local procedure VerifyRedeemRequest(RequestJson: JsonObject; var Response: Codeunit "NPR API Response"): Boolean
    var
        TempText: Text;
    begin
        if not VerifyRequiredField(RequestJson, 'referenceNo', TempText, Response) then
            exit(false);

        if not VerifyRequiredField(RequestJson, 'documentNo', TempText, Response) then
            exit(false);

        exit(true);
    end;

    local procedure BuildRedeemResponse(NpDcCoupon: Record "NPR NpDc Coupon"; DocumentNo: Text; var Json: Codeunit "NPR JSON Builder")
    begin
        Json.StartObject('')
            .StartObject('redemption')
            .AddProperty('couponId', Format(NpDcCoupon.SystemId, 0, 4).ToLower())
            .AddProperty('referenceNo', NpDcCoupon."Reference No.")
            .AddProperty('documentNo', DocumentNo)
            .AddProperty('couponType', NpDcCoupon."Coupon Type");

        Json.EndObject().EndObject();
    end;

    local procedure CouponToJson(VersionDate: Date; Coupon: Record "NPR NpDc Coupon"; JsonObjectName: Text; var Json: Codeunit "NPR Json Builder")
    begin
        Coupon.CalcFields(Open, "Remaining Quantity", "Issue Date");
        Json.StartObject(JsonObjectName)
            .AddProperty('id', Format(Coupon.SystemId, 0, 4).ToLower())
            .AddProperty('no', Coupon."No.")
            .AddProperty('description', Coupon.Description)
            .AddProperty('referenceNo', Coupon."Reference No.");

        if (VersionDate <= DMY2DATE(30, 4, 2026)) then
            Json.AddProperty('coupontype', Format(Coupon."Coupon Type"));

        Json.AddProperty('couponType', Format(Coupon."Coupon Type"));

        if Coupon.Open then
            Json.AddProperty('status', 'ACTIVE')
        else
            Json.AddProperty('status', 'CONSUMED');

        if Coupon."Discount Type" = Coupon."Discount Type"::"Discount %" then
            Json.AddProperty('discountType', 'PERCENTAGE')
        else
            Json.AddProperty('discountType', 'AMOUNT');

        Json.AddProperty('issueDate', Coupon."Issue Date");

        if (Coupon."Starting Date" > 0DT) then
            Json.AddProperty('validFrom', Coupon."Starting Date");

        if (Coupon."Ending Date" > 0DT) then
            Json.AddProperty('validUntil', Coupon."Ending Date");

        Json.AddProperty('maxUsesPerSale', Coupon."Max Use per Sale");

        if Coupon."Discount Type" = Coupon."Discount Type"::"Discount %" then
            Json.AddProperty('discountPercent', Coupon."Discount %")
        else
            Json.AddProperty('discountAmount', Coupon."Discount Amount");
        Json.AddProperty('maxDiscountAmount', Coupon."Max. Discount Amount");

        Json.AddProperty('customerNo', Coupon."Customer No.");
        Json.AddProperty('remainingQuantity', Coupon."Remaining Quantity");
        Json.EndObject();
    end;

    local procedure ArchivedCouponToJson(VersionDate: Date; Coupon: Record "NPR NpDc Arch. Coupon"; JsonObjectName: Text; var Json: Codeunit "NPR Json Builder")
    begin
        Coupon.CalcFields("Remaining Quantity", "Issue Date");
        Json.StartObject(JsonObjectName)
            .AddProperty('id', Format(Coupon.SystemId, 0, 4).ToLower())
            .AddProperty('no', Coupon."No.")
            .AddProperty('description', Coupon.Description)
            .AddProperty('referenceNo', Coupon."Reference No.");

        if (VersionDate <= DMY2DATE(30, 4, 2026)) then
            Json.AddProperty('coupontype', Format(Coupon."Coupon Type"));

        Json.AddProperty('couponType', Format(Coupon."Coupon Type"));
        Json.AddProperty('status', 'CONSUMED');

        if Coupon."Discount Type" = Coupon."Discount Type"::"Discount %" then
            Json.AddProperty('discountType', 'PERCENTAGE')
        else
            Json.AddProperty('discountType', 'AMOUNT');

        Json.AddProperty('issueDate', Coupon."Issue Date");

        if (Coupon."Starting Date" > 0DT) then
            Json.AddProperty('validFrom', Coupon."Starting Date");

        if (Coupon."Ending Date" > 0DT) then
            Json.AddProperty('validUntil', Coupon."Ending Date");

        Json.AddProperty('maxUsesPerSale', Coupon."Max Use per Sale");

        if Coupon."Discount Type" = Coupon."Discount Type"::"Discount %" then
            Json.AddProperty('discountPercent', Coupon."Discount %")
        else
            Json.AddProperty('discountAmount', Coupon."Discount Amount");
        Json.AddProperty('maxDiscountAmount', Coupon."Max. Discount Amount");

        Json.AddProperty('customerNo', Coupon."Customer No.");
        Json.AddProperty('remainingQuantity', Coupon."Remaining Quantity");
        Json.EndObject();
    end;

    #endregion
}
#endif
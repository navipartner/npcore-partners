#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248253 "NPR RetailVoucherAgent"
{
    Access = Internal;

    internal procedure FindVouchers(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        ResponseJson: Codeunit "NPR JSON Builder";
    begin
        if (Request.QueryParams().ContainsKey('customerNumber')) then
            NpRvVoucher.SetFilter("Customer No.", '=%1', CopyStr(UpperCase(Request.QueryParams().Get('customerNumber')), 1, MaxStrLen(NpRvVoucher."Customer No.")));

        if (Request.QueryParams().ContainsKey('email')) then
            NpRvVoucher.SetFilter("E-mail", '=%1', CopyStr(LowerCase(Request.QueryParams().Get('email')), 1, MaxStrLen(NpRvVoucher."E-mail")));

        if (Request.QueryParams().ContainsKey('referenceNo')) then
            NpRvVoucher.SetFilter("Reference No.", '=%1', CopyStr(LowerCase(Request.QueryParams().Get('referenceNo')), 1, MaxStrLen(NpRvVoucher."Reference No.")));

        NpRvVoucher.SetRange("Disabled for Web Service", false);
        ResponseJson.StartObject('');
        ResponseJson.StartArray('vouchers');
        if NpRvVoucher.FindSet() then begin
            repeat
                VoucherAsJson(NpRvVoucher, 'voucher', ResponseJson);
            until NpRvVoucher.Next() = 0;
        end;
        ResponseJson.EndArray().EndObject();
        exit(Response.RespondOK(ResponseJson));
    end;

    internal procedure CreateVoucher(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        RequestJson: JsonObject;
        Json: Codeunit "NPR JSON Builder";
    begin
        RequestJson := Request.BodyJson().AsObject();
        if not VerifyCreateRequest(RequestJson, Response) then
            exit(Response);

        CreateVoucher(RequestJson.AsToken(), Json);
        exit(Response.RespondOK(Json));
    end;

    internal procedure GetVoucher(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        Json: Codeunit "NPR Json Builder";
        VoucherId: Text;
    begin
        VoucherId := Request.Paths().Get(2);
        if VoucherId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: voucherId'));

        if (not FindVoucherById(VoucherId, NpRvVoucher, Response)) then
            exit(Response);

        Json.StartObject('');
        VoucherAsJson(NpRvVoucher, 'voucher', Json);
        Json.EndObject();

        exit(Response.RespondOK(Json));
    end;

    internal procedure ReserveVoucher(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        RequestJson: JsonObject;
        VoucherId: Text;
        Json: Codeunit "NPR JSON Builder";
    begin
        VoucherId := Request.Paths().Get(2);
        if VoucherId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: voucherId'));

        RequestJson := Request.BodyJson().AsObject();
        if not VerifyReserveRequest(RequestJson, Response) then
            exit(Response);

        if (not FindVoucherById(VoucherId, NpRvVoucher, Response)) then
            exit(Response);

        if not DoRequest(NpRvVoucher, RequestJson.AsToken(), Response, true) then
            exit(Response);

        ReserveVoucher(NpRvVoucher, RequestJson.AsToken(), Json);

        exit(Response.RespondOK(Json));
    end;

    internal procedure CancelVoucherReservation(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        ReservationId: Text;
        Json: Codeunit "NPR JSON Builder";
    begin
        ReservationId := Request.Paths().Get(3);
        if ReservationId = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: reservationId'));

        if not NpRvSalesLine.GetBySystemId(ReservationId) then
            exit(Response.RespondBadRequest('ReservationId not found'));

        NpRvVoucher.Get(NpRvSalesLine."Voucher No.");
        CancelReserveVoucher(NpRvVoucher, NpRvSalesLine, Json);
        exit(Response.RespondOK(Json));
    end;

    internal procedure DoRequest(NpRvVoucher: Record "NPR NpRv Voucher"; RequestJToken: JsonToken; var Response: Codeunit "NPR API Response"; Reserve: Boolean): Boolean
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        JsonHelper: Codeunit "NPR Json Helper";
        AvailableAmount: Decimal;
        Amount: Decimal;
        ReservationId: Text;
    begin
        if Reserve then begin
            NpRvVoucher.CalcFields("Apply Payment Module", NpRvVoucher."Initial Amount");
            Amount := JsonHelper.GetJDecimal(RequestJToken, 'amount', true);
            if NpRvVoucher."Apply Payment Module" = ModuleCode() then begin
                if Amount <> NpRvVoucher."Initial Amount" then begin
                    Response.RespondBadRequest('Full amount should be reserved for this voucher type');
                    exit(false);
                end;
            end;

            if not NpRvVoucherMgt.ValidateAmount(NpRvVoucher, Amount, AvailableAmount) then begin
                Response.RespondBadRequest('Insufficient balance on voucher');
                exit(false);
            end;
        end;

        if not Reserve then begin
            ReservationId := JsonHelper.GetJText(RequestJToken, 'reservationId', true);
            if not NpRvSalesLine.GetBySystemId(ReservationId) then begin
                Response.RespondBadRequest('ReservationId not found');
                exit(false);
            end;
        end;

        exit(true);
    end;

    internal procedure ReserveVoucher(NpRvVoucher: Record "NPR NpRv Voucher"; RequestJToken: JsonToken; var Json: Codeunit "NPR JSON Builder")
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        JsonHelper: Codeunit "NPR Json Helper";
        DocumentNo: Text;
        Amount: Decimal;
    begin
        DocumentNo := JsonHelper.GetJText(RequestJToken, 'documentNo', true);
        Amount := JsonHelper.GetJDecimal(RequestJToken, 'amount', true);

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
#pragma warning disable AA0139
        NpRvSalesLine."External Document No." := DocumentNo;
#pragma warning restore AA0139
        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
        NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
        NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
        NpRvSalesLine.Description := NpRvVoucher.Description;
        NpRvSalesLine.Amount := Amount;
        NpRvSalesLine.Insert();

        BuildReserveResponse(NpRvVoucher, NpRvSalesLine.SystemId, Json, true);
    end;

    local procedure BuildReserveResponse(NpRvVoucher: Record "NPR NpRv Voucher"; ReservationId: guid; var Json: Codeunit "NPR JSON Builder"; Reserve: Boolean)
    begin
        Json.StartObject('');
        VoucherReserveAsJson(NpRvVoucher, ReservationId, 'reservation', Json, Reserve);
        Json.EndObject();
    end;

    internal procedure CancelReserveVoucher(NpRvVoucher: Record "NPR NpRv Voucher"; NpRvSalesLine: Record "NPR NpRv Sales Line"; var Json: Codeunit "NPR JSON Builder")
    begin
        NpRvSalesLine.Delete(true);
        BuildReserveResponse(NpRvVoucher, NpRvSalesLine.SystemId, Json, false);
    end;

    local procedure CreateVoucher(RequestJson: JsonToken; var Json: Codeunit "NPR JSON Builder")
    var
        TempNpRvSalesLine: Record "NPR NpRv Sales Line" temporary;
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        TempNpRvVoucher: Record "NPR NpRv Voucher" temporary;
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
    begin
        JsontoTempNpRvSalesLine(TempNpRvSalesLine, RequestJson);

        NpRvSalesLine.SetRange("External Document No.", TempNpRvSalesLine."Document No.");
        NpRvSalesLine.SetRange("Reference No.", TempNpRvSalesLine."Reference No.");
        if NpRvSalesLine.FindFirst() then begin
            VoucherSalesLinetoJson(NpRvSalesLine, 'voucher', Json);
            exit;
        end;

        if TempNpRvSalesLine."Reference No." <> '' then begin
            if FindVoucher(TempNpRvSalesLine."Voucher Type", TempNpRvSalesLine."Reference No.", NpRvVoucher) then begin
                NpRvVoucher.TestField("Allow Top-up");
                Voucher2TempNpRvSalesLine(NpRvVoucher, TempNpRvSalesLine);
                NpRvSalesLine.Init();
                NpRvSalesLine.Id := CreateGuid();
                NpRvSalesLine.Type := NpRvSalesLine.Type::"Top-up";
                NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
                NpRvSalesLine."External Document No." := TempNpRvSalesLine."Document No.";
                TempNpRvSalesLineToNpRvSalesLine(TempNpRvSalesLine, NpRvSalesLine);
                NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
                NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
                NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
                NpRvSalesLine.Description := NpRvVoucher.Description;
                NpRvSalesLine.Insert(true);

                VoucherSalesLinetoJson(TempNpRvSalesLine, 'voucher', Json);
                exit;
            end;
            if FindSalesVoucher(TempNpRvSalesLine."Voucher Type", TempNpRvSalesLine."Reference No.", NpRvSalesLine) then begin
                VoucherSalesLinetoJson(NpRvSalesLine, 'voucher', Json);
                exit;
            end;
        end;

        TempNpRvSalesLine.TestField("Voucher Type");
        NpRvVoucherType.Get(TempNpRvSalesLine."Voucher Type");
        NpRvVoucherMgt.GenerateTempVoucher(NpRvVoucherType, TempNpRvVoucher);
        TempNpRvSalesLineToVoucher(TempNpRvVoucher, TempNpRvSalesLine);
        TempNpRvVoucher.Insert();

        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine.Type := NpRvSalesLine.Type::"New Voucher";
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."External Document No." := TempNpRvSalesLine."Document No.";
        TempNpRvSalesLineToNpRvSalesLine(TempNpRvSalesLine, NpRvSalesLine);
        NpRvSalesLine."Voucher No." := TempNpRvVoucher."No.";
        NpRvSalesLine."Reference No." := TempNpRvVoucher."Reference No.";
        NpRvSalesLine."Voucher Type" := TempNpRvVoucher."Voucher Type";
        NpRvSalesLine.Description := TempNpRvVoucher.Description;
        NpRvSalesLine.Insert(true);

        NpRvSalesDocMgt.InsertNpRVSalesLineReference(NpRvSalesLine, TempNpRvVoucher);
        VoucherSalesLinetoJson(NpRvSalesLine, 'voucher', Json);
    end;

    local procedure VoucherAsJson(NpRvVoucher: Record "NPR NpRv Voucher"; JsonObjectName: Text; var ResponseJson: Codeunit "NPR Json Builder")
    var
        PaymentMethodCode: Code[10];
    begin
        NpRvVoucher.CalcFields(Amount, "Initial Amount", "Reserved Amount", Open);
        ResponseJson.StartObject(JsonObjectName)
            .AddProperty('voucherId', Format(NpRvVoucher.systemId, 0, 4).ToLower())
            .AddProperty('referenceNo', NpRvVoucher."Reference No.")
            .AddProperty('voucherType', NpRvVoucher."Voucher Type")
            .AddProperty('description', NpRvVoucher.Description)
            .AddProperty('startingDate', NpRvVoucher."Starting Date")
            .AddProperty('endingDate', NpRvVoucher."Ending Date")
            .AddProperty('initialAmount', NpRvVoucher."Initial Amount")
            .AddProperty('amount', NpRvVoucher.Amount)
            .AddProperty('reservedAmount', NpRvVoucher."Reserved Amount")
            .AddProperty('open', NpRvVoucher.Open)
            .AddProperty('name', NpRvVoucher.Name)
            .AddProperty('name2', NpRvVoucher."Name 2")
            .AddProperty('address', NpRvVoucher.Address)
            .AddProperty('address2', NpRvVoucher."Address 2")
            .AddProperty('postCode', NpRvVoucher."Post Code")
            .AddProperty('city', NpRvVoucher.City)
            .AddProperty('county', NpRvVoucher.County)
            .AddProperty('countryCode', NpRvVoucher."Country/Region Code")
            .AddProperty('email', NpRvVoucher."E-mail")
            .AddProperty('phoneNo', NpRvVoucher."Phone No.")
            .AddProperty('voucherMessage', NpRvVoucher."Voucher Message");
        ResponseJson.StartArray('items');
        if CheckIfPaymentMethodItemsExistVoucher(NpRvVoucher."Reference No.", PaymentMethodCode) then
            ResponseJson.AddArray(VoucherItems(PaymentMethodCode, ResponseJson));
        ResponseJson.EndArray();
        ResponseJson.EndObject();
    end;

    local procedure VoucherItems(PaymentMethodCode: code[10]; ResponseJson: Codeunit "NPR Json Builder"): Codeunit "NPR JSON Builder"
    var
        POSPaymentMethodItem: Record "NPR POS Payment Method Item";
    begin
        POSPaymentMethodItem.SetRange("POS Payment Method Code", PaymentMethodCode);
        if POSPaymentMethodItem.FindSet() then
            repeat
                ResponseJson.StartObject()
                .AddProperty('type', TypetoText(POSPaymentMethodItem.Type))
                .AddProperty('itemNo', POSPaymentMethodItem."No.")
                .AddProperty('description', POSPaymentMethodItem.Description)
                .EndObject();
            until POSPaymentMethodItem.Next() = 0;
    end;

    local procedure TypetoText(POSPaymentmethodItemType: Enum "NPR POS Pmt. Method Item Type"): Text
    begin
        case POSPaymentmethodItemType of
            POSPaymentmethodItemType::Item:
                exit('Item');
            POSPaymentmethodItemType::"Item Categories":
                exit('Item Categories');
        end;
    end;

    local procedure CheckIfPaymentMethodItemsExistVoucher(ReferenceNo: Text[50]; var PaymentMethodCode: Code[10]) HasItemFilter: Boolean
    var
        POSPmtMethodItemMgt: Codeunit "NPR POS Pmt. Method Item Mgt.";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        PaymentMethodCode := NpRvVoucherMgt.GetVoucherPaymentMethod(ReferenceNo);
        if PaymentMethodCode = '' then
            exit;

        HasItemFilter := POSPmtMethodItemMgt.HasPOSPaymentMethodItemFilter(PaymentMethodCode);
    end;

    procedure FindSalesVoucher(VoucherTypeFilter: Text; ReferenceNo: Text[50]; var NpRvSalesLine: Record "NPR NpRv Sales Line"): Boolean
    begin
        NpRvSalesLine.SetFilter("Voucher Type", UpperCase(VoucherTypeFilter));
        NpRvSalesLine.SetRange("Reference No.", ReferenceNo);
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        exit(NpRvSalesLine.FindLast());
    end;

    local procedure TempNpRvSalesLineToNpRvSalesLine(var TempNpRvSalesLine: Record "NPR NpRv Sales Line" temporary; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
        NpRvSalesLine."Voucher Type" := TempNpRvSalesLine."Voucher Type";
        NpRvSalesLine.Description := TempNpRvSalesLine.Description;
        NpRvSalesLine."Starting Date" := TempNpRvSalesLine."Starting Date";
        NpRvSalesLine.Name := TempNpRvSalesLine.Name;
        NpRvSalesLine."Name 2" := TempNpRvSalesLine."Name 2";
        NpRvSalesLine.Address := TempNpRvSalesLine.Address;
        NpRvSalesLine."Address 2" := TempNpRvSalesLine."Address 2";
        NpRvSalesLine."Post Code" := TempNpRvSalesLine."Post Code";
        NpRvSalesLine.City := TempNpRvSalesLine.City;
        NpRvSalesLine.County := TempNpRvSalesLine.County;
        NpRvSalesLine."Country/Region Code" := TempNpRvSalesLine."Country/Region Code";
        NpRvSalesLine."E-mail" := TempNpRvSalesLine."E-mail";
        NpRvSalesLine."Phone No." := TempNpRvSalesLine."Phone No.";
        NpRvSalesLine."Voucher Message" := TempNpRvSalesLine."Voucher Message";
    end;

    local procedure Voucher2TempNpRvSalesLine(var NpRvVoucher: Record "NPR NpRv Voucher"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
        NpRvSalesLine.Name := NpRvVoucher.Name;
        NpRvSalesLine."Name 2" := NpRvVoucher."Name 2";
        NpRvSalesLine.Address := NpRvVoucher.Address;
        NpRvSalesLine."Address 2" := NpRvVoucher."Address 2";
        NpRvSalesLine."Post Code" := NpRvVoucher."Post Code";
        NpRvSalesLine.City := NpRvVoucher.City;
        NpRvSalesLine.County := NpRvVoucher.County;
        NpRvSalesLine."Country/Region Code" := NpRvVoucher."Country/Region Code";
        NpRvSalesLine."E-mail" := NpRvVoucher."E-mail";
        NpRvSalesLine."Phone No." := NpRvVoucher."Phone No.";
        NpRvSalesLine."Voucher Message" := NpRvVoucher."Voucher Message";
        NpRvSalesLine.Modify();
    end;

    local procedure TempNpRvSalesLineToVoucher(var NpRvVoucher: Record "NPR NpRv Voucher"; var NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
        NpRvVoucher.Name := NpRvSalesLine.Name;
        NpRvVoucher."Name 2" := NpRvSalesLine."Name 2";
        NpRvVoucher.Address := NpRvSalesLine.Address;
        NpRvVoucher."Address 2" := NpRvSalesLine."Address 2";
        NpRvVoucher."Post Code" := NpRvSalesLine."Post Code";
        NpRvVoucher.City := NpRvSalesLine.City;
        NpRvVoucher.County := NpRvSalesLine.County;
        NpRvVoucher."Country/Region Code" := NpRvSalesLine."Country/Region Code";
        NpRvVoucher."E-mail" := NpRvSalesLine."E-mail";
        NpRvVoucher."Phone No." := NpRvSalesLine."Phone No.";
        NpRvVoucher."Voucher Message" := NpRvSalesLine."Voucher Message";
    end;

    procedure FindVoucher(VoucherTypeFilter: Text; ReferenceNo: Text[50]; var Voucher: Record "NPR NpRv Voucher"): Boolean
    begin
        if ReferenceNo = '' then
            exit(false);

        Voucher.SetFilter("Voucher Type", UpperCase(VoucherTypeFilter));
        Voucher.SetRange("Reference No.", ReferenceNo);
        Voucher.SetRange("Disabled for Web Service", false);
        if Voucher.FindLast() then
            exit(true);

        Voucher.SetRange("Voucher Type");
        exit(Voucher.FindLast());
    end;

    internal procedure GetCustomerByNo(var Request: Codeunit "NPR API Request"; PathPosition: Integer; var Customer: Record Customer): Boolean
    var
        CustomerNoText: Text[20];
        CustomerNo: Code[20];
    begin
        CustomerNoText := CopyStr(Request.Paths().Get(PathPosition), 1, MaxStrLen(CustomerNoText));
        if (CustomerNoText = '') then
            exit(false);

        if (not Evaluate(CustomerNo, CustomerNoText)) then
            exit(false);

        if (not Customer.get(CustomerNo)) then
            exit(false);

        exit(true);
    end;

    internal procedure IsValidEmail(var Request: Codeunit "NPR API Request"; PathPosition: Integer; var EmailText: Text): Boolean
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
    begin
        EmailText := CopyStr(Request.Paths().Get(PathPosition), 1, MaxStrLen(NpRvVoucher."E-mail"));
        if StrLen(EmailText) > MaxStrLen(NpRvVoucher."E-mail") then
            exit(false);

        exit(true);
    end;

    internal procedure FindandValidateArchiveVoucher(VoucherId: Text; var Response: Codeunit "NPR API Response"): Boolean
    var
        NpRvArchiveVoucher: Record "NPR NpRv Arch. Voucher";
    begin
        if not NpRvArchiveVoucher.GetBySystemId(VoucherId) then begin
            Response.RespondBadRequest('Not found, Invalid Reference number');
            exit(false);
        end else begin
            NpRvArchiveVoucher.CalcFields("Remaining Amount");
            if NpRvArchiveVoucher."Remaining Amount" = 0 then begin
                Response.RespondBadRequest('Voucher is fully used and archived');
                exit(false)
            end;

            if (NpRvArchiveVoucher."Ending Date" < NpRvArchiveVoucher.SystemCreatedAt) and (NpRvArchiveVoucher."Ending Date" <> 0DT) then begin
                Response.RespondBadRequest('Voucher is expired and archived');
                exit(false);
            end;

            Response.RespondBadRequest('Voucher is archived');
            exit(false);
        end;
    end;

    internal procedure ValidateActiveVoucher(NpRvVoucher: Record "NPR NpRv Voucher"; var Response: Codeunit "NPR API Response"): Boolean
    var
        TimeStamp: DateTime;
    begin
        if not NpRvVoucher."Allow Top-up" then begin
            NpRvVoucher.CalcFields(Open);
            if not NpRvVoucher.Open then begin
                Response.RespondBadRequest('Voucher is fully used');
                exit(false);
            end;
        end;

        Timestamp := CurrentDateTime;
        if NpRvVoucher."Starting Date" > Timestamp then begin
            Response.RespondBadRequest('Voucher is not valid yet');
            exit(false);
        end;

        if (NpRvVoucher."Ending Date" < Timestamp) and (NpRvVoucher."Ending Date" <> 0DT) then begin
            Response.RespondBadRequest('Voucher is expired');
            exit(false);
        end;

        exit(true);
    end;

    internal procedure FindVoucherById(VoucherId: Text; var NpRvVoucher: Record "NPR NpRv Voucher"; var Response: Codeunit "NPR API Response"): Boolean
    begin
        if not NpRvVoucher.GetBySystemId(VoucherId) then begin
            if not FindandValidateArchiveVoucher(VoucherId, Response) then
                exit(false);
        end else begin
            if not ValidateActiveVoucher(NpRvVoucher, Response) then
                exit(false);
        end;

        exit(true);
    end;

    local procedure VerifyCreateRequest(RequestJson: JsonObject; var Response: Codeunit "NPR API Response"): Boolean
    var
        TempText: Text;
    begin
        if not VerifyRequiredField(RequestJson, 'documentNo', TempText, Response) then
            exit(false);

        if not VerifyRequiredField(RequestJson, 'voucherType', TempText, Response) then
            exit(false);

        exit(true);
    end;

    local procedure VerifyReserveRequest(RequestJson: JsonObject; var Response: Codeunit "NPR API Response"): Boolean
    var
        TempText: Text;
        TempDecimal: Decimal;
    begin
        if not VerifyRequiredField(RequestJson, 'documentNo', TempText, Response) then
            exit(false);

        if not VerifyRequiredField(RequestJson, 'amount', TempDecimal, Response) then
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

    local procedure VoucherReserveAsJson(NpRvVoucher: Record "NPR NpRv Voucher"; ReservationId: Guid; JsonObjectName: Text; var Json: Codeunit "NPR Json Builder"; Reserve: Boolean)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvVoucher.CalcFields(Amount, "Initial Amount", "Reserved Amount");
        Json.StartObject(JsonObjectName)
            .AddProperty('voucherId', Format(NpRvVoucher.systemId, 0, 4).ToLower())
            .AddProperty('referenceNo', NpRvVoucher."Reference No.")
            .AddProperty('startingDate', NpRvVoucher."Starting Date")
            .AddProperty('endingDate', NpRvVoucher."Ending Date")
            .AddProperty('initialAmount', NpRvVoucher."Initial Amount")
            .AddProperty('amount', NpRvVoucher.Amount)
            .AddProperty('reservedAmount', NpRvVoucher."Reserved Amount");
        if Reserve then begin
            Json.AddProperty('reservationId', Format(ReservationId, 0, 4).ToLower());
            NpRvSalesLine.GetBySystemId(ReservationId);
            Json.AddProperty('reservationDocNo', NpRvSalesLine."External Document No.");
        end;
    end;

    local procedure VoucherSalesLinetoJson(NpRvSalesLine: Record "NPR NpRv Sales Line"; JsonObjectName: Text; var Json: Codeunit "NPR Json Builder")
    begin
        Json.StartObject(JsonObjectName)
            .AddProperty('documentNo', NpRvSalesLine."External Document No.")
            .AddProperty('referenceNo', NpRvSalesLine."Reference No.")
            .AddProperty('voucherType', NpRvSalesLine."Voucher Type")
            .AddProperty('description', NpRvSalesLine.Description)
            .AddProperty('startingDate', NpRvSalesLine."Starting Date")
            .AddProperty('name', NpRvSalesLine.Name)
            .AddProperty('name2', NpRvSalesLine."Name 2")
            .AddProperty('address', NpRvSalesLine.Address)
            .AddProperty('address2', NpRvSalesLine."Address 2")
            .AddProperty('postCode', NpRvSalesLine."Post Code")
            .AddProperty('city', NpRvSalesLine.City)
            .AddProperty('county', NpRvSalesLine.County)
            .AddProperty('countryCode', NpRvSalesLine."Country/Region Code")
            .AddProperty('email', NpRvSalesLine."E-mail")
            .AddProperty('phoneNo', NpRvSalesLine."Phone No.")
            .AddProperty('voucherMessage', NpRvSalesLine."Voucher Message");
        Json.EndObject();
    end;

    local procedure JsontoTempNpRvSalesLine(var TempNpRvSalesLine: Record "NPR NpRv Sales Line" temporary; RequestJson: JsonToken)
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        TempNpRvSalesLine.Init();
        TempNpRvSalesLine.Id := CreateGuid();
#pragma warning disable AA0139
        TempNpRvSalesLine."Document No." := JsonHelper.GetJText(RequestJson, 'documentNo', true);
        TempNpRvSalesLine."Reference No." := JsonHelper.GetJText(RequestJson, 'referenceNo', false);
        TempNpRvSalesLine."Voucher Type" := JsonHelper.GetJText(RequestJson, 'voucherType', false);
        TempNpRvSalesLine.Description := JsonHelper.GetJText(RequestJson, 'description', false);
        TempNpRvSalesLine."Starting Date" := JsonHelper.GetJDT(RequestJson, 'startingDate', false);
        TempNpRvSalesLine.Name := JsonHelper.GetJText(RequestJson, 'name', false);
        TempNpRvSalesLine."Name 2" := JsonHelper.GetJText(RequestJson, 'name2', false);
        TempNpRvSalesLine.Address := JsonHelper.GetJText(RequestJson, 'address', false);
        TempNpRvSalesLine."Address 2" := JsonHelper.GetJText(RequestJson, 'address2', false);
        TempNpRvSalesLine."Post Code" := JsonHelper.GetJText(RequestJson, 'postCode', false);
        TempNpRvSalesLine.City := JsonHelper.GetJText(RequestJson, 'city', false);
        TempNpRvSalesLine.County := JsonHelper.GetJText(RequestJson, 'county', false);
        TempNpRvSalesLine."Country/Region Code" := JsonHelper.GetJText(RequestJson, 'countryCode', false);
        TempNpRvSalesLine."E-mail" := JsonHelper.GetJText(RequestJson, 'email', false);
        TempNpRvSalesLine."Phone No." := JsonHelper.GetJText(RequestJson, 'phoneNo', false);
        TempNpRvSalesLine."Voucher Message" := JsonHelper.GetJText(RequestJson, 'voucherMessage', false);
#pragma warning restore AA0139
        TempNpRvSalesLine.Insert();
    end;

    local procedure ModuleCode(): Code[20]
    begin
        exit('DEFAULT');
    end;
}
#endif
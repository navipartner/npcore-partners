#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185107 "NPR API SubscriptionPmtMethods"
{
    Access = Internal;

    internal procedure GetPaymentMethods(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
        Json: Codeunit "NPR Json Builder";
        MembershipID: Text;
    begin
        MembershipID := Request.Paths().Get(2);
        if MembershipID = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: membershipId'));

        SelectLatestVersion();
        Membership.ReadIsolation := IsolationLevel::ReadCommitted;
        Membership.SetLoadFields(SystemId);
        if not Membership.GetBySystemId(MembershipID) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Membership %1', MembershipID)));

        MemberPaymentMethod.ReadIsolation := IsolationLevel::ReadCommitted;
        MemberPaymentMethod.SetRange("Table No.", Membership.RecordId().TableNo());
        MemberPaymentMethod.SetRange("BC Record ID", Membership.RecordId());
        Json.StartObject('');
        Json.StartArray('paymentMethods');
        if MemberPaymentMethod.FindSet() then
            repeat
                PaymentMethodAsJson(MemberPaymentMethod, '', false, Json);
            until MemberPaymentMethod.Next() = 0;
        Json.EndArray().EndObject();

        exit(Response.RespondOK(Json));
    end;

    internal procedure GetPaymentMethod(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Json: Codeunit "NPR Json Builder";
        PaymentMethodID: Text;
    begin
        PaymentMethodID := Request.Paths().Get(3);
        if PaymentMethodID = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: paymentMethodId'));

        MemberPaymentMethod.ReadIsolation := IsolationLevel::ReadCommitted;
        if not MemberPaymentMethod.GetBySystemId(PaymentMethodID) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Payment Method %1', PaymentMethodID)));

        Json.StartObject('');
        PaymentMethodAsJson(MemberPaymentMethod, 'paymentMethod', false, Json);
        Json.EndObject();

        exit(Response.RespondOK(Json));
    end;

    internal procedure CreatePaymentMethod(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        TempMemberPaymentMethod: Record "NPR MM Member Payment Method" temporary;
        Membership: Record "NPR MM Membership";
        Json: Codeunit "NPR Json Builder";
        JsonHelper: Codeunit "NPR Json Helper";
        PaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
        RequestBody: JsonToken;
        MembershipID: Text;
        PSPAsString: Text;
        IsModified: Boolean;
    begin
        MembershipID := Request.Paths().Get(2);
        if MembershipID = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: membershipId'));

        RequestBody := Request.BodyJson();
        PSPAsString := JsonHelper.GetJText(RequestBody, 'paymentMethod.PSP', false);
        if PSPAsString <> '' then
            if not Enum::"NPR MM Subscription PSP".Names().Contains(PSPAsString) then
                exit(Response.RespondResourceNotFound(StrSubstNo('PSP %1', PSPAsString)));

        Membership.ReadIsolation := IsolationLevel::ReadCommitted;
        Membership.SetLoadFields(SystemId);
        if not Membership.GetBySystemId(MembershipID) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Membership %1', MembershipID)));

        if PSPAsString <> '' then
            TempMemberPaymentMethod.PSP := Enum::"NPR MM Subscription PSP".FromInteger(Enum::"NPR MM Subscription PSP".Ordinals().Get(Enum::"NPR MM Subscription PSP".Names().IndexOf(PSPAsString)));
        TempMemberPaymentMethod."Payment Brand" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.paymentBrand', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Brand"));
        TempMemberPaymentMethod."Payment Instrument Type" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.paymentInstrument', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Instrument Type"));
        TempMemberPaymentMethod."Masked PAN" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.maskedPAN', false), 1, MaxStrLen(TempMemberPaymentMethod."Masked PAN"));
        TempMemberPaymentMethod."PAN Last 4 Digits" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.PANLastDigits', false), 1, MaxStrLen(TempMemberPaymentMethod."PAN Last 4 Digits"));
        TempMemberPaymentMethod."Expiry Date" := JsonHelper.GetJDate(RequestBody, 'paymentMethod.expiryDate', false);
        TempMemberPaymentMethod.Default := JsonHelper.GetJBoolean(RequestBody, 'paymentMethod.default', false);
        TempMemberPaymentMethod."Payment Method Alias" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.alias', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Method Alias"));
        TempMemberPaymentMethod."Shopper Reference" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.shopperReference', false), 1, MaxStrLen(TempMemberPaymentMethod."Shopper Reference"));
        TempMemberPaymentMethod."Payment Token" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.paymentToken', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Token"));

        if PaymentMethodMgt.FindMemberPaymentMethod(TempMemberPaymentMethod."Payment Token", TempMemberPaymentMethod."Shopper Reference", TempMemberPaymentMethod.PSP, Membership, MemberPaymentMethod) then begin
            if MemberPaymentMethod."Payment Brand" <> TempMemberPaymentMethod."Payment Brand" then begin
                MemberPaymentMethod."Payment Brand" := TempMemberPaymentMethod."Payment Brand";
                IsModified := true;
            end;

            if MemberPaymentMethod."Payment Instrument Type" <> TempMemberPaymentMethod."Payment Instrument Type" then begin
                MemberPaymentMethod."Payment Instrument Type" := TempMemberPaymentMethod."Payment Instrument Type";
                IsModified := true;
            end;

            if (MemberPaymentMethod."Expiry Date" <> TempMemberPaymentMethod."Expiry Date") then begin
                MemberPaymentMethod."Expiry Date" := TempMemberPaymentMethod."Expiry Date";
                IsModified := true;
            end;

            if MemberPaymentMethod.Default <> TempMemberPaymentMethod.Default then begin
                MemberPaymentMethod.Validate(Default, TempMemberPaymentMethod.Default);
                IsModified := true;
            end;

            if MemberPaymentMethod."Payment Method Alias" <> TempMemberPaymentMethod."Payment Method Alias" then begin
                MemberPaymentMethod."Payment Method Alias" := TempMemberPaymentMethod."Payment Method Alias";
                IsModified := true;
            end;

            if IsModified then
                MemberPaymentMethod.Modify(true);
        end else begin
            Clear(MemberPaymentMethod);
            MemberPaymentMethod.Init();
            MemberPaymentMethod."Entry No." := 0;
            MemberPaymentMethod."Table No." := Membership.RecordId().TableNo();
            MemberPaymentMethod."BC Record ID" := Membership.RecordId();
            MemberPaymentMethod.PSP := TempMemberPaymentMethod.PSP;
            MemberPaymentMethod."Payment Brand" := TempMemberPaymentMethod."Payment Brand";
            MemberPaymentMethod."Payment Instrument Type" := TempMemberPaymentMethod."Payment Instrument Type";
            MemberPaymentMethod."Masked PAN" := TempMemberPaymentMethod."Masked PAN";
            MemberPaymentMethod."PAN Last 4 Digits" := TempMemberPaymentMethod."PAN Last 4 Digits";
            MemberPaymentMethod."Expiry Date" := TempMemberPaymentMethod."Expiry Date";
            MemberPaymentMethod.Validate(Default, TempMemberPaymentMethod.Default);
            MemberPaymentMethod."Payment Method Alias" := TempMemberPaymentMethod."Payment Method Alias";
            MemberPaymentMethod."Shopper Reference" := TempMemberPaymentMethod."Shopper Reference";
            MemberPaymentMethod."Payment Token" := TempMemberPaymentMethod."Payment Token";
            MemberPaymentMethod.Insert(true);
        end;

        Json.StartObject('');
        PaymentMethodAsJson(MemberPaymentMethod, 'paymentMethod', true, Json);
        Json.EndObject();

        exit(Response.RespondOK(Json));
    end;

    internal procedure UpdatePaymentMethod(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Json: Codeunit "NPR Json Builder";
        JsonHelper: Codeunit "NPR Json Helper";
        RequestBody: JsonToken;
        JToken: JsonToken;
        NewExpiryDate: Date;
        NewStatusString: Text;
        PaymentMethodID: Text;
    begin
        PaymentMethodID := Request.Paths().Get(3);
        if PaymentMethodID = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: paymentMethodId'));

        RequestBody := Request.BodyJson();
        NewStatusString := JsonHelper.GetJText(RequestBody, 'paymentMethod.status', false);
        if NewStatusString <> '' then
            if not Enum::"NPR MM Payment Method Status".Names().Contains(NewStatusString) then
                exit(Response.RespondResourceNotFound(StrSubstNo('Payment method status %1', NewStatusString)));

        MemberPaymentMethod.ReadIsolation := IsolationLevel::ReadCommitted;
        if not MemberPaymentMethod.GetBySystemId(PaymentMethodID) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Payment Method %1', PaymentMethodID)));

        if NewStatusString <> '' then
            MemberPaymentMethod.Status := Enum::"NPR MM Payment Method Status".FromInteger(Enum::"NPR MM Payment Method Status".Ordinals().Get(Enum::"NPR MM Payment Method Status".Names().IndexOf(NewStatusString)));
        NewExpiryDate := JsonHelper.GetJDate(RequestBody, 'paymentMethod.expiryDate', false);
        if NewExpiryDate <> 0D then
            MemberPaymentMethod."Expiry Date" := NewExpiryDate;
        if RequestBody.SelectToken('paymentMethod.default', JToken) then
            MemberPaymentMethod.Validate(Default, JsonHelper.GetJBoolean(RequestBody, 'paymentMethod.default', false));
        if RequestBody.SelectToken('paymentMethod.alias', JToken) then
            MemberPaymentMethod."Payment Method Alias" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.alias', false), 1, MaxStrLen(MemberPaymentMethod."Payment Method Alias"));
        MemberPaymentMethod.Modify(true);

        Json.StartObject('');
        PaymentMethodAsJson(MemberPaymentMethod, 'paymentMethod', false, Json);
        Json.EndObject();

        exit(Response.RespondOK(Json));
    end;

    internal procedure DeletePaymentMethod(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Json: Codeunit "NPR Json Builder";
        PaymentMethodID: Text;
    begin
        PaymentMethodID := Request.Paths().Get(3);
        if PaymentMethodID = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: paymentMethodId'));

        MemberPaymentMethod.ReadIsolation := IsolationLevel::ReadCommitted;
        if not MemberPaymentMethod.GetBySystemId(PaymentMethodID) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Payment Method %1', PaymentMethodID)));
        MemberPaymentMethod.Delete(true);

        Json.StartObject('');
        PaymentMethodAsJson(MemberPaymentMethod, 'paymentMethod', false, Json);
        Json.EndObject();

        exit(Response.RespondOK(Json));
    end;

    internal procedure PaymentMethodAsJson(MemberPaymentMethod: Record "NPR MM Member Payment Method"; JsonObjectName: Text; WithToken: Boolean; var Json: Codeunit "NPR Json Builder")
    begin
        Json.StartObject(JsonObjectName)
            .AddProperty('id', Format(MemberPaymentMethod.SystemId, 0, 4).ToLower())
            .AddProperty('maskedPAN', MemberPaymentMethod."Masked PAN")
            .AddProperty('PANLastDigits', MemberPaymentMethod."PAN Last 4 Digits")
            .AddProperty('PSP', PSPEnumValueName(MemberPaymentMethod.PSP))
            .AddProperty('alias', MemberPaymentMethod."Payment Method Alias")
            .AddProperty('default', MemberPaymentMethod.Default)
            .AddProperty('expiryDate', MemberPaymentMethod."Expiry Date")
            .AddProperty('paymentBrand', MemberPaymentMethod."Payment Brand")
            .AddProperty('paymentInstrument', MemberPaymentMethod."Payment Instrument Type")
            .AddProperty('status', PaymentMethodStatusEnumValueName(MemberPaymentMethod.Status));
        if WithToken then
            Json
                .AddProperty('paymentToken', MemberPaymentMethod."Payment Token")
                .AddProperty('shopperReference', MemberPaymentMethod."Shopper Reference");
        Json.EndObject();
    end;

    local procedure PSPEnumValueName(SubscriptionPSP: Enum "NPR MM Subscription PSP") Result: Text
    begin
        SubscriptionPSP.Names().Get(SubscriptionPSP.Ordinals().IndexOf(SubscriptionPSP.AsInteger()), Result);
    end;

    local procedure PaymentMethodStatusEnumValueName(Status: Enum "NPR MM Payment Method Status") Result: Text
    begin
        Status.Names().Get(Status.Ordinals().IndexOf(Status.AsInteger()), Result);
    end;
}
#endif
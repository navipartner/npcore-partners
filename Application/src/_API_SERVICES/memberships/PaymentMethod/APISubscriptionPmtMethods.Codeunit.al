#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6185107 "NPR API SubscriptionPmtMethods"
{
    Access = Internal;

    internal procedure GetPaymentMethods(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        Membership: Record "NPR MM Membership";
        Json: Codeunit "NPR Json Builder";
        PmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
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

        Json.StartObject('');
        Json.StartArray('paymentMethods');
        PmtMethodMap.ReadIsolation := IsolationLevel::ReadCommitted;
        PmtMethodMap.SetRange(MembershipId, MembershipID);
        if PmtMethodMap.FindSet() then
            repeat
                MemberPaymentMethod.GetBySystemId(PmtMethodMap.PaymentMethodId);
                PaymentMethodAsJson(MemberPaymentMethod, '', false, PmtMethodMap.Default, Json);
            until PmtMethodMap.Next() = 0;
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
        PaymentMethodAsJson(MemberPaymentMethod, 'paymentMethod', false, false, Json);
        Json.EndObject();

        exit(Response.RespondOK(Json));
    end;

    internal procedure CreatePaymentMethod(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        TempMemberPaymentMethod: Record "NPR MM Member Payment Method" temporary;
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        UserAccount: Record "NPR UserAccount";
        Json: Codeunit "NPR Json Builder";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        RequestBody: JsonToken;
        MembershipID: Text;
        PSPAsString: Text;
        PayerAccountId: Guid;
        PayerEmail: Text[80];
        ErrorMessage: Text;
        Default: Boolean;
    begin
        MembershipID := Request.Paths().Get(2);
        if MembershipID = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: membershipId'));

        RequestBody := Request.BodyJson();
        if not ValidatePSP(RequestBody, PSPAsString) then
            exit(Response.RespondResourceNotFound(StrSubstNo('PSP %1', PSPAsString)));

        if not ParsePayer(RequestBody, PayerAccountId, PayerEmail, ErrorMessage) then
            exit(Response.RespondBadRequest(ErrorMessage));

        Membership.ReadIsolation := IsolationLevel::ReadCommitted;
        Membership.SetLoadFields("Entry No.", SystemId);
        if not Membership.GetBySystemId(MembershipID) then
            exit(Response.RespondResourceNotFound(StrSubstNo('Membership %1', MembershipID)));

        if not IsNullGuid(PayerAccountId) then begin
            UserAccount.ReadIsolation := IsolationLevel::ReadCommitted;
            if not UserAccount.GetBySystemId(PayerAccountId) then
                exit(Response.RespondResourceNotFound(StrSubstNo('User account with id "%1" could not be found', PayerAccountId)));
        end else
            if PayerEmail <> '' then
                FindOrCreatePayerAccountByEmail(Membership."Entry No.", PayerEmail, UserAccount)
            else begin
                if not MembershipMgtInternal.GetFirstAdminMember(Membership."Entry No.", Member) then
                    exit(Response.RespondBadRequest('Membership did not contain at least one admin member to assign card to.'));

                if not MembershipMgtInternal.GetUserAccountFromMember(Member, UserAccount) then
                    MembershipMgtInternal.CreateUserAccountFromMember(Member, UserAccount);
            end;

        ParsePaymentMethodInput(RequestBody, PSPAsString, TempMemberPaymentMethod);
        FindOrCreatePaymentMethod(TempMemberPaymentMethod, UserAccount, MemberPaymentMethod);

        Default := GetPaymentMethodDefault(RequestBody);
        EnsureMembershipPaymentMethod(Membership, MemberPaymentMethod, Default, MembershipPmtMethodMap);
        EnsureShopperRecognition(MemberPaymentMethod, UserAccount);

        Json.StartObject('');
        PaymentMethodAsJson(MemberPaymentMethod, 'paymentMethod', true, MembershipPmtMethodMap.Default, Json);
        Json.EndObject();

        exit(Response.RespondOK(Json));
    end;

    local procedure ValidatePSP(RequestBody: JsonToken; var PSPAsString: Text): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        PSPAsString := JsonHelper.GetJText(RequestBody, 'paymentMethod.PSP', false);
        if PSPAsString = '' then
            exit(true);
        exit(Enum::"NPR MM Subscription PSP".Names().Contains(PSPAsString));
    end;

    local procedure ParsePaymentMethodInput(RequestBody: JsonToken; PSPAsString: Text; var TempMemberPaymentMethod: Record "NPR MM Member Payment Method" temporary)
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        if PSPAsString <> '' then
            TempMemberPaymentMethod.PSP := Enum::"NPR MM Subscription PSP".FromInteger(Enum::"NPR MM Subscription PSP".Ordinals().Get(Enum::"NPR MM Subscription PSP".Names().IndexOf(PSPAsString)));

        TempMemberPaymentMethod."Payment Brand" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.paymentBrand', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Brand"));
        TempMemberPaymentMethod."Payment Instrument Type" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.paymentInstrument', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Instrument Type"));
        TempMemberPaymentMethod."Masked PAN" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.maskedPAN', false), 1, MaxStrLen(TempMemberPaymentMethod."Masked PAN"));
        TempMemberPaymentMethod."PAN Last 4 Digits" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.PANLastDigits', false), 1, MaxStrLen(TempMemberPaymentMethod."PAN Last 4 Digits"));
        TempMemberPaymentMethod."Expiry Date" := JsonHelper.GetJDate(RequestBody, 'paymentMethod.expiryDate', false);
        TempMemberPaymentMethod."Payment Method Alias" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.alias', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Method Alias"));
        TempMemberPaymentMethod."Shopper Reference" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.shopperReference', false), 1, MaxStrLen(TempMemberPaymentMethod."Shopper Reference"));
        TempMemberPaymentMethod."Payment Token" := CopyStr(JsonHelper.GetJText(RequestBody, 'paymentMethod.paymentToken', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Token"));
    end;

    local procedure FindOrCreatePaymentMethod(var TempMemberPaymentMethod: Record "NPR MM Member Payment Method" temporary; var UserAccount: Record "NPR UserAccount"; var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    var
        PaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
    begin
        if PaymentMethodMgt.FindPaymentMethod(TempMemberPaymentMethod."Payment Token", TempMemberPaymentMethod."Shopper Reference", TempMemberPaymentMethod.PSP, UserAccount, MemberPaymentMethod) then begin
            UpdatePaymentMethodFromInput(TempMemberPaymentMethod, MemberPaymentMethod);
            exit;
        end;

        InsertPaymentMethod(TempMemberPaymentMethod, UserAccount, MemberPaymentMethod);
    end;

    local procedure UpdatePaymentMethodFromInput(var TempMemberPaymentMethod: Record "NPR MM Member Payment Method" temporary; var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    var
        IsModified: Boolean;
    begin
        if MemberPaymentMethod."Payment Brand" <> TempMemberPaymentMethod."Payment Brand" then begin
            MemberPaymentMethod."Payment Brand" := TempMemberPaymentMethod."Payment Brand";
            IsModified := true;
        end;

        if MemberPaymentMethod."Payment Instrument Type" <> TempMemberPaymentMethod."Payment Instrument Type" then begin
            MemberPaymentMethod."Payment Instrument Type" := TempMemberPaymentMethod."Payment Instrument Type";
            IsModified := true;
        end;

        if MemberPaymentMethod."Expiry Date" <> TempMemberPaymentMethod."Expiry Date" then begin
            MemberPaymentMethod."Expiry Date" := TempMemberPaymentMethod."Expiry Date";
            IsModified := true;
        end;

        if MemberPaymentMethod."Payment Method Alias" <> TempMemberPaymentMethod."Payment Method Alias" then begin
            MemberPaymentMethod."Payment Method Alias" := TempMemberPaymentMethod."Payment Method Alias";
            IsModified := true;
        end;

        if IsModified then
            MemberPaymentMethod.Modify(true);
    end;

    local procedure InsertPaymentMethod(var TempMemberPaymentMethod: Record "NPR MM Member Payment Method" temporary; var UserAccount: Record "NPR UserAccount"; var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    begin
        Clear(MemberPaymentMethod);
        MemberPaymentMethod.Init();
        MemberPaymentMethod."Entry No." := 0;
        MemberPaymentMethod."Table No." := UserAccount.RecordId().TableNo();
        MemberPaymentMethod."BC Record ID" := UserAccount.RecordId();
        MemberPaymentMethod."BC Record System ID" := UserAccount.SystemId;
        MemberPaymentMethod.PSP := TempMemberPaymentMethod.PSP;
        MemberPaymentMethod."Payment Brand" := TempMemberPaymentMethod."Payment Brand";
        MemberPaymentMethod."Payment Instrument Type" := TempMemberPaymentMethod."Payment Instrument Type";
        MemberPaymentMethod."Masked PAN" := TempMemberPaymentMethod."Masked PAN";
        MemberPaymentMethod."PAN Last 4 Digits" := TempMemberPaymentMethod."PAN Last 4 Digits";
        MemberPaymentMethod."Expiry Date" := TempMemberPaymentMethod."Expiry Date";
        MemberPaymentMethod."Payment Method Alias" := TempMemberPaymentMethod."Payment Method Alias";
        MemberPaymentMethod."Shopper Reference" := TempMemberPaymentMethod."Shopper Reference";
        MemberPaymentMethod."Payment Token" := TempMemberPaymentMethod."Payment Token";
        MemberPaymentMethod.Insert(true);
    end;

    local procedure GetPaymentMethodDefault(RequestBody: JsonToken): Boolean
    var
        JsonHelper: Codeunit "NPR Json Helper";
    begin
        exit(JsonHelper.GetJBoolean(RequestBody, 'paymentMethod.default', false));
    end;

    local procedure EnsureMembershipPaymentMethod(var Membership: Record "NPR MM Membership"; var MemberPaymentMethod: Record "NPR MM Member Payment Method"; Default: Boolean; var MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap")
    begin
        if MembershipPmtMethodMap.Get(MemberPaymentMethod.SystemId, Membership.SystemId) then begin
            if MembershipPmtMethodMap.Default <> Default then begin
                MembershipPmtMethodMap.Validate(Default, Default);
                MembershipPmtMethodMap.Modify(true);
            end;
            exit;
        end;

        MembershipPmtMethodMap.Init();
        MembershipPmtMethodMap.PaymentMethodId := MemberPaymentMethod.SystemId;
        MembershipPmtMethodMap.MembershipId := Membership.SystemId;
        MembershipPmtMethodMap.Status := MembershipPmtMethodMap.Status::Active;
        MembershipPmtMethodMap.Validate(Default, Default);
        MembershipPmtMethodMap.Insert();
    end;

    local procedure EnsureShopperRecognition(var MemberPaymentMethod: Record "NPR MM Member Payment Method"; var UserAccount: Record "NPR UserAccount")
    var
        EFTShopperRecognition: Record "NPR EFT Shopper Recognition";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        EntityType: Option Customer,Contact,Membership,UserAccount;
    begin
        if (MemberPaymentMethod."Shopper Reference" = '') or (MemberPaymentMethod.PSP <> MemberPaymentMethod.PSP::Adyen) then
            exit;

        EFTAdyenIntegration.GetCreateEFTShopperRecognition(Format(UserAccount.AccountNo), EntityType::UserAccount, EFTAdyenIntegration.CloudIntegrationType(), EFTShopperRecognition);
    end;

    local procedure ParsePayer(RequestBody: JsonToken; var PayerAccountId: Guid; var PayerEmail: Text[80]; var ErrorMessage: Text): Boolean
    var
        MailManagement: Codeunit "Mail Management";
        AccountIdToken: JsonToken;
        EmailToken: JsonToken;
        AccountIdSent: Boolean;
        EmailSent: Boolean;
        TokenText: Text;
        Tab: Text[1];
        Nbsp: Text[1];
    begin
        AccountIdSent := GetNonNullToken(RequestBody, 'payerAccountId', AccountIdToken);
        EmailSent := GetNonNullToken(RequestBody, 'payerEmail', EmailToken);
        if AccountIdSent and EmailSent then begin
            ErrorMessage := 'Only one of payerAccountId or payerEmail can be specified.';
            exit(false);
        end;

        if AccountIdSent then begin
            ErrorMessage := 'Malformed parameter: payerAccountId';
            if not AccountIdToken.IsValue() then
                exit(false);
            TokenText := AccountIdToken.AsValue().AsText().Trim();
            if TokenText = '' then
                exit(false);
            if not Evaluate(PayerAccountId, TokenText) then
                exit(false);
            if IsNullGuid(PayerAccountId) then
                exit(false);
        end;

        if EmailSent then begin
            ErrorMessage := 'Malformed parameter: payerEmail';
            if not EmailToken.IsValue() then
                exit(false);
            TokenText := EmailToken.AsValue().AsText().Trim();
            if TokenText = '' then
                exit(false);
            Tab[1] := 9;
            Nbsp[1] := 160;
            if DelChr(TokenText, '=', '<>()[]";:, ' + Tab + Nbsp) <> TokenText then
                exit(false);
            if StrLen(TokenText) > MaxStrLen(PayerEmail) then
                exit(false);
            if not MailManagement.CheckValidEmailAddress(TokenText) then
                exit(false);
            PayerEmail := CopyStr(TokenText.ToLower(), 1, MaxStrLen(PayerEmail));
        end;

        ErrorMessage := '';
        exit(true);
    end;

    local procedure GetNonNullToken(RequestBody: JsonToken; TokenKey: Text; var Token: JsonToken): Boolean
    begin
        if not RequestBody.SelectToken(TokenKey, Token) then
            exit(false);
        if not Token.IsValue() then
            exit(true);
        exit(not Token.AsValue().IsNull());
    end;

    local procedure FindOrCreatePayerAccountByEmail(MembershipEntryNo: Integer; PayerEmail: Text[80]; var UserAccount: Record "NPR UserAccount")
    var
        Member: Record "NPR MM Member";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        UserAccountMgtImpl: Codeunit "NPR UserAccountMgtImpl";
    begin
        if UserAccountMgtImpl.FindAccountByEmail(PayerEmail, UserAccount) then
            exit;

        if MembershipMgtInternal.GetFirstAdminMember(MembershipEntryNo, Member) then
            if Member."E-Mail Address".Trim().ToLower() = PayerEmail then begin
                MembershipMgtInternal.CreateUserAccountFromMember(Member, UserAccount);
                exit;
            end;

        MembershipMgtInternal.CreatePaymentUserAccountFromEmail(PayerEmail, UserAccount);
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
        PaymentMethodAsJson(MemberPaymentMethod, 'paymentMethod', false, false, Json);
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
        PaymentMethodAsJson(MemberPaymentMethod, 'paymentMethod', false, false, Json);
        Json.EndObject();

        exit(Response.RespondOK(Json));
    end;

    internal procedure PaymentMethodAsJson(MemberPaymentMethod: Record "NPR MM Member Payment Method"; JsonObjectName: Text; WithToken: Boolean; IsDefault: Boolean; var Json: Codeunit "NPR Json Builder")
    var
        UserAccount: Record "NPR UserAccount";
    begin
        if (not UserAccount.Get(MemberPaymentMethod."BC Record ID")) then
            UserAccount.Init();

        Json.StartObject(JsonObjectName)
            .AddProperty('id', Format(MemberPaymentMethod.SystemId, 0, 4).ToLower())
            .AddProperty('accountId', Format(UserAccount.SystemId, 0, 4).ToLower())
            .AddProperty('maskedPAN', MemberPaymentMethod."Masked PAN")
            .AddProperty('PANLastDigits', MemberPaymentMethod."PAN Last 4 Digits")
            .AddProperty('PSP', PSPEnumValueName(MemberPaymentMethod.PSP))
            .AddProperty('alias', MemberPaymentMethod."Payment Method Alias")
            .AddProperty('default', IsDefault)
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
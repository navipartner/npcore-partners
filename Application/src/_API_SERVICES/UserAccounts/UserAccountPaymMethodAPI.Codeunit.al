#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248418 "NPR UserAccountPaymMethodAPI"
{
    Access = Internal;

    internal procedure GetPaymentMethodsFromAccount(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        UserAccount: Record "NPR UserAccount";
        AccountIdTxt: Text;
        AccountId: Guid;
        Json: Codeunit "NPR Json Builder";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        if (not Request.Paths().Get(2, AccountIdTxt)) then
            exit(Response.RespondBadRequest('Missing required parameters: accountId'));
        if (not Evaluate(AccountId, AccountIdTxt)) then
            exit(Response.RespondBadRequest('Malformed parameter: accountId'));

        UserAccount.SetLoadFields(SystemId);
        UserAccount.ReadIsolation := IsolationLevel::ReadCommitted;
        UserAccount.SetRange(SystemId, AccountId);
        if (not UserAccount.FindFirst()) then
            exit(Response.RespondResourceNotFound(StrSubstNo('User account with id "%1" could not be found', AccountId)));

        MemberPaymentMethod.ReadIsolation := IsolationLevel::ReadCommitted;
        MemberPaymentMethod.SetRange("Table No.", UserAccount.RecordId().TableNo());
        MemberPaymentMethod.SetRange("BC Record ID", UserAccount.RecordId());

        Json.StartArray();
        if (MemberPaymentMethod.FindSet()) then
            repeat
                UserAccountPaymentMethodDTO(MemberPaymentMethod, false, Json);
            until MemberPaymentMethod.Next() = 0;
        Json.EndArray();

        exit(Response.RespondOK(Json.BuildAsArray()));
    end;

    internal procedure CreatePaymentMethodForAccount(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        UserAccount: Record "NPR UserAccount";
        AccountIdTxt: Text;
        AccountId: Guid;
        PSPAsString: Text;
        JHelper: Codeunit "NPR Json Helper";
        RequestBody: JsonToken;
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        TempMemberPaymentMethod: Record "NPR MM Member Payment Method" temporary;
        PaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
        IsModified: Boolean;
        Json: Codeunit "NPR Json Builder";
        MembershipArrayTok: JsonToken;
        MembershipIdTok: JsonToken;
        MembershipId: Guid;
        Membership: Record "NPR MM Membership";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        if (not Request.Paths().Get(2, AccountIdTxt)) then
            exit(Response.RespondBadRequest('Missing required parameters: accountId'));
        if (not Evaluate(AccountId, AccountIdTxt)) then
            exit(Response.RespondBadRequest('Malformed parameter: accountId'));

        UserAccount.SetLoadFields(SystemId);
        UserAccount.ReadIsolation := IsolationLevel::ReadCommitted;
        UserAccount.SetRange(SystemId, AccountId);
        if (not UserAccount.FindFirst()) then
            exit(Response.RespondResourceNotFound(StrSubstNo('User account with id "%1" could not be found', AccountId)));

        RequestBody := Request.BodyJson();

        PSPAsString := JHelper.GetJText(RequestBody, 'PSP', false);
        if PSPAsString <> '' then
            if not Enum::"NPR MM Subscription PSP".Names().Contains(PSPAsString) then
                exit(Response.RespondResourceNotFound(StrSubstNo('PSP %1', PSPAsString)));

        if PSPAsString <> '' then
            TempMemberPaymentMethod.PSP := Enum::"NPR MM Subscription PSP".FromInteger(Enum::"NPR MM Subscription PSP".Ordinals().Get(Enum::"NPR MM Subscription PSP".Names().IndexOf(PSPAsString)));
        TempMemberPaymentMethod."Payment Brand" := CopyStr(JHelper.GetJText(RequestBody, 'paymentBrand', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Brand"));
        TempMemberPaymentMethod."Payment Instrument Type" := CopyStr(JHelper.GetJText(RequestBody, 'paymentInstrument', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Instrument Type"));
        TempMemberPaymentMethod."Masked PAN" := CopyStr(JHelper.GetJText(RequestBody, 'maskedPAN', false), 1, MaxStrLen(TempMemberPaymentMethod."Masked PAN"));
        TempMemberPaymentMethod."PAN Last 4 Digits" := CopyStr(JHelper.GetJText(RequestBody, 'PANLastDigits', false), 1, MaxStrLen(TempMemberPaymentMethod."PAN Last 4 Digits"));
        TempMemberPaymentMethod."Expiry Date" := JHelper.GetJDate(RequestBody, 'expiryDate', false);
        TempMemberPaymentMethod."Payment Method Alias" := CopyStr(JHelper.GetJText(RequestBody, 'alias', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Method Alias"));
        TempMemberPaymentMethod."Shopper Reference" := CopyStr(JHelper.GetJText(RequestBody, 'shopperReference', false), 1, MaxStrLen(TempMemberPaymentMethod."Shopper Reference"));
        TempMemberPaymentMethod."Payment Token" := CopyStr(JHelper.GetJText(RequestBody, 'paymentToken', false), 1, MaxStrLen(TempMemberPaymentMethod."Payment Token"));

        if PaymentMethodMgt.FindPaymentMethod(TempMemberPaymentMethod."Payment Token", TempMemberPaymentMethod."Shopper Reference", TempMemberPaymentMethod.PSP, UserAccount, MemberPaymentMethod) then begin
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

        if (JHelper.GetJsonToken(RequestBody, 'membershipIds', MembershipArrayTok)) then begin
            Membership.ReadIsolation := IsolationLevel::ReadCommitted;
            Membership.SetLoadFields(SystemId);
            foreach MembershipIdTok in MembershipArrayTok.AsArray() do begin
                Evaluate(MembershipId, MembershipIdTok.AsValue().AsText());
                Membership.GetBySystemId(MembershipId); // ensure that membership exists
                if (not MembershipPmtMethodMap.Get(MemberPaymentMethod.SystemId, MembershipId)) then begin
                    MembershipPmtMethodMap.Init();
                    MembershipPmtMethodMap.MembershipId := MembershipId;
                    MembershipPmtMethodMap.PaymentMethodId := MemberPaymentMethod.SystemId;
                    MembershipPmtMethodMap.Status := "NPR MM Payment Method Status"::Active;
                    MembershipPmtMethodMap.Validate(Default, true);
                    MembershipPmtMethodMap.Insert();
                end else begin
                    MembershipPmtMethodMap.Status := "NPR MM Payment Method Status"::Active;
                    MembershipPmtMethodMap.Validate(Default, true);
                    MembershipPmtMethodMap.Modify();
                end;
            end;
        end;

        exit(Response.RespondCreated(UserAccountPaymentMethodDTO(MemberPaymentMethod, true, Json)));
    end;

    internal procedure UserAccountPaymentMethodDTO(PaymentMethod: Record "NPR MM Member Payment Method"; WithToken: Boolean; var Json: Codeunit "NPR Json Builder"): Codeunit "NPR Json Builder"
    var
        PmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
    begin
        Json.StartObject()
            .AddProperty('id', Format(PaymentMethod.SystemId, 0, 4).ToLower())
            .AddProperty('maskedPAN', PaymentMethod."Masked PAN")
            .AddProperty('PANLastDigits', PaymentMethod."PAN Last 4 Digits")
            .AddProperty('PSP', "NPR MM Subscription PSP".Names().Get("NPR MM Subscription PSP".Ordinals().IndexOf(PaymentMethod.PSP.AsInteger())))
            .AddProperty('alias', PaymentMethod."Payment Method Alias");

        if (PaymentMethod."Expiry Date" <> 0D) then
            Json.AddProperty('expiryDate', PaymentMethod."Expiry Date");

        Json.AddProperty('paymentBrand', PaymentMethod."Payment Brand")
            .AddProperty('paymentInstrument', PaymentMethod."Payment Instrument Type")
            .AddProperty('status', "NPR MM Payment Method Status".Names().Get("NPR MM Payment Method Status".Ordinals().IndexOf(PaymentMethod.Status.AsInteger())));
        if WithToken then
            Json
                .AddProperty('paymentToken', PaymentMethod."Payment Token")
                .AddProperty('shopperReference', PaymentMethod."Shopper Reference");

        Json.StartArray('memberships');

        PmtMethodMap.ReadIsolation := IsolationLevel::ReadCommitted;
        PmtMethodMap.SetRange(PaymentMethodId, PaymentMethod.SystemId);
        if (PmtMethodMap.FindSet()) then
            repeat
                Json.StartObject()
                        .AddProperty('membershipId', Format(PmtMethodMap.MembershipId, 0, 4).ToLower())
                        .AddProperty('status', "NPR MM Payment Method Status".Names().Get("NPR MM Payment Method Status".Ordinals().IndexOf(PmtMethodMap.Status.AsInteger())))
                        .AddProperty('default', PmtMethodMap.Default)
                    .EndObject();
            until PmtMethodMap.Next() = 0;

        Json.EndArray().EndObject();
        exit(Json);
    end;

    local procedure GetTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"NPR UserAccount");
        TableIds.Add(Database::"NPR MM Member Payment Method");
        TableIds.Add(Database::"NPR MM MembershipPmtMethodMap");
    end;
}
#endif
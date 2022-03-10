codeunit 6059810 "NPR Stripe Web Service"
{
    Access = Internal;

    internal procedure CreateCustomer(var StripeCustomer: Record "NPR Stripe Customer"): Boolean
    var
        TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary;
        RequestContent: HttpContent;
        RequestHeaders: HttpHeaders;
        HttpStatusCode: Integer;
        Response: JsonObject;
        CreateCustomerFailedErr: Label 'Creation of customer failed.';
    begin
        InitArguments(TempStripeRESTWSArgument, 'customers');
        TempStripeRESTWSArgument."Rest Method" := TempStripeRESTWSArgument."Rest Method"::post;

        RequestContent.WriteFrom(StripeCustomer.GetAsFormData());

        RequestContent.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');
        TempStripeRESTWSArgument.SetRequestContent(RequestContent);
        if not CallWebService(TempStripeRESTWSArgument, HttpStatusCode) then
            if not IsServerError(HttpStatusCode) then
                Error('%1\\%2', CreateCustomerFailedErr, TempStripeRESTWSArgument.GetResponseContentAsText())
            else
                exit(false);

        Response.ReadFrom(TempStripeRESTWSArgument.GetResponseContentAsText());
        StripeCustomer.PopulateFromJson(Response);
        StripeCustomer.Insert();
        exit(true);
    end;

    internal procedure UpdateCustomer(var StripeCustomer: Record "NPR Stripe Customer"): Boolean
    var
        TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary;
        RequestContent: HttpContent;
        RequestHeaders: HttpHeaders;
        HttpStatusCode: Integer;
        Response: JsonObject;
        CustomerIdLbl: Label 'customers/%1', Locked = true, Comment = '%1 = id';
        UpdateCustomerFailedErr: Label 'Update of customer failed.';
    begin
        InitArguments(TempStripeRESTWSArgument, StrSubstNo(CustomerIdLbl, StripeCustomer.Id));
        TempStripeRESTWSArgument."Rest Method" := TempStripeRESTWSArgument."Rest Method"::post;

        RequestContent.WriteFrom(StripeCustomer.GetAsFormData());

        RequestContent.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');
        TempStripeRESTWSArgument.SetRequestContent(RequestContent);
        if not CallWebService(TempStripeRESTWSArgument, HttpStatusCode) then
            if not IsServerError(HttpStatusCode) then
                Error('%1\\%2', UpdateCustomerFailedErr, TempStripeRESTWSArgument.GetResponseContentAsText())
            else
                exit(false);

        Response.ReadFrom(TempStripeRESTWSArgument.GetResponseContentAsText());
        StripeCustomer.PopulateFromJson(Response);
        StripeCustomer.Modify();
        exit(true);
    end;

    internal procedure CreateCustomerTax(StripeCustomer: Record "NPR Stripe Customer"; var StripeCustomerTax: Record "NPR Stripe Customer Tax"): Boolean
    var
        TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary;
        RequestContent: HttpContent;
        RequestHeaders: HttpHeaders;
        HttpStatusCode: Integer;
        Response: JsonObject;
        CreateCustomerTaxFailedErr: Label 'Creation of customer tax failed.';
        CustomerTaxLbl: Label 'customers/%1/tax_ids', Locked = true, Comment = 'Subscription Item Id';
    begin
        InitArguments(TempStripeRESTWSArgument, StrSubstNo(CustomerTaxLbl, StripeCustomer.Id));
        TempStripeRESTWSArgument."Rest Method" := TempStripeRESTWSArgument."Rest Method"::post;

        RequestContent.WriteFrom(StripeCustomerTax.GetFormDataForCreateCustomerTax(StripeCustomer));

        RequestContent.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');
        TempStripeRESTWSArgument.SetRequestContent(RequestContent);
        if not CallWebService(TempStripeRESTWSArgument, HttpStatusCode) then
            if not IsServerError(HttpStatusCode) then
                Error('%1\\%2', CreateCustomerTaxFailedErr, TempStripeRESTWSArgument.GetResponseContentAsText())
            else
                exit(false);

        Response.ReadFrom(TempStripeRESTWSArgument.GetResponseContentAsText());
        StripeCustomerTax.PopulateFromJson(Response);
        StripeCustomerTax.Insert();
        exit(true);
    end;

    internal procedure GetProducts(var StripeProduct: Record "NPR Stripe Product"): Boolean
    var
        TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary;
        HttpStatusCode: Integer;
        DataArray: JsonArray;
        Data: JsonObject;
        Response: JsonObject;
        JToken: JsonToken;
        GetProductsFailedErr: Label 'Could not get available products.';
    begin
        InitArguments(TempStripeRESTWSArgument, 'products');
        TempStripeRESTWSArgument."Rest Method" := TempStripeRESTWSArgument."Rest Method"::get;
        if not CallWebService(TempStripeRESTWSArgument, HttpStatusCode) then
            if not IsServerError(HttpStatusCode) then
                Error('%1\\%2', GetProductsFailedErr, TempStripeRESTWSArgument.GetResponseContentAsText())
            else
                exit(false);

        StripeProduct.Reset();
        StripeProduct.DeleteAll();

        Response.ReadFrom(TempStripeRESTWSArgument.GetResponseContentAsText());
        Response.Get('data', JToken);
        DataArray := JToken.AsArray();
        foreach JToken in DataArray do begin
            Data := JToken.AsObject();
            StripeProduct.Init();
            if StripeProduct.PopulateFromJson(Data) then
                StripeProduct.Insert();
        end;
        exit(true);
    end;

    internal procedure GetPlans(var StripePlan: Record "NPR Stripe Plan"): Boolean
    var
        StripePlanTier: Record "NPR Stripe Plan Tier";
        TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary;
        HttpStatusCode: Integer;
        DataArray: JsonArray;
        Data: JsonObject;
        Response: JsonObject;
        JToken: JsonToken;
        GetPlansFailedErr: Label 'Could not get available plans.';
    begin
        InitArguments(TempStripeRESTWSArgument, 'plans?expand[]=data.tiers');
        TempStripeRESTWSArgument."Rest Method" := TempStripeRESTWSArgument."Rest Method"::get;
        if not CallWebService(TempStripeRESTWSArgument, HttpStatusCode) then
            if not IsServerError(HttpStatusCode) then
                Error('%1\\%2', GetPlansFailedErr, TempStripeRESTWSArgument.GetResponseContentAsText())
            else
                exit(false);

        StripePlan.Reset();
        StripePlan.DeleteAll();
        StripePlanTier.DeleteAll();

        Response.ReadFrom(TempStripeRESTWSArgument.GetResponseContentAsText());
        Response.Get('data', JToken);
        DataArray := JToken.AsArray();
        foreach JToken in DataArray do begin
            Data := JToken.AsObject();
            StripePlan.Init();
            if StripePlan.PopulateFromJson(Data) then begin
                StripePlan.Insert();
                GetPlanTiers(StripePlan, JToken);
            end;
        end;
        exit(true);
    end;

    local procedure GetPlanTiers(StripePlan: Record "NPR Stripe Plan"; SourceJToken: JsonToken)
    var
        StripePlanTier: Record "NPR Stripe Plan Tier";
        OldUpTo: Integer;
        TierNo: Integer;
        DataArray: JsonArray;
        Data: JsonObject;
        JToken: JsonToken;
        Placeholder1Txt: Label '%1-%2 %3s', Comment = '%1 - placeholder 1, %2 - placeholder 2, %3 - Unit Name value';
        Placeholder2Txt: Label '%1+ %2s', Comment = '%1 - placeholder 1, %2 - Unit Name value';
        DeviceLbl: Label 'device';
        UnitName: Text[50];
    begin
        TierNo := 1;
        OldUpTo := 0;
        StripePlan.CalcFields("Unit Name");
        UnitName := StripePlan."Unit Name";
        if UnitName = '' then
            UnitName := DeviceLbl;

        SourceJToken.SelectToken('tiers', JToken);
        DataArray := JToken.AsArray();
        foreach JToken in DataArray do begin
            Data := JToken.AsObject();
            StripePlanTier.Init();
            StripePlanTier."Plan Id" := StripePlan.Id;
            StripePlanTier."Tier No." := TierNo;
            StripePlanTier.PopulateFromJson(Data);
            if StripePlanTier."Up To" <> 0 then
                StripePlanTier.Description := StrSubstNo(Placeholder1Txt, OldUpTo + 1, StripePlanTier."Up To", UnitName)
            else
                StripePlanTier.Description := StrSubstNo(Placeholder2Txt, OldUpTo + 1, UnitName);
            StripePlanTier.Insert();
            TierNo += 1;
            OldUpTo := StripePlanTier."Up To";
        end;
    end;

    internal procedure GetTaxRates(var StripeTaxRate: Record "NPR Stripe Tax Rate"): Boolean
    var
        TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary;
        HttpStatusCode: Integer;
        DataArray: JsonArray;
        Data: JsonObject;
        Response: JsonObject;
        JToken: JsonToken;
        GetTaxRatesFailedErr: Label 'Could not get available tax rates.';
    begin
        InitArguments(TempStripeRESTWSArgument, 'tax_rates');
        TempStripeRESTWSArgument."Rest Method" := TempStripeRESTWSArgument."Rest Method"::get;
        if not CallWebService(TempStripeRESTWSArgument, HttpStatusCode) then
            if not IsServerError(HttpStatusCode) then
                Error('%1\\%2', GetTaxRatesFailedErr, TempStripeRESTWSArgument.GetResponseContentAsText())
            else
                exit(false);

        StripeTaxRate.Reset();
        StripeTaxRate.DeleteAll();

        Response.ReadFrom(TempStripeRESTWSArgument.GetResponseContentAsText());
        Response.Get('data', JToken);
        DataArray := JToken.AsArray();
        foreach JToken in DataArray do begin
            Data := JToken.AsObject();
            StripeTaxRate.Init();
            StripeTaxRate.PopulateFromJson(Data);
            StripeTaxRate.Insert();
        end;
        exit(true);
    end;

    internal procedure CreateSubscription(StripeCustomer: Record "NPR Stripe Customer"; StripePlan: Record "NPR Stripe Plan"; var StripeSubscription: Record "NPR Stripe Subscription"; Trial: Boolean): Boolean
    var
        TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary;
        RequestContent: HttpContent;
        RequestHeaders: HttpHeaders;
        HttpStatusCode: Integer;
        Response: JsonObject;
        CreateSubscriptionFailedErr: Label 'Could not create subscription.';
    begin
        InitArguments(TempStripeRESTWSArgument, 'subscriptions');
        TempStripeRESTWSArgument."Rest Method" := TempStripeRESTWSArgument."Rest Method"::post;

        if Trial then
            RequestContent.WriteFrom(StripeSubscription.GetFormDataForCreateTrialSubscription(StripeCustomer, StripePlan))
        else
            RequestContent.WriteFrom(StripeSubscription.GetFormDataForCreateSubscription(StripeCustomer, StripePlan));

        RequestContent.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');
        TempStripeRESTWSArgument.SetRequestContent(RequestContent);
        if not CallWebService(TempStripeRESTWSArgument, HttpStatusCode) then
            if not IsServerError(HttpStatusCode) then
                Error('%1\\%2', CreateSubscriptionFailedErr, TempStripeRESTWSArgument.GetResponseContentAsText())
            else
                exit(false);

        Response.ReadFrom(TempStripeRESTWSArgument.GetResponseContentAsText());
        StripeSubscription.Init();
        StripeSubscription.PopulateFromJson(Response);
        StripeSubscription.Insert();
        exit(true);
    end;

    internal procedure UpdateSubscription(StripeCustomer: Record "NPR Stripe Customer"; StripePlan: Record "NPR Stripe Plan"; var StripeSubscription: Record "NPR Stripe Subscription"): Boolean
    var
        TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary;
        RequestContent: HttpContent;
        RequestHeaders: HttpHeaders;
        HttpStatusCode: Integer;
        Response: JsonObject;
        UpdateSubscriptionFailedErr: Label 'Could not update subscription.';
        SubscriptionIdLbl: Label 'subscriptions/%1', Locked = true, Comment = '%1 - Subscription Id';
    begin
        InitArguments(TempStripeRESTWSArgument, StrSubstNo(SubscriptionIdLbl, StripeSubscription.Id));
        TempStripeRESTWSArgument."Rest Method" := TempStripeRESTWSArgument."Rest Method"::post;

        RequestContent.WriteFrom(StripeSubscription.GetFormDataForUpdateSubscription(StripeCustomer, StripePlan));

        RequestContent.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');
        TempStripeRESTWSArgument.SetRequestContent(RequestContent);
        if not CallWebService(TempStripeRESTWSArgument, HttpStatusCode) then
            if not IsServerError(HttpStatusCode) then
                Error('%1\\%2', UpdateSubscriptionFailedErr, TempStripeRESTWSArgument.GetResponseContentAsText())
            else
                exit(false);

        Response.ReadFrom(TempStripeRESTWSArgument.GetResponseContentAsText());
        StripeSubscription.PopulateFromJson(Response);
        StripeSubscription.Modify();
        exit(true);
    end;

    internal procedure RefreshSubscription(var StripeSubscription: Record "NPR Stripe Subscription"): Boolean
    var
        TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary;
        HttpStatusCode: Integer;
        Response: JsonObject;
        GetSubscriptionFailedErr: Label 'Could not get subscription.';
        SubscriptionIdLbl: Label 'subscriptions/%1', Locked = true, Comment = '%1 - Subscription Id';
    begin
        InitArguments(TempStripeRESTWSArgument, StrSubstNo(SubscriptionIdLbl, StripeSubscription.Id));
        TempStripeRESTWSArgument."Rest Method" := TempStripeRESTWSArgument."Rest Method"::get;

        if not CallWebService(TempStripeRESTWSArgument, HttpStatusCode) then
            if not IsServerError(HttpStatusCode) then
                Error('%1\\%2', GetSubscriptionFailedErr, TempStripeRESTWSArgument.GetResponseContentAsText())
            else
                exit(false);

        Response.ReadFrom(TempStripeRESTWSArgument.GetResponseContentAsText());
        StripeSubscription.PopulateFromJson(Response);
        StripeSubscription.Modify();
        exit(true);
    end;

    internal procedure UpdateSubscriptionUsage(var StripeSubscription: Record "NPR Stripe Subscription"; Quantity: Integer): Boolean
    var
        TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary;
        RequestContent: HttpContent;
        RequestHeaders: HttpHeaders;
        HttpStatusCode: Integer;
        UpdateSubscriptionUsageFailedErr: Label 'Could not update subscription usage.';
        SubscriptionItemIdLbl: Label 'subscription_items/%1/usage_records', Locked = true, Comment = 'Subscription Item Id';
    begin
        InitArguments(TempStripeRESTWSArgument, StrSubstNo(SubscriptionItemIdLbl, StripeSubscription."Subscription Item Id"));
        TempStripeRESTWSArgument."Rest Method" := TempStripeRESTWSArgument."Rest Method"::post;

        RequestContent.WriteFrom(StripeSubscription.GetFormDataForUpdateSubscriptionUsage(Quantity, GetCurrUTCTimestamp()));

        RequestContent.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Content-Type');
        RequestHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');
        TempStripeRESTWSArgument.SetRequestContent(RequestContent);
        if not CallWebService(TempStripeRESTWSArgument, HttpStatusCode) then
            if not IsServerError(HttpStatusCode) then
                Error('%1\\%2', UpdateSubscriptionUsageFailedErr, TempStripeRESTWSArgument.GetResponseContentAsText())
            else
                exit(false);

        exit(true);
    end;

    internal procedure GetCustomerPortalURL(StripeCustomer: Record "NPR Stripe Customer"; var CustomerPortalURL: Text): Boolean
    var
        TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary;
        StripeJSONHelper: Codeunit "NPR Stripe JSON Helper";
        HttpStatusCode: Integer;
        Response: JsonObject;
        CustomerPortalIdLbl: Label 'billing_portal/sessions?customer=%1', Locked = true, Comment = '%1 - Customer Id';
        GetCustomerPortalURLFailedErr: Label 'Could not get your customer portal URL.';
    begin
        InitArguments(TempStripeRESTWSArgument, StrSubstNo(CustomerPortalIdLbl, StripeCustomer.Id));
        TempStripeRESTWSArgument."Rest Method" := TempStripeRESTWSArgument."Rest Method"::post;

        if not CallWebService(TempStripeRESTWSArgument, HttpStatusCode) then
            if not IsServerError(HttpStatusCode) then
                Error('%1\\%2', GetCustomerPortalURLFailedErr, TempStripeRESTWSArgument.GetResponseContentAsText())
            else
                exit(false);

        Response.ReadFrom(TempStripeRESTWSArgument.GetResponseContentAsText());
        CustomerPortalURL := StripeJSONHelper.GetJsonPropertyValueAsText(Response, 'url');
        exit(true);
    end;

    local procedure CallWebService(var TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary; var HttpStatusCode: Integer) Success: Boolean
    var
        StripeRESTWebService: Codeunit "NPR Stripe REST Web Service";
        Handled: Boolean;
    begin
        OnBeforeCallWebService(TempStripeRESTWSArgument, HttpStatusCode, Success, Handled);
        if Handled then
            exit(Success);

        Success := StripeRESTWebService.CallRESTWebService(TempStripeRESTWSArgument, HttpStatusCode);
    end;

    local procedure IsServerError(HttpStatusCode: Integer): Boolean
    begin
        exit(HttpStatusCode in [500 .. 511]);
    end;

    [NonDebuggable]
    local procedure InitArguments(var TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary; Method: Text)
    begin
        TempStripeRESTWSArgument.URL := GetBaseUrl() + Method;
        TempStripeRESTWSArgument.Username := CopyStr(GetSecretKey(), 1, MaxStrLen(TempStripeRESTWSArgument.Username));
    end;

    local procedure GetBaseUrl(): Text
    begin
        exit('https://api.stripe.com/v1/');
    end;

    [NonDebuggable]
    local procedure GetSecretKey(): Text
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        if EnvironmentInformation.IsOnPrem() then // this key is meant for testing purposes
            exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret('TestStripeSecretKey'));

        if EnvironmentInformation.IsSaaS() then
            exit(AzureKeyVaultMgt.GetAzureKeyVaultSecret('LiveStripeSecretKey'));
    end;

    local procedure GetCurrUTCTimestamp(): BigInteger
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        exit(Round((TypeHelper.GetCurrUTCDateTime() - CreateDateTime(DMY2Date(1, 1, 1970), 0T)) / 1000, 1));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCallWebService(var TempStripeRESTWSArgument: Record "NPR Stripe REST WS Argument" temporary; var HttpStatusCode: Integer; var Success: Boolean; var Handled: Boolean)
    begin
    end;
}
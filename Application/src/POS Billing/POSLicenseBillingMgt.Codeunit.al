#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248524 "NPR POS License Billing Mgt."
{
    Access = Internal;
    SingleInstance = true;

    // The POS_BILLING_INTEGRATION_DEV compiler symbol is used to switch between the production and development versions of the POS Billing API.
    // When this symbol is defined, the code will use the development API URL and a hardcoded tenant ID (the same is used in dev API) for testing purposes.
    // It also enables the feature automatically, bypassing the feature check.
    // This allows developers to test the integration without affecting the production environment.
    // To use it, define POS_BILL_ING_INTEGRATION_DEV in the 'preprocessorSymbols' setting in the 'app.json' file.

    var
        UserNotLicensedErr: Label 'You are not a licensed POS user. Please contact your administrator.';
        NotEnoughLicensesBuyMoreLicensesErr: Label 'Not enough licenses (%1 purchased for license type %2). Visit %3 to buy more.', Comment = '%1 = number of licensed sessions. %2 = License Type, %3 = License Portal Url';
        UserLicenseNotActiveErr: Label 'The license for user %1 is not active. Try to activate it or contact your administrator.';
        ApiResponseErr: Label 'License verification service returned an error (Status: %1). Please contact your administrator.';
        ApiCallFailedErr: Label 'Failed to send %1 request to API endpoint %2.', Comment = '%1 = HTTP method, %2 = endpoint';
        ApiResponseReadErr: Label 'Failed to read response content from API.';
        UnsupportedHttpErr: Label 'Unsupported HTTP method: %1', Comment = '%1 = HTTP method';
        CouldNotVerifyLicenseErr: Label 'Could not verify license information with the license server. Please try again later.';
        FailedToSyncTenantToRemoteErr: Label 'Failed to create tenant in the license system. Error: %1', Comment = '%1 = Error message';
        FailedToSyncEnvironmentToRemoteErr: Label 'Failed to create environment in the license system. Error: %1', Comment = '%1 = Error message';
        FailedToSyncCompanyToRemoteErr: Label 'Failed to create company in the license system. Error: %1', Comment = '%1 = Error message';
        FailedToSyncTenantEnvironmentCompanyErr: Label 'Failed to create tenant, environment or company in the license system. Error: %1', Comment = '%1 = Error message';
#if POS_BILLING_INTEGRATION_DEV
        PosBillingApiUrlTok: Label 'https://bc-pos-billing-api.npretail-prelive.app/api', Locked = true;
#else
        PosBillingApiUrlTok: Label 'https://bc-pos-billing-api.npretail.app/api', Locked = true;
#endif
        CustomerPortalAppUrlTok: Label 'TODO: Define the URL once we have it!', Locked = true;
        AkvNpPosBillingLicenseApiKeyTok: Label 'NpPosBillingLicenseApiKey', Locked = true;
        POSLicBillingAllowanceLoaded: Boolean;
        LicenseValidationDone: Boolean;
        TenantId: Text;
        ApiSecretToken: SecretText;
        HttpClient: HttpClient;
        IsHttpClientInitialized: Boolean;
        SyncTenantAttemptDone: Boolean;
        TenantSynced: Boolean;
        EnvironmentSynced: Boolean;
        CompanySynced: Boolean;

    [Obsolete('Switching from concurrent model to per-user model.', '2023-11-09')]
    procedure GetAllowedLicenses(): Integer
    begin
        exit(0);
    end;

    internal procedure GetCustomerPortalUrl(): Text
    begin
        exit(CustomerPortalAppUrlTok);
    end;

    internal procedure ForceSyncCurrentLicenseAllowanceFromApi(): Boolean
    begin
        POSLicBillingAllowanceLoaded := false;
        exit(SyncCurrentLicenseAllowanceFromApi());
    end;

    internal procedure OnActivateLicensedUser(var POSLicBillingUser: Record "NPR POS License Billing User")
    var
        POSLicBillingUser2: Record "NPR POS License Billing User";
        POSLicBillingAllowance: Record "NPR POS Lic. Billing Allowance";
        TempPOSLicBillingAllowance: Record "NPR POS Lic. Billing Allowance" temporary;
        LicenseTypeAllowances: Dictionary of [Integer, Integer];
        AllowedLicenses: Integer;
    begin
        POSLicBillingUser.TestField("License Type");

        if (not POSLicBillingAllowanceLoaded) then begin
            if (not GetCurrentLicenseAllowanceFromApi(TempPOSLicBillingAllowance)) then
                Error(CouldNotVerifyLicenseErr);

            PersistLicenseAllowance(TempPOSLicBillingAllowance);
            InvalidateLicensedUsers();
        end;

        POSLicBillingUser2.Reset();
        POSLicBillingUser2.SetCurrentKey("License Type", Status);
        POSLicBillingUser2.SetRange("License Type", POSLicBillingUser."License Type");
        POSLicBillingUser2.SetRange(Status, POSLicBillingUser2.Status::Active);

        LicenseTypeAllowances := GetAllowanceDictionaryPerLicenseType(POSLicBillingAllowance);

        if (not LicenseTypeAllowances.Get(POSLicBillingUser."License Type".AsInteger(), AllowedLicenses)) then
            AllowedLicenses := 0;

        if (POSLicBillingUser2.Count() >= AllowedLicenses) then
            Error(NotEnoughLicensesBuyMoreLicensesErr, AllowedLicenses, POSLicBillingUser."License Type", GetCustomerPortalUrl());
    end;

    internal procedure GetAllowanceDictionaryPerLicenseType(var SuccessfullySyncedFromPOSBillingAPI: Boolean): Dictionary of [Integer, Integer]
    var
        POSLicBillingAllowance: Record "NPR POS Lic. Billing Allowance";
    begin
        SuccessfullySyncedFromPOSBillingAPI := SyncCurrentLicenseAllowanceFromApi();
        Exit(GetAllowanceDictionaryPerLicenseType(POSLicBillingAllowance));
    end;

    internal procedure SyncTenantEnvironmentCompany(ShowErrorMessage: Boolean)
    var
        ErrorMsg: Text;
    begin
        if (not TrySyncTenantEnvironmentCompany()) then begin
            ErrorMsg := StrSubstNo(FailedToSyncTenantEnvironmentCompanyErr, GetLastErrorText());
            LogError(ErrorMsg, GetLastErrorCallStack());

            if ((GuiAllowed()) and (ShowErrorMessage)) then
                Message(ErrorMsg);
        end;
    end;

    [TryFunction()]
    local procedure TrySyncTenantEnvironmentCompany()
    begin
        SyncTenant();
        SyncEnvironment();
        SyncCompany();
    end;

    local procedure SyncTenant()
    begin
        if (not IsControlledEnvironment()) then
            exit;
        if (SyncTenantAttemptDone) then
            exit;

        InitGlobalVars();

        TenantSynced := TenantExists();
        if (not TenantSynced) then begin
            CreateTenant();
            TenantSynced := true;
        end;

        SyncTenantAttemptDone := true;
    end;

    local procedure TenantExists(): Boolean
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Endpoint: Text;
        RequestUri: Text;
        IsSent: Boolean;
    begin
        Endpoint := StrSubstNo('/tenants/%1', TenantId);
        RequestUri := BuildApiUrl(Endpoint);
        GetConfiguredHttpClient(Client);
        IsSent := Client.Get(RequestUri, Response);

        if (not IsSent) then
            Error(ApiCallFailedErr, "Http Method"::GET, Endpoint);

        if (Response.HttpStatusCode = 422) then
            exit(false);

        if (Response.IsSuccessStatusCode()) then
            exit(true);

        Error(ApiResponseErr, Response.HttpStatusCode);
    end;

    local procedure CreateTenant()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        JsonResponse: Codeunit "NPR Json Parser";
        RequestBody: JsonObject;
        TenantName: Text;
    begin
        TenantName := AzureADTenant.GetAadTenantDomainName();

        RequestBody.Add('id', TenantId);
        RequestBody.Add('name', TenantName);

        if (not ApiPost('/tenants', RequestBody, JsonResponse)) then
            Error(FailedToSyncTenantToRemoteErr, GetLastErrorText());
    end;

    local procedure SyncEnvironment()
    begin
        if (not IsControlledEnvironment()) then
            exit;
        if ((not TenantSynced) or (EnvironmentSynced)) then
            exit;

        InitGlobalVars();

        if (not EnvironmentExists()) then
            CreateEnvironment();

        EnvironmentSynced := true;
    end;

    local procedure EnvironmentExists(): Boolean
    var
        EnvInfo: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        Client: HttpClient;
        Response: HttpResponseMessage;
        Endpoint: Text;
        RequestUri: Text;
        EnvironmentName: Text;
        IsSent: Boolean;
    begin
        EnvironmentName := EnvInfo.GetEnvironmentName();

        Endpoint := StrSubstNo('/tenants/%1/environments/%2', TenantId, TypeHelper.UrlEncode(EnvironmentName));
        RequestUri := BuildApiUrl(Endpoint);
        GetConfiguredHttpClient(Client);
        IsSent := Client.Get(RequestUri, Response);

        if (not IsSent) then
            Error(ApiCallFailedErr, "Http Method"::GET, Endpoint);

        if (Response.HttpStatusCode = 422) then
            exit(false);

        if (Response.IsSuccessStatusCode()) then
            exit(true);

        Error(ApiResponseErr, Response.HttpStatusCode);
    end;

    local procedure CreateEnvironment()
    var
        EnvInfo: Codeunit "Environment Information";
        RequestBody: JsonObject;
        JsonResponse: Codeunit "NPR Json Parser";
        Endpoint: Text;
        EnvironmentName: Text;
    begin
        EnvironmentName := EnvInfo.GetEnvironmentName();

        Endpoint := StrSubstNo('/tenants/%1/environments', TenantId);

        RequestBody.Add('name', EnvironmentName);
        RequestBody.Add('status', 'active');

        if (not ApiPost(Endpoint, RequestBody, JsonResponse)) then
            Error(FailedToSyncEnvironmentToRemoteErr, GetLastErrorText());
    end;

    local procedure SyncCompany()
    begin
        if (not IsControlledEnvironment()) then
            exit;
        if ((not TenantSynced) or (not EnvironmentSynced) or (CompanySynced)) then
            exit;

        InitGlobalVars();

        if (not CompanyExists()) then
            CreateCompany();

        CompanySynced := true;
    end;

    local procedure CompanyExists(): Boolean
    var
        EnvInfo: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        Client: HttpClient;
        Response: HttpResponseMessage;
        Endpoint: Text;
        RequestUri: Text;
        EnvironmentName: Text;
        CompanyNameTxt: Text;
        IsSent: Boolean;
    begin
        EnvironmentName := EnvInfo.GetEnvironmentName();
        CompanyNameTxt := CompanyName();

        Endpoint := StrSubstNo('/tenants/%1/environments/%2/companies/%3',
            TenantId,
            TypeHelper.UrlEncode(EnvironmentName),
            TypeHelper.UrlEncode(CompanyNameTxt));
        RequestUri := BuildApiUrl(Endpoint);
        GetConfiguredHttpClient(Client);
        IsSent := Client.Get(RequestUri, Response);

        if (not IsSent) then
            Error(ApiCallFailedErr, "Http Method"::GET, Endpoint);

        if (Response.HttpStatusCode = 422) then
            exit(false);

        if (Response.IsSuccessStatusCode()) then
            exit(true);

        Error(ApiResponseErr, Response.HttpStatusCode);
    end;

    local procedure CreateCompany()
    var
        EnvInfo: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        RequestBody: JsonObject;
        JsonResponse: Codeunit "NPR Json Parser";
        Endpoint: Text;
        EnvironmentName: Text;
        CompanyNameTxt: Text;
    begin
        EnvironmentName := EnvInfo.GetEnvironmentName();
        CompanyNameTxt := CompanyName();

        Endpoint := StrSubstNo('/tenants/%1/environments/%2/companies',
            TenantId,
            TypeHelper.UrlEncode(EnvironmentName));

        RequestBody.Add('name', CompanyNameTxt);
        RequestBody.Add('status', 'active');

        if (not ApiPost(Endpoint, RequestBody, JsonResponse)) then
            Error(FailedToSyncCompanyToRemoteErr, GetLastErrorText());
    end;

    local procedure SyncCurrentLicenseAllowanceFromApi(): Boolean
    var
        TempPOSLicBillingAllowance: Record "NPR POS Lic. Billing Allowance" temporary;
    begin
        if (not GetCurrentLicenseAllowanceFromApi(TempPOSLicBillingAllowance)) then
            exit(false);

        PersistLicenseAllowance(TempPOSLicBillingAllowance);
        InvalidateLicensedUsers();

        exit(true);
    end;

    local procedure PersistLicenseAllowance(var POSLicBillingAllowanceTemp: Record "NPR POS Lic. Billing Allowance" temporary)
    var
        POSLicBillingAllowance: Record "NPR POS Lic. Billing Allowance";
        SyncRecord: Boolean;
    begin
        POSLicBillingAllowance.Reset();
        if (POSLicBillingAllowance.FindSet()) then
            repeat
                POSLicBillingAllowance.Mark(true);
            until (POSLicBillingAllowance.Next() = 0);


        POSLicBillingAllowance.Reset();
        if (POSLicBillingAllowance.FindSet()) then
            repeat
                SyncRecord := false;
                if (POSLicBillingAllowance.Get(POSLicBillingAllowanceTemp."Pool Id", POSLicBillingAllowanceTemp."License Type")) then begin
                    POSLicBillingAllowance.Mark(false);

                    if (POSLicBillingAllowance."Updated At" <> POSLicBillingAllowanceTemp."Updated At") then begin
                        SyncRecord := true;
                    end;
                end else begin
                    SyncRecord := true;
                end;

                if (SyncRecord) then begin
                    POSLicBillingAllowance.Init();
                    POSLicBillingAllowance.TransferFields(POSLicBillingAllowanceTemp, true);
                    if (not POSLicBillingAllowance.Insert()) then
                        POSLicBillingAllowance.Modify();
                end;
            until (POSLicBillingAllowanceTemp.Next() = 0);

        // Delete license allowances that are not valid anymore:
        POSLicBillingAllowance.MarkedOnly(true);
        POSLicBillingAllowance.DeleteAll();
        POSLicBillingAllowanceLoaded := true;
    end;

    local procedure InvalidateLicensedUsers()
    var
        POSLicBillingUser: Record "NPR POS License Billing User";
        POSLicBillingUser2: Record "NPR POS License Billing User";
        POSLicBillLicenseType: Enum "NPR POS Lic. Billing Lic. Type";
        POSLicBillingAllowance: Record "NPR POS Lic. Billing Allowance";
        POSLicBillLicenseTypeOrdinals: List of [Integer];
        POSLicBillLicenseTypeOrdinal: Integer;
        LicenseTypeAllowances: Dictionary of [Integer, Integer];
        LicenseTypeAllowance: Integer;
        LicenseAssignedUsers: Integer;
    begin
        POSLicBillingUser.Reset();
        POSLicBillingUser.SetCurrentKey("License Type", Status, "Status Changed At");
        POSLicBillingUser.SetRange(Status, POSLicBillingUser.Status::Active);

        LicenseTypeAllowances := GetAllowanceDictionaryPerLicenseType(POSLicBillingAllowance);
        POSLicBillLicenseTypeOrdinals := POSLicBillLicenseType.Ordinals();

        foreach POSLicBillLicenseTypeOrdinal in POSLicBillLicenseTypeOrdinals do begin
            POSLicBillingUser.SetRange("License Type", POSLicBillLicenseTypeOrdinal);

            if (not LicenseTypeAllowances.Get(POSLicBillLicenseTypeOrdinal, LicenseTypeAllowance)) then
                LicenseTypeAllowance := 0;

            LicenseAssignedUsers := 0;

            if (POSLicBillingUser.FindSet()) then
                repeat
                    LicenseAssignedUsers += 1;
                    if (LicenseAssignedUsers > LicenseTypeAllowance) then
                        POSLicBillingUser.Mark(true);
                until (POSLicBillingUser.Next() = 0);
        end;

        POSLicBillingUser.SetRange("License Type");
        POSLicBillingUser.MarkedOnly(true);

        if (POSLicBillingUser.FindSet()) then begin
            repeat
                POSLicBillingUser2 := POSLicBillingUser;
                POSLicBillingUser2.Validate(Status, POSLicBillingUser2.Status::SuspendedAutomatically);
                POSLicBillingUser2.Modify(true);
            until (POSLicBillingUser.Next() = 0);
        end;
    end;

    local procedure GetAllowanceDictionaryPerLicenseType(var POSLicBillingAllowance: Record "NPR POS Lic. Billing Allowance") Result: Dictionary of [Integer, Integer]
    var
        TotalLicenses: Integer;
    begin
        Clear(Result);

        POSLicBillingAllowance.Reset();
        if (not POSLicBillingAllowance.FindSet()) then
            exit(Result);

        repeat
            if Result.Get(POSLicBillingAllowance."License Type".AsInteger(), TotalLicenses) then
                Result.Set(POSLicBillingAllowance."License Type".AsInteger(), TotalLicenses + POSLicBillingAllowance."Total Licenses")
            else
                Result.Add(POSLicBillingAllowance."License Type".AsInteger(), POSLicBillingAllowance."Total Licenses");
        until (POSLicBillingAllowance.Next() = 0);

        exit(Result);
    end;

    local procedure GetCurrentLicenseAllowanceFromApi(var POSLicBillingAllowanceTemp: Record "NPR POS Lic. Billing Allowance" temporary): Boolean
    var
        JsonParser: Codeunit "NPR Json Parser";
        EnvInfo: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        Endpoint: Text;
        EnvironmentName: Text;
        CurrCompanyName: Text;
    begin
        InitGlobalVars();
        EnvironmentName := EnvInfo.GetEnvironmentName();
        CurrCompanyName := CompanyName();

        Endpoint := StrSubstNo('/tenants/%1/environments/%2/companies/%3/licenses/current',
            TenantId,
            TypeHelper.UrlEncode(EnvironmentName),
            TypeHelper.UrlEncode(CurrCompanyName));

        if (not ApiGet(Endpoint, JsonParser)) then begin
            LogError(StrSubstNo('SyncCurrentLicenseAllowance() error: %1', GetLastErrorText()), GetLastErrorCallStack());
            exit(false);
        end;

        exit(ParseLicenseAllowanceJsonToTable(JsonParser, POSLicBillingAllowanceTemp));
    end;

    [TryFunction]
    local procedure ParseLicenseAllowanceJsonToTable(var JsonParser: Codeunit "NPR Json Parser"; var POSLicBillingAllowanceTemp: Record "NPR POS Lic. Billing Allowance" temporary)
    var
        JsonParser2: Codeunit "NPR Json Parser";
        JsonPoolListOfJObjects: List of [JsonObject];
        JsonPoolListOfJObject: JsonObject;
        LicenseType: Text;
        LicenseStatus: Text;
    begin
        JsonParser
            .EnterArray('value')
                .GetValues(JsonPoolListOfJObjects)
            .ExitArray();

        foreach JsonPoolListOfJObject in JsonPoolListOfJObjects do begin
            Clear(JsonParser2);
            JsonParser2.Load(JsonPoolListOfJObject);

            POSLicBillingAllowanceTemp.Init();

            JsonParser2
                .EnterObject('pool')
#pragma warning disable AA0139
                    .GetProperty('id', POSLicBillingAllowanceTemp."Pool Id")
                    .GetProperty('licenseType', LicenseType)
                    .GetProperty('name', POSLicBillingAllowanceTemp.Name)
                    .GetProperty('totalLicenses', POSLicBillingAllowanceTemp."Total Licenses")
                    .GetProperty('tenantId', POSLicBillingAllowanceTemp."Tenant Id")
                    .GetProperty('environmentName', POSLicBillingAllowanceTemp."Environment Name")
                    .GetProperty('companyName', POSLicBillingAllowanceTemp."Company Name")
                    .GetProperty('status', LicenseStatus)
                    .GetProperty('renewalMonth', POSLicBillingAllowanceTemp."Renewal Month")
                    .GetProperty('renewalDay', POSLicBillingAllowanceTemp."Renewal Day")
                    .GetProperty('periodMonths', POSLicBillingAllowanceTemp."Period Months")
                    .GetProperty('validSince', POSLicBillingAllowanceTemp."Valid Since")
                    .GetProperty('validUntil', POSLicBillingAllowanceTemp."Valid Until")
                    .GetProperty('createdAt', POSLicBillingAllowanceTemp."Created At")
                    .GetProperty('updatedAt', POSLicBillingAllowanceTemp."Updated At")
#pragma warning restore AA0139
                .ExitObject();

            Evaluate(POSLicBillingAllowanceTemp."License Type", LicenseType);
            POSLicBillingAllowanceTemp.Validate("License Type");

            Evaluate(POSLicBillingAllowanceTemp.Status, LicenseStatus);
            POSLicBillingAllowanceTemp.Validate(Status);

            POSLicBillingAllowanceTemp.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Session", OnInitialize, '', false, false)]
    local procedure OnPOSSessionInitialize(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        ProceedLicenseValidationFromPOS();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS License Billing User", OnAfterValidateEvent, Status, false, false)]
    local procedure OnAfterValidateStatusEvent(var Rec: Record "NPR POS License Billing User"; var xRec: Record "NPR POS License Billing User")
    begin
        if (Rec.IsTemporary) then
            exit;

        if (Rec.Status <> xRec.Status) then begin
            case Rec.Status of
                Rec.Status::Active:
                    begin
                        OnActivateLicensedUser(Rec);
                    end;
            end;
        end;
    end;

    local procedure ProceedLicenseValidationFromPOS()
    var
        TempPOSLicBillingAllowance: Record "NPR POS Lic. Billing Allowance" temporary;
        POSLicBillingUser: Record "NPR POS License Billing User";
        RemoteValidationSuccessful: Boolean;
        UserIdentifier: Text;
    begin
        if (LicenseValidationDone) then
            exit;

        if (not IsPosLicenseBillingFeatureEnabled()) then begin
            LicenseValidationDone := true;
            exit;
        end;

        if ((IsControlledEnvironment()) and (not IsDelegatedUser(UserSecurityId()))) then begin
            InitGlobalVars();

            RemoteValidationSuccessful := GetCurrentLicenseAllowanceFromApi(TempPOSLicBillingAllowance);

            if (RemoteValidationSuccessful) then begin
                PersistLicenseAllowance(TempPOSLicBillingAllowance);
                InvalidateLicensedUsers();
            end;

            if (not POSLicBillingUser.Get(UserSecurityId())) then
                Error(UserNotLicensedErr);

            if (not (POSLicBillingUser.Status in [POSLicBillingUser.Status::Active])) then begin
                POSLicBillingUser.CalcFields("User Name");

                if (POSLicBillingUser."User Name" <> '') then
                    UserIdentifier := POSLicBillingUser."User Name"
                else
                    UserIdentifier := POSLicBillingUser."User Security ID";

                Error(UserLicenseNotActiveErr, UserIdentifier);
            end;

            UpdateLastLogin();
        end;

        LicenseValidationDone := true;
    end;

    local procedure IsPosLicenseBillingFeatureEnabled(): Boolean
    var
        POSLicenseBillingFeat: Codeunit "NPR POS License Billing Feat.";
    begin
#if POS_BILLING_INTEGRATION_DEV
        exit(true);
#endif
        exit(POSLicenseBillingFeat.IsFeatureEnabled());
    end;

    local procedure IsControlledEnvironment(): Boolean
    var
        EnvInfo: Codeunit "Environment Information";
    begin
#if POS_BILLING_INTEGRATION_DEV
        exit(true);
#endif
        if not EnvInfo.IsSaaSInfrastructure() then
            exit(false);

        if not EnvInfo.IsProduction() then
            exit(false);

        exit(true);
    end;

    local procedure InitGlobalVars()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvInfo: Codeunit "Environment Information";
    begin
        if (EnvInfo.IsSaaSInfrastructure()) then
            TenantId := AzureADTenant.GetAadTenantId();

#if POS_BILLING_INTEGRATION_DEV
        TenantId := '4386a841-4785-4918-a23f-a1eaaa5fa614';
#endif
        TenantId := DelChr(TenantId, '<>', '{}');
    end;

    local procedure UpdateLastLogin()
    var
        POSLicBillingUser: Record "NPR POS License Billing User";
        TypeHelper: Codeunit "Type Helper";
        CurrentDateTimeInUTC: DateTime;
        MarginDuration: Duration;
    begin
        CurrentDateTimeInUTC := TypeHelper.GetCurrUTCDateTime();
        MarginDuration := 5 * 60000; // Update max. every 5 minutes to avoid excessive writes e.g. for WS calls.

        if (POSLicBillingUser.Get(UserSecurityId())) then begin
            if (POSLicBillingUser."Last Login (DateTime)" < CurrentDateTimeInUTC - MarginDuration) then begin
                POSLicBillingUser."Last Login (DateTime)" := CurrentDateTimeInUTC;
                POSLicBillingUser.Modify(true);
            end;
        end;
    end;

    [TryFunction()]
    local procedure ApiGet(Endpoint: Text; var JsonResponse: Codeunit "NPR Json Parser")
    var
        Response: HttpResponseMessage;
    begin
        ExecuteApiRequest("Http Method"::GET, Endpoint, Response);
        HandleApiResponse(Response, JsonResponse);
    end;

    [TryFunction()]
    local procedure ApiPost(Endpoint: Text; RequestBody: JsonObject; var JsonResponse: Codeunit "NPR Json Parser")
    var
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        ContentText: Text;
    begin
        RequestBody.WriteTo(ContentText);
        Content.WriteFrom(ContentText);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        ExecuteApiRequest("Http Method"::POST, Endpoint, Content, Response);
        HandleApiResponse(Response, JsonResponse);
    end;

    local procedure ExecuteApiRequest(Method: Enum "Http Method"; Endpoint: Text; var Response: HttpResponseMessage)
    var
        NullContent: HttpContent;
    begin
        ExecuteApiRequest(Method, Endpoint, NullContent, Response);
    end;

    local procedure ExecuteApiRequest(Method: Enum "Http Method"; Endpoint: Text;
                                                  Content: HttpContent; var Response: HttpResponseMessage)
    var
        Client: HttpClient;
        RequestUri: Text;
        IsSent: Boolean;
    begin
        RequestUri := BuildApiUrl(Endpoint);
        GetConfiguredHttpClient(Client);

        case Method of
            Method::GET:
                IsSent := Client.Get(RequestUri, Response);
            Method::DELETE:
                IsSent := Client.Delete(RequestUri, Response);
            Method::POST:
                IsSent := Client.Post(RequestUri, Content, Response);
            Method::PUT:
                IsSent := Client.Put(RequestUri, Content, Response);
            Method::PATCH:
                IsSent := Client.Patch(RequestUri, Content, Response);
            else
                Error(UnsupportedHttpErr, Method);
        end;

        if (not IsSent) then
            Error(ApiCallFailedErr, Method, Endpoint);
    end;

    local procedure HandleApiResponse(var Response: HttpResponseMessage; var JsonResponse: Codeunit "NPR Json Parser")
    var
        JsonText: Text;
    begin
        case Response.HttpStatusCode of
            // 422 means e.g. missing tenant (but still valid URL) -> exit with 0 allowed licenses which will result in an error:
            422:
                exit;
            200, 201, 204:
                begin
                    if (Response.Content().ReadAs(JsonText)) then
                        JsonResponse.Parse(JsonText)
                    else if Response.HttpStatusCode <> 204 then
                        Error(ApiResponseReadErr);
                end;
            else
                Error(ApiResponseErr, Response.HttpStatusCode);
        end;
    end;

    local procedure BuildApiUrl(Endpoint: Text): Text
    begin
        if not Endpoint.StartsWith('/') then
            Endpoint := '/' + Endpoint;

        exit(PosBillingApiUrlTok + Endpoint);
    end;

    local procedure GetConfiguredHttpClient(var Client: HttpClient)
    begin
        if (not IsHttpClientInitialized) then begin
            HttpClient.Timeout(30000);
            HttpClient.DefaultRequestHeaders.Clear();
            HttpClient.DefaultRequestHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', GetAuthSecret()));
            IsHttpClientInitialized := true;
        end;

        Client := HttpClient;
    end;

    local procedure LogError(ErrorMsg: Text; ErrorCallStack: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
    begin
        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_TenantId', TenantId);
        CustomDimensions.Add('NPR_UserID', UserId);
        CustomDimensions.Add('NPR_UserSecurityId', UserSecurityId());
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");
        CustomDimensions.Add('NPR_Error_CallStack', ErrorCallStack);

        Session.LogMessage('NPR_POSLicenseApiError', ErrorMsg, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    [NonDebuggable]
    local procedure GetAuthSecret(): SecretText
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        if (ApiSecretToken.IsEmpty()) then begin
            ApiSecretToken := AzureKeyVaultMgt.GetAzureKeyVaultSecret(AkvNpPosBillingLicenseApiKeyTok);
        end;

        exit(ApiSecretToken);
    end;

    local procedure IsDelegatedUser(UserSecID: Guid): Boolean
    var
        EntraIDUserMgt: Codeunit "Azure AD User Management";
    begin
        // Not sure if testing for IsUserTenantAdmin() also makes sense or not.
        exit(EntraIDUserMgt.IsUserDelegated(UserSecID));
    end;
}
#endif
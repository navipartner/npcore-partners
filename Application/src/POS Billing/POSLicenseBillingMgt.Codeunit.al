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
        SessionsExceededErr: Label 'There are no available licenses to run the POS. Your environment has %1 available concurrent licenses which is/are all currently in use. Open page %2 to configure licensed users and visit %3 to buy more.',
            Comment = 'This error is shown when user tries to log in but the number of active sessions exceeds the allowed licenses number. %1 = number of licensed sessions. %1 = License Count, %2 = Page Caption, %3 = License Portal Url';
        LicensesNotConfiguredErr: Label 'No licenses configured for NP Retail POS in the remote license configuration system! Please contact your administrator.\ \Open page %1 to configure licensed users and visit %2 to buy more.\ \If you are testing, evaluating or developing then please switch to a sandbox environment instead where license checks are disabled.',
            Comment = 'This error is shown when there are no licenses configured for NP Retail POS in the remote license configuration system. %1 = Page Caption, %2 = License Portal Url';
        UserNotLicensedErr: Label 'You are not a licensed POS user. Please contact your administrator. Open page %1 to configure licensed users and visit %2 to buy more.', Comment = '%1 = Page Caption, %2 = License Portal Url';
        ApiResponseErr: Label 'License verification service returned an error (Status: %1). Please contact your administrator.';
#if POS_BILLING_INTEGRATION_DEV
        PosBillingApiUrlTok: Label 'https://bc-pos-billing-api.npretail-prelive.app/api', Locked = true;
#else
        PosBillingApiUrlTok: Label 'https://bc-pos-billing-api.npretail.app/api', Locked = true;
#endif
        CustomerPortalAppUrlTok: Label 'TODO: Define the URL once we have it!', Locked = true;
        AkvNpPosBillingLicenseApiKeyTok: Label 'NpPosBillingLicenseApiKey', Locked = true;
        LicenseValidationDone: Boolean;
        TenantId: Text;
        ApiSecretToken: SecretText;

    procedure GetAllowedLicenses(): Integer
    var
        AllowedLicenses: Integer;
    begin
        if (not IsPosLicenseBillingFeatureEnabled()) then
            exit(0);

        if ((IsControlledEnvironment()) and (not IsDelegatedUser(UserSecurityId()))) then begin

            InitGlobalVars();

            if (not CheckLicenseAvailability(AllowedLicenses)) then
                LogError(GetLastErrorText(), GetLastErrorCallStack());
        end;

        exit(AllowedLicenses);
    end;

    internal procedure GetCustomerPortalUrl(): Text
    begin
        exit(CustomerPortalAppUrlTok);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Session", OnInitialize, '', false, false)]
    local procedure OnPOSSessionInitialize(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        ProceedLicenseValidation();
    end;

    internal procedure ProceedLicenseValidation()
    begin
        ProceedSafeLicenseValidation();
    end;

    [TryFunction()]
    local procedure ProceedSafeLicenseValidation()
    var
        POSLicenseBillingUsers: Page "NPR POS License Billing Users";
        ActiveSessionsNumber: Integer;
        AllowedLicenses: Integer;
    begin
        if (LicenseValidationDone) then
            exit;

        if (not IsPosLicenseBillingFeatureEnabled()) then begin
            LicenseValidationDone := true;
            exit;
        end;

        if ((IsControlledEnvironment()) and (not IsDelegatedUser(UserSecurityId()))) then begin
            InitGlobalVars();

            if (not IsPosLicensedUser()) then
                Error(UserNotLicensedErr, POSLicenseBillingUsers.Caption, GetCustomerPortalUrl());

            ActiveSessionsNumber := GetNumberOfActiveSessions();

            if (not CheckLicenseAvailability(AllowedLicenses)) then begin
                LogError(GetLastErrorText(), GetLastErrorCallStack());
                // Maybe we might want to set LicenseValidationDone to true to avoid next checks if the API is down or not reachable etc.?
                exit;
            end;

            if (AllowedLicenses <= 0) then
                Error(LicensesNotConfiguredErr, POSLicenseBillingUsers.Caption, GetCustomerPortalUrl());

            if (ActiveSessionsNumber > AllowedLicenses) then
                Error(SessionsExceededErr, AllowedLicenses, POSLicenseBillingUsers.Caption, GetCustomerPortalUrl());

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
        //Tenant ID used by the dev API:
        TenantId := '4386a841-4785-4918-a23f-a1eaaa5fa614';
#endif
        TenantId := DelChr(TenantId, '<>', '{}');
    end;

    local procedure GetNumberOfActiveSessions(): Integer
    var
        ActiveSession: Record "Active Session";
        POSLicenseBillingUser: Record "NPR POS License Billing User";
        UniqueUsers: List of [Guid];
    begin
        // No locking but I am a bit afraid this might allow in edge cases access more users than allowed by our license ...
        ActiveSession.ReadIsolation := ActiveSession.ReadIsolation::ReadCommitted;

        ActiveSession.Reset();
        ActiveSession.SetFilter("Client Type", '<>%1&<>%2&<>%3',
            ActiveSession."Client Type"::NAS,
            ActiveSession."Client Type"::Background,
            ActiveSession."Client Type"::"Child Session");

        if (ActiveSession.FindSet()) then
            repeat
                if (POSLicenseBillingUser.Get(ActiveSession."User SID")) then
                    if (not UniqueUsers.Contains(ActiveSession."User SID")) then
                        UniqueUsers.Add(ActiveSession."User SID");
            until (ActiveSession.Next() = 0);

        // I think we don't need to check if the user isn't delegated at this stage
        // as we test against the licensed users list.
        // Putting delegated users there isn't needed as we skip the checks for them.
        if (POSLicenseBillingUser.Get(UserSecurityId())) then
            if (not UniqueUsers.Contains(UserSecurityId())) then begin
                UniqueUsers.Add(UserSecurityId());
            end;

        exit(UniqueUsers.Count());
    end;

    local procedure IsPosLicensedUser(): Boolean
    var
        POSLicenseBillingUser: Record "NPR POS License Billing User";
    begin
        exit(POSLicenseBillingUser.Get(UserSecurityId()));
    end;

    local procedure UpdateLastLogin()
    var
        POSLicenseBillingUser: Record "NPR POS License Billing User";
        TypeHelper: Codeunit "Type Helper";
        CurrentDateTimeInUTC: DateTime;
        MarginDuration: Duration;
    begin
        CurrentDateTimeInUTC := TypeHelper.GetCurrUTCDateTime();
        MarginDuration := 5 * 60000; // Update max. every 5 minutes to avoid excessive writes e.g. for WS calls.

        POSLicenseBillingUser.Get(UserSecurityId());
        if (POSLicenseBillingUser."Last Login (DateTime)" < CurrentDateTimeInUTC - MarginDuration) then begin
            POSLicenseBillingUser."Last Login (DateTime)" := CurrentDateTimeInUTC;
            POSLicenseBillingUser.Modify(true);
        end;
    end;

    [TryFunction()]
    local procedure CheckLicenseAvailability(var AllowedLicenses: Integer)
    begin
        Clear(AllowedLicenses);
        CallPosBillingApi(AllowedLicenses);
    end;

    [TryFunction()]
    local procedure CallPosBillingApi(var AllowedLicenses: Integer)
    var
        ResponseJson: Codeunit "NPR Json Parser";
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
        RequestURI: Text;
        Headers: HttpHeaders;
        JsonText: Text;
    begin
        Clear(ResponseJson);
        AllowedLicenses := 0;

        RequestURI := StrSubstNo('%1%2', PosBillingApiUrlTok, StrSubstNo('/tenants/%1/licenses', TenantId));

        Headers := HttpClient.DefaultRequestHeaders();
        Headers.Clear();
        Headers.Add('Authorization', SecretStrSubstNo('Bearer %1', GetAuthSecret()));

        // Let's set (a relatively short) timeout:
        HttpClient.Timeout(30000);
        HttpClient.Get(RequestURI, HttpResponse);

        if (not HttpResponse.IsSuccessStatusCode()) then begin
            case HttpResponse.HttpStatusCode of
                // 422 means e.g. missing tenant (but still valid URL) -> exit with 0 allowed licenses which will result in an error:
                422:
                    exit;
                else begin
                    // Now unexpected API errors, bypass the error. It will be logged and silently skipped by the client.
                    Error(ApiResponseErr, HttpResponse.HttpStatusCode);
                end;
            end;
        end;

        HttpResponse.Content().ReadAs(JsonText);
        ResponseJson.Parse(JsonText);

        AllowedLicenses := ParseLicenseResponse(ResponseJson);
    end;

    local procedure ParseLicenseResponse(ApiResponseJson: Codeunit "NPR Json Parser") AllowedLicenses: Integer
    var
        LicenseObjParser: Codeunit "NPR Json Parser";
        LicenseObjectList: List of [JsonObject];
        LicenseObjectListItem: JsonObject;
        PoolLicenses: Integer;
    begin
        Clear(AllowedLicenses);

        ApiResponseJson
            .EnterArray('pools')
            .GetValues(LicenseObjectList);

        foreach LicenseObjectListItem in LicenseObjectList do begin
            LicenseObjParser.Load(LicenseObjectListItem)
                .GetProperty('totalLicenses', PoolLicenses);

            AllowedLicenses += PoolLicenses;
        end;
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
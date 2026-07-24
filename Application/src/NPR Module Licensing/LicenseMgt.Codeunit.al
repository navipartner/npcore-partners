// Ported from the legacy "NPR POS License Billing Mgt." Changes vs. the original are limited to: multi-module
// keying (the new tables carry Module), the /api/v1 base URL, the parser reading `module`,
// the Status enum + raw "Status (API)" helper, current-period selection by date, and minimal renames
// (POS Billing / Allowance -> License / Pool where the model changed). Everything else mirrors the legacy logic.
codeunit 6248739 "NPR License Mgt."
{
    Access = Internal;
    SingleInstance = true;

    // The MODULE_LICENSING_INTEGRATION_DEV compiler symbol switches to the prelive API and forces the
    // controlled-environment + feature checks on, so the integration can be exercised from a sandbox.
    // (Kept as-is from the legacy module; rename to a licensing-specific symbol is on the follow-up list.)

    var
#if MODULE_LICENSING_INTEGRATION_DEV
        ApiBaseUrlTok: Label 'https://bc-pos-billing-api.npretail-prelive.app/api/v1', Locked = true;
        CustomerPortalAppUrlTok: Label 'https://customer-portal.npretail-prelive.app/', Locked = true;
#else
        ApiBaseUrlTok: Label 'https://bc-pos-billing-api.npretail.app/api/v1', Locked = true;
        CustomerPortalAppUrlTok: Label 'https://portal.navipartner.com', Locked = true;
#endif
        UserNotLicensedErr: Label 'You are not a licensed %1 user. Please contact your administrator.', Comment = '%1 = Module';
        NotEnoughLicensesBuyMoreLicensesErr: Label 'Not enough licenses to activate this user.\Module: %1\License term: %2\Licenses purchased: %3', Comment = '%1 = Module, %2 = License Term, %3 = number of purchased licenses';
        OpenCustomerPortalActionLbl: Label 'Open %1', Comment = '%1 = the Customer Portal product name (injected from the locked token below so it is never translated)';
        CustomerPortalNameTok: Label 'Customer Portal', Locked = true;
        UserLicenseNotActiveErr: Label 'The license for user %1 is not active. Try to activate it or contact your administrator.', Comment = '%1 = User';
        ApiResponseErr: Label 'License verification service returned an error (Status: %1). Please contact your administrator.', Comment = '%1 = HTTP status';
        ApiCallFailedErr: Label 'Failed to send %1 request to API endpoint %2.', Comment = '%1 = HTTP method, %2 = endpoint';
        ApiResponseReadErr: Label 'Failed to read response content from API.';
        UnsupportedHttpErr: Label 'Unsupported HTTP method: %1', Comment = '%1 = HTTP method';
        CouldNotVerifyLicenseErr: Label 'Could not verify license information with the license server. Please try again later.';
        PortalSyncProductionOnlyMsg: Label 'License pools are synced from the portal only in production environments.';
        PortalNoPoolDataMsg: Label 'The license service did not return license data for this tenant, environment, or company (it may not be registered yet).';
        FailedToSyncTenantToRemoteErr: Label 'Failed to create tenant in the license system. Error: %1', Comment = '%1 = Error message';
        FailedToSyncEnvironmentToRemoteErr: Label 'Failed to create environment in the license system. Error: %1', Comment = '%1 = Error message';
        FailedToSyncCompanyToRemoteErr: Label 'Failed to create company in the license system. Error: %1', Comment = '%1 = Error message';
        FailedToSyncTenantEnvironmentCompanyErr: Label 'Failed to create tenant, environment or company in the license system. Error: %1', Comment = '%1 = Error message';
        MalformedPoolDatesErr: Label 'ParsePoolsJsonToTable() pool %1: missing or unparseable validSince/validUntil.', Comment = '%1 = license pool id', Locked = true;
        AkvApiKeyTok: Label 'NpPosBillingLicenseApiKey', Locked = true;
        _PoolsLoaded: Boolean;
        _LicenseValidationDone: Boolean;
        _TenantId: Text;
        _ApiSecretToken: SecretText;
        _HttpClient: HttpClient;
        _IsHttpClientInitialized: Boolean;
        _SyncTenantAttemptDone: Boolean;
        _TenantSynced: Boolean;
        _EnvironmentSynced: Boolean;
        _CompanySynced: Boolean;
        _LastSyncFailureReason: Text;

    internal procedure GetCustomerPortalUrl(): Text
    begin
        exit(CustomerPortalAppUrlTok);
    end;

    procedure OpenCustomerPortal(ErrorInfo: ErrorInfo)
    begin
        HyperLink(GetCustomerPortalUrl());
    end;

    procedure SyncLicensePools(ForceRefresh: Boolean): Boolean
    begin
        if ForceRefresh then
            _PoolsLoaded := false;
        if _PoolsLoaded then
            exit(true);
        exit(SyncCurrentPoolsFromApi());
    end;

    internal procedure GetLastSyncFailureReason(): Text
    begin
        // Reason set by the most recent SyncLicensePools/SyncCurrentPoolsFromApi failure, surfaced to the
        // "Refresh from Portal" action so the admin gets a brief cause (HTTP status, not-in-production, or no data).
        exit(_LastSyncFailureReason);
    end;

    procedure ValidateUserLicense(Module: Enum "NPR License Module"; UserSecID: Guid): Boolean
    var
        LicenseUser: Record "NPR License User";
    begin
        if not LicenseUser.Get(UserSecID, Module) then
            exit(false);
        exit(LicenseUser.Status = LicenseUser.Status::Active);
    end;

    procedure ActivateUser(Module: Enum "NPR License Module"; UserSecID: Guid; LicenseTerm: Enum "NPR License Term")
    var
        LicenseUser: Record "NPR License User";
    begin
        if not LicenseUser.Get(UserSecID, Module) then begin
            LicenseUser.Init();
            LicenseUser.Validate("User Security ID", UserSecID);
            LicenseUser.Module := Module;
            LicenseUser.Insert(true);
        end;
        LicenseUser.Validate("License Term", LicenseTerm);
        LicenseUser.Validate(Status, LicenseUser.Status::Active); // triggers OnActivateLicensedUser (allowance guard)
        LicenseUser.Modify(true);
    end;

    procedure DeactivateUser(Module: Enum "NPR License Module"; UserSecID: Guid)
    var
        LicenseUser: Record "NPR License User";
    begin
        if not LicenseUser.Get(UserSecID, Module) then
            exit;
        LicenseUser.Validate(Status, LicenseUser.Status::DisabledManually);
        LicenseUser.Modify(true);
    end;

    internal procedure OnActivateLicensedUser(var LicenseUser: Record "NPR License User")
    var
        ActiveUser: Record "NPR License User";
        TempLicensePool: Record "NPR License Pool" temporary;
        Allowance: Dictionary of [Text, Integer];
        AllowedLicenses: Integer;
        ErrInfo: ErrorInfo;
    begin
        LicenseUser.TestField("License Term");

        // License enforcement is controlled-environment-only (mirrors ProceedLicenseValidationFromPOS). Outside a
        // controlled env (e.g. a SaaS sandbox) there is no portal to verify against, so activation is left
        // unrestricted instead of hitting the prod portal -> 422 -> a permanent "try again later".
        if not IsControlledEnvironment() then
            exit;

        if not _PoolsLoaded then begin
            if not GetCurrentPoolsFromApi(TempLicensePool) then
                Error(CouldNotVerifyLicenseErr);
            PersistPools(TempLicensePool);
            InvalidateLicensedUsers();
        end;

        ActiveUser.SetCurrentKey(Module, "License Term", Status);
        ActiveUser.SetRange(Module, LicenseUser.Module);
        ActiveUser.SetRange("License Term", LicenseUser."License Term");
        ActiveUser.SetRange(Status, ActiveUser.Status::Active);

        Allowance := GetAllowanceDictionary();
        if not Allowance.Get(ComboKeyOf(LicenseUser.Module, LicenseUser."License Term"), AllowedLicenses) then
            AllowedLicenses := 0;

        if ActiveUser.Count() >= AllowedLicenses then begin
            ErrInfo := ErrorInfo.Create(StrSubstNo(NotEnoughLicensesBuyMoreLicensesErr, LicenseUser.Module, LicenseUser."License Term", AllowedLicenses));
            ErrInfo.AddAction(StrSubstNo(OpenCustomerPortalActionLbl, CustomerPortalNameTok), Codeunit::"NPR License Mgt.", 'OpenCustomerPortal');
            Error(ErrInfo);
        end;
    end;

    internal procedure SyncTenantEnvironmentCompany(ShowErrorMessage: Boolean)
    var
        ErrorMsg: Text;
    begin
        if not TrySyncTenantEnvironmentCompany() then begin
            ErrorMsg := StrSubstNo(FailedToSyncTenantEnvironmentCompanyErr, GetLastErrorText());
            LogError(ErrorMsg, GetLastErrorCallStack());
            if GuiAllowed() and ShowErrorMessage then
                Message(ErrorMsg);
        end;
    end;

    [TryFunction]
    local procedure TrySyncTenantEnvironmentCompany()
    begin
        SyncTenant();
        SyncEnvironment();
        SyncCompany();
    end;

    local procedure SyncTenant()
    begin
        if not IsControlledEnvironment() then
            exit;
        if _SyncTenantAttemptDone then
            exit;

        InitGlobalVars();

        _TenantSynced := TenantExists();
        if not _TenantSynced then begin
            CreateTenant();
            _TenantSynced := true;
        end;

        _SyncTenantAttemptDone := true;
    end;

    local procedure TenantExists(): Boolean
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Endpoint: Text;
        IsSent: Boolean;
    begin
        Endpoint := StrSubstNo('/tenants/%1', _TenantId);
        GetConfiguredHttpClient(Client);
        IsSent := Client.Get(BuildApiUrl(Endpoint), Response);

        if not IsSent then
            Error(ApiCallFailedErr, "Http Method"::GET, Endpoint);
        if Response.HttpStatusCode = 422 then
            exit(false);
        if Response.IsSuccessStatusCode() then
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

        RequestBody.Add('id', _TenantId);
        RequestBody.Add('name', TenantName);

        if not ApiPost('/tenants', RequestBody, JsonResponse) then
            Error(FailedToSyncTenantToRemoteErr, GetLastErrorText());
    end;

    local procedure SyncEnvironment()
    begin
        if not IsControlledEnvironment() then
            exit;
        if (not _TenantSynced) or _EnvironmentSynced then
            exit;

        InitGlobalVars();

        if not EnvironmentExists() then
            CreateEnvironment();

        _EnvironmentSynced := true;
    end;

    local procedure EnvironmentExists(): Boolean
    var
        EnvInfo: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        Client: HttpClient;
        Response: HttpResponseMessage;
        Endpoint: Text;
        EnvironmentName: Text;
        IsSent: Boolean;
    begin
        EnvironmentName := EnvInfo.GetEnvironmentName();
        Endpoint := StrSubstNo('/tenants/%1/environments/%2', _TenantId, TypeHelper.UrlEncode(EnvironmentName));
        GetConfiguredHttpClient(Client);
        IsSent := Client.Get(BuildApiUrl(Endpoint), Response);

        if not IsSent then
            Error(ApiCallFailedErr, "Http Method"::GET, Endpoint);
        if Response.HttpStatusCode = 422 then
            exit(false);
        if Response.IsSuccessStatusCode() then
            exit(true);

        Error(ApiResponseErr, Response.HttpStatusCode);
    end;

    local procedure CreateEnvironment()
    var
        EnvInfo: Codeunit "Environment Information";
        RequestBody: JsonObject;
        JsonResponse: Codeunit "NPR Json Parser";
        Endpoint: Text;
    begin
        Endpoint := StrSubstNo('/tenants/%1/environments', _TenantId);

        RequestBody.Add('name', EnvInfo.GetEnvironmentName());
        RequestBody.Add('status', 'active');

        if not ApiPost(Endpoint, RequestBody, JsonResponse) then
            Error(FailedToSyncEnvironmentToRemoteErr, GetLastErrorText());
    end;

    local procedure SyncCompany()
    begin
        if not IsControlledEnvironment() then
            exit;
        if (not _TenantSynced) or (not _EnvironmentSynced) or _CompanySynced then
            exit;

        InitGlobalVars();

        if not CompanyExists() then
            CreateCompany();

        _CompanySynced := true;
    end;

    local procedure CompanyExists(): Boolean
    var
        EnvInfo: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        Client: HttpClient;
        Response: HttpResponseMessage;
        Endpoint: Text;
        EnvironmentName: Text;
        CompanyNameTxt: Text;
        IsSent: Boolean;
    begin
        EnvironmentName := EnvInfo.GetEnvironmentName();
        CompanyNameTxt := CompanyName();
        Endpoint := StrSubstNo('/tenants/%1/environments/%2/companies/%3',
            _TenantId,
            TypeHelper.UrlEncode(EnvironmentName),
            TypeHelper.UrlEncode(CompanyNameTxt));
        GetConfiguredHttpClient(Client);
        IsSent := Client.Get(BuildApiUrl(Endpoint), Response);

        if not IsSent then
            Error(ApiCallFailedErr, "Http Method"::GET, Endpoint);
        if Response.HttpStatusCode = 422 then
            exit(false);
        if Response.IsSuccessStatusCode() then
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
    begin
        EnvironmentName := EnvInfo.GetEnvironmentName();
        Endpoint := StrSubstNo('/tenants/%1/environments/%2/companies',
            _TenantId,
            TypeHelper.UrlEncode(EnvironmentName));

        RequestBody.Add('name', CompanyName());
        RequestBody.Add('status', 'active');

        if not ApiPost(Endpoint, RequestBody, JsonResponse) then
            Error(FailedToSyncCompanyToRemoteErr, GetLastErrorText());
    end;

    local procedure SyncCurrentPoolsFromApi(): Boolean
    var
        TempLicensePool: Record "NPR License Pool" temporary;
    begin
        Clear(_LastSyncFailureReason);
        if not IsControlledEnvironment() then begin
            _LastSyncFailureReason := PortalSyncProductionOnlyMsg;
            exit(false);
        end;
        if not GetCurrentPoolsFromApi(TempLicensePool) then // GetCurrentPoolsFromApi sets _LastSyncFailureReason
            exit(false);

        PersistPools(TempLicensePool);
        InvalidateLicensedUsers();
        ReportUsageToApi();
        exit(true);
    end;

    internal procedure PersistPools(var TempLicensePool: Record "NPR License Pool" temporary)
    var
        LicensePool: Record "NPR License Pool";
    begin
        // CROSS-REPO CONTRACT: "NPR License Pool" is DataPerCompany = false (env-wide within this BC database). The
        // portal projects pools per TENANT — the pool set and each Pool Id (bc-pos-api `periodPoolId(licenseId,
        // periodStart)`) are company-independent; the payload's companyName is echo-only and the cap varies per
        // ENVIRONMENT, not company. So this env-wide mark-and-sweep is idempotent across companies in the same
        // environment. If the portal ever keys a pool id or cap on company, this sweep would silently delete
        // cross-company rows — the two repos must stay in sync.
        LicensePool.Reset();
        if LicensePool.FindSet() then
            repeat
                LicensePool.Mark(true);
            until LicensePool.Next() = 0;

        TempLicensePool.Reset();
        if TempLicensePool.FindSet() then
            repeat
                if LicensePool.Get(TempLicensePool."Pool Id", TempLicensePool.Module, TempLicensePool."License Term") then begin
                    LicensePool.Mark(false);
                    if LicensePool."Updated At" <> TempLicensePool."Updated At" then begin
                        LicensePool.TransferFields(TempLicensePool, true);
                        LicensePool.Modify();
                    end;
                end else begin
                    LicensePool.Init();
                    LicensePool.TransferFields(TempLicensePool, true);
                    LicensePool.Insert();
                end;
            until TempLicensePool.Next() = 0;

        // Delete pools that are not valid anymore:
        LicensePool.MarkedOnly(true);
        LicensePool.DeleteAll();
        _PoolsLoaded := true;
    end;

    internal procedure InvalidateLicensedUsers()
    var
        LicenseUser: Record "NPR License User";
        LicenseUser2: Record "NPR License User";
        Allowance: Dictionary of [Text, Integer];
        AssignedCount: Integer;
        AllowedLicenses: Integer;
    begin
        Allowance := GetAllowanceDictionary();

        // Per (Module, License Term), keep the oldest activations within allowance and suspend the excess.
        LicenseUser.Reset();
        LicenseUser.SetCurrentKey(Module, "License Term", Status, "Status Changed At");
        LicenseUser.SetRange(Status, LicenseUser.Status::Active);
        if LicenseUser.FindSet() then
            repeat
                if (LicenseUser.Module <> LicenseUser2.Module) or (LicenseUser."License Term" <> LicenseUser2."License Term") then
                    AssignedCount := 0; // reset the running count when the (Module, License Term) group changes
                LicenseUser2 := LicenseUser;
                if not Allowance.Get(ComboKeyOf(LicenseUser.Module, LicenseUser."License Term"), AllowedLicenses) then
                    AllowedLicenses := 0;
                AssignedCount += 1;
                if AssignedCount > AllowedLicenses then
                    LicenseUser.Mark(true);
            until LicenseUser.Next() = 0;

        LicenseUser.SetRange(Status);
        LicenseUser.MarkedOnly(true);
        if LicenseUser.FindSet() then
            repeat
                LicenseUser2 := LicenseUser;
                LicenseUser2.Validate(Status, LicenseUser2.Status::SuspendedAutomatically);
                LicenseUser2.Modify(true);
            until LicenseUser.Next() = 0;

        // Bring auto-suspended users back into any freed headroom (most recent first).
        ReactivateWithinAllowance(Allowance);
    end;

    local procedure ReactivateWithinAllowance(Allowance: Dictionary of [Text, Integer])
    var
        Suspended: Record "NPR License User";
        ToActivate: Record "NPR License User";
        ActiveUser: Record "NPR License User";
        ComboKey: Text;
        PrevKey: Text;
        AllowedLicenses: Integer;
        Headroom: Integer;
    begin
        // Symmetric with the suspend pass: when a (Module, License Term) has fewer
        // active users than its allowance (pool grew, quota raised, or a transient
        // dip recovered), bring auto-suspended users back - MOST RECENTLY suspended
        // first - up to the headroom. DisabledManually is never touched. Direct
        // status writes bypass the activation guard (allowance is enforced here),
        // mirroring how the suspend pass writes without re-checking.
        Suspended.Reset();
        Suspended.SetCurrentKey(Module, "License Term", Status, "Status Changed At");
        Suspended.SetRange(Status, Suspended.Status::SuspendedAutomatically);
        Suspended.SetAscending("Status Changed At", false);
        PrevKey := '';
        Headroom := 0;
        if Suspended.FindSet() then
            repeat
                ComboKey := ComboKeyOf(Suspended.Module, Suspended."License Term");
                if ComboKey <> PrevKey then begin
                    PrevKey := ComboKey;
                    if not Allowance.Get(ComboKey, AllowedLicenses) then
                        AllowedLicenses := 0;
                    ActiveUser.Reset();
                    ActiveUser.SetRange(Module, Suspended.Module);
                    ActiveUser.SetRange("License Term", Suspended."License Term");
                    ActiveUser.SetRange(Status, ActiveUser.Status::Active);
                    Headroom := AllowedLicenses - ActiveUser.Count();
                end;
                if Headroom > 0 then begin
                    Suspended.Mark(true);
                    Headroom -= 1;
                end;
            until Suspended.Next() = 0;

        Suspended.SetRange(Status);
        Suspended.MarkedOnly(true);
        if Suspended.FindSet() then
            repeat
                ToActivate := Suspended;
                ToActivate.Status := ToActivate.Status::Active;
                ToActivate."Status Changed At" := CurrentDateTime();
                ToActivate."Activated At" := CurrentDateTime();
                ToActivate."Activated By" := UserSecurityId();
                ToActivate.Modify(false);
            until Suspended.Next() = 0;
    end;

    internal procedure BuildUsageArray(var UsageArray: JsonArray)
    var
        LicenseUser: Record "NPR License User";
        Counts: Dictionary of [Integer, Integer];
        Item: JsonObject;
        ModuleInt: Integer;
        Slug: Text;
        Seats: Integer;
    begin
        Clear(UsageArray);

        LicenseUser.SetRange(Status, LicenseUser.Status::Active);
        if LicenseUser.FindSet() then
            repeat
                ModuleInt := LicenseUser.Module.AsInteger();
                if Counts.ContainsKey(ModuleInt) then
                    Counts.Set(ModuleInt, Counts.Get(ModuleInt) + 1)
                else
                    Counts.Add(ModuleInt, 1);
            until LicenseUser.Next() = 0;

        // Emit every known module (not just those with users) so the portal can clear a module that dropped to zero.
        foreach ModuleInt in Enum::"NPR License Module".Ordinals() do begin
            Slug := ModuleSlugOf(ModuleInt);
            if Slug <> '' then begin
                if not Counts.Get(ModuleInt, Seats) then
                    Seats := 0;
                Clear(Item);
                Item.Add('module', Slug);
                Item.Add('activeSeats', Seats);
                UsageArray.Add(Item);
            end;
        end;
    end;

    local procedure ReportUsageToApi()
    var
        EnvInfo: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        JsonResponse: Codeunit "NPR Json Parser";
        Body: JsonObject;
        UsageArray: JsonArray;
        Endpoint: Text;
        EnvironmentName: Text;
        CompanyNameTxt: Text;
    begin
        // Advisory usage feed (INF-939): report active-assignment counts per module
        // to the portal, which drives the 'used vs quota' overview. Env-wide under
        // DataPerCompany=false, so the portal takes MAX across companies. Best-effort
        // - never fails the sync. Every known module is reported (incl. activeSeats 0)
        // so the portal can clear a module whose last active user was just deactivated.
        if not IsControlledEnvironment() then
            exit;
        InitGlobalVars();

        BuildUsageArray(UsageArray);

        EnvironmentName := EnvInfo.GetEnvironmentName();
        CompanyNameTxt := CompanyName();
        Body.Add('usage', UsageArray);
        Endpoint := StrSubstNo('/tenants/%1/environments/%2/companies/%3/usage',
            _TenantId,
            TypeHelper.UrlEncode(EnvironmentName),
            TypeHelper.UrlEncode(CompanyNameTxt));

        if not ApiPost(Endpoint, Body, JsonResponse) then
            LogError(StrSubstNo('ReportUsageToApi() error: %1', GetLastErrorText()), GetLastErrorCallStack());
    end;

    local procedure ModuleSlugOf(ModuleInt: Integer): Text
    var
        Module: Enum "NPR License Module";
    begin
        Module := Enum::"NPR License Module".FromInteger(ModuleInt);
        case Module of
            Module::POS:
                exit('pos');
            Module::KDS:
                exit('kds');
            Module::Scanner:
                exit('scanner');
        end;
        exit('');
    end;

    internal procedure GetAllowanceDictionary() Result: Dictionary of [Text, Integer]
    var
        LicensePool: Record "NPR License Pool";
        ComboKey: Text;
        Total: Integer;
    begin
        Clear(Result);
        LicensePool.Reset();
        LicensePool.SetRange(Status, LicensePool.Status::Active);
        SetCurrentPeriodFilter(LicensePool);

        LicensePool.SetLoadFields(Module, "License Term", "Total Licenses");
        if LicensePool.FindSet() then
            repeat
                ComboKey := ComboKeyOf(LicensePool.Module, LicensePool."License Term");
                if Result.Get(ComboKey, Total) then
                    Result.Set(ComboKey, Total + LicensePool."Total Licenses")
                else
                    Result.Add(ComboKey, LicensePool."Total Licenses");
            until LicensePool.Next() = 0;
    end;

    internal procedure GetLicenseStats(var TempLicenseStats: Record "NPR License Stats" temporary)
    var
        LicensePool: Record "NPR License Pool";
        LicenseUser: Record "NPR License User";
        EntryNo: Integer;
    begin
        TempLicenseStats.Reset();
        TempLicenseStats.DeleteAll();

        LicensePool.Reset();
        LicensePool.SetRange(Status, LicensePool.Status::Active);
        SetCurrentPeriodFilter(LicensePool);
        LicensePool.SetLoadFields(Module, "License Term", "Total Licenses");
        if LicensePool.FindSet() then
            repeat
                FindOrInitStats(TempLicenseStats, LicensePool.Module, LicensePool."License Term", EntryNo);
                TempLicenseStats."Total Licenses" += LicensePool."Total Licenses";
                TempLicenseStats.Modify();
            until LicensePool.Next() = 0;

        LicenseUser.SetRange(Status, LicenseUser.Status::Active);
        LicenseUser.SetLoadFields(Module, "License Term");
        if LicenseUser.FindSet() then
            repeat
                FindOrInitStats(TempLicenseStats, LicenseUser.Module, LicenseUser."License Term", EntryNo);
                TempLicenseStats."Used Licenses" += 1;
                TempLicenseStats.Modify();
            until LicenseUser.Next() = 0;

        TempLicenseStats.Reset();
        if TempLicenseStats.FindSet() then
            repeat
                TempLicenseStats.Remaining := TempLicenseStats."Total Licenses" - TempLicenseStats."Used Licenses";
                if TempLicenseStats."Total Licenses" > 0 then
                    TempLicenseStats."Usage %" := Round(TempLicenseStats."Used Licenses" / TempLicenseStats."Total Licenses" * 100, 0.1);
                TempLicenseStats.Modify();
            until TempLicenseStats.Next() = 0;
    end;

    local procedure FindOrInitStats(var TempLicenseStats: Record "NPR License Stats" temporary; Module: Enum "NPR License Module"; LicenseTerm: Enum "NPR License Term"; var EntryNo: Integer)
    begin
        TempLicenseStats.Reset();
        TempLicenseStats.SetRange(Module, Module);
        TempLicenseStats.SetRange("License Term", LicenseTerm);
        if TempLicenseStats.FindFirst() then
            exit;
        EntryNo += 1;
        TempLicenseStats.Init();
        TempLicenseStats."Entry No." := EntryNo;
        TempLicenseStats.Module := Module;
        TempLicenseStats."License Term" := LicenseTerm;
        TempLicenseStats.Insert();
    end;

    local procedure GetCurrentPoolsFromApi(var TempLicensePool: Record "NPR License Pool" temporary): Boolean
    var
        JsonParser: Codeunit "NPR Json Parser";
        EnvInfo: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        Endpoint: Text;
        EnvironmentName: Text;
        CompanyNameTxt: Text;
    begin
        InitGlobalVars();

        EnvironmentName := EnvInfo.GetEnvironmentName();
        CompanyNameTxt := CompanyName();
        Endpoint := StrSubstNo('/tenants/%1/environments/%2/companies/%3/licenses/current',
            _TenantId,
            TypeHelper.UrlEncode(EnvironmentName),
            TypeHelper.UrlEncode(CompanyNameTxt));

        if not ApiGet(Endpoint, JsonParser) then begin
            _LastSyncFailureReason := GetLastErrorText(); // user-facing API error - includes the HTTP status
            LogError(StrSubstNo('GetCurrentPoolsFromApi() error: %1', GetLastErrorText()), GetLastErrorCallStack());
            exit(false);
        end;

        if not ParsePoolsJsonToTable(JsonParser, TempLicensePool) then begin
            // False here means either an unregistered tenant/env/company (the tolerated 422 leaves the parser empty,
            // so EnterArray('value') throws) or a genuinely malformed response - both leave the local pool cache
            // untouched (no PersistPools), which is the safe outcome. Distinguishing the two is a deferred follow-up.
            _LastSyncFailureReason := PortalNoPoolDataMsg;
            LogError(StrSubstNo('GetCurrentPoolsFromApi() returned no usable pool data (unregistered tenant/env/company or malformed response): %1', GetLastErrorText()), GetLastErrorCallStack());
            exit(false);
        end;
        exit(true);
    end;

    internal procedure ParsePoolsJsonToTemp(JsonText: Text; var TempLicensePool: Record "NPR License Pool" temporary): Boolean
    var
        JsonParser: Codeunit "NPR Json Parser";
    begin
        JsonParser.Parse(JsonText);
        exit(ParsePoolsJsonToTable(JsonParser, TempLicensePool));
    end;

    [TryFunction]
    local procedure ParsePoolsJsonToTable(var JsonParser: Codeunit "NPR Json Parser"; var TempLicensePool: Record "NPR License Pool" temporary)
    var
        JsonPoolParser: Codeunit "NPR Json Parser";
        JsonPools: List of [JsonObject];
        JsonPool: JsonObject;
        ModuleSlug: Text;
        LicenseTypeCode: Text;
        LicenseStatus: Text;
        ParsedType: Enum "NPR License Term";
        HasValidSince: Boolean;
        HasValidUntil: Boolean;
    begin
        JsonParser
            .EnterArray('value')
                .GetValues(JsonPools)
            .ExitArray();

        foreach JsonPool in JsonPools do begin
            Clear(JsonPoolParser);
            JsonPoolParser.Load(JsonPool);

            TempLicensePool.Init();
            Clear(ModuleSlug);
            Clear(LicenseTypeCode);
            Clear(LicenseStatus);

            JsonPoolParser
                .EnterObject('pool')
#pragma warning disable AA0139
                    .GetProperty('id', TempLicensePool."Pool Id")
                    .GetProperty('module', ModuleSlug)
                    .GetProperty('licenseType', LicenseTypeCode)
                    .GetProperty('name', TempLicensePool.Name)
                    .GetProperty('totalLicenses', TempLicensePool."Total Licenses")
                    .GetProperty('tenantId', TempLicensePool."Tenant Id")
                    .GetProperty('environmentName', TempLicensePool."Environment Name")
                    .GetProperty('companyName', TempLicensePool."Company Name")
                    .GetProperty('status', LicenseStatus)
                    .GetProperty('renewalMonth', TempLicensePool."Renewal Month")
                    .GetProperty('renewalDay', TempLicensePool."Renewal Day")
                    .GetProperty('periodMonths', TempLicensePool."Period Months")
                    .GetProperty('validSince', TempLicensePool."Valid Since Date", HasValidSince)
                    .GetProperty('validUntil', TempLicensePool."Valid Until Date", HasValidUntil)
                    .GetProperty('createdAt', TempLicensePool."Created At")
                    .GetProperty('updatedAt', TempLicensePool."Updated At")
#pragma warning restore AA0139
                .ExitObject();

            // Module and License Term are PK parts: an unmappable value can't be stored/gated -> skip the pool (logged
            // so a term/module the portal emits but BC does not model is observable, not a silent allowance shortfall).
            if not TryMapModule(ModuleSlug, TempLicensePool) then begin
                LogError(StrSubstNo('ParsePoolsJsonToTable() skipped pool %1: unmappable module ''%2'' (portal returned a module we do not model).', Format(TempLicensePool."Pool Id"), ModuleSlug), '');
                continue;
            end;
            if not Evaluate(ParsedType, LicenseTypeCode) then begin
                LogError(StrSubstNo('ParsePoolsJsonToTable() skipped pool %1: unmappable licenseType ''%2'' (portal returned a term we do not model).', Format(TempLicensePool."Pool Id"), LicenseTypeCode), '');
                continue;
            end;
            if ParsedType = ParsedType::_ then begin
                LogError(StrSubstNo('ParsePoolsJsonToTable() skipped pool %1: empty licenseType.', Format(TempLicensePool."Pool Id")), '');
                continue;
            end;
            TempLicensePool."License Term" := ParsedType;

            if not (HasValidSince and HasValidUntil) then
                Error(MalformedPoolDatesErr, Format(TempLicensePool."Pool Id"));

            // Status is descriptive (non-key): keep the row, raw value in helper, enum falls back to empty.
            TempLicensePool."Status (API)" := CopyStr(LicenseStatus, 1, MaxStrLen(TempLicensePool."Status (API)"));
            MapPoolStatus(LicenseStatus, TempLicensePool);

            TempLicensePool.Insert(true);
        end;
    end;

    local procedure TryMapModule(ModuleSlug: Text; var TempLicensePool: Record "NPR License Pool" temporary): Boolean
    begin
        case LowerCase(ModuleSlug) of
            'pos':
                TempLicensePool.Module := TempLicensePool.Module::POS;
            'kds':
                TempLicensePool.Module := TempLicensePool.Module::KDS;
            'scanner':
                TempLicensePool.Module := TempLicensePool.Module::Scanner;
            else
                exit(false);
        end;
        exit(true);
    end;

    local procedure MapPoolStatus(StatusText: Text; var TempLicensePool: Record "NPR License Pool" temporary)
    begin
        case LowerCase(StatusText) of
            'active':
                TempLicensePool.Status := TempLicensePool.Status::Active;
            else
                TempLicensePool.Status := TempLicensePool.Status::_;
        end;
    end;

    local procedure SetCurrentPeriodFilter(var LicensePool: Record "NPR License Pool")
    begin
        // Effectiveness is decided by BC's own date against the pool's validity window (validSince/validUntil).
        LicensePool.SetFilter("Valid Since Date", '<=%1', Today());
        LicensePool.SetFilter("Valid Until Date", '>=%1', Today());
    end;

    local procedure ComboKeyOf(Module: Enum "NPR License Module"; LicenseTerm: Enum "NPR License Term"): Text
    begin
        exit(StrSubstNo('%1|%2', Module.AsInteger(), LicenseTerm.AsInteger()));
    end;

    // ----------------------------------------------------------------- POS license gate (ported, validates the POS module)

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Session", OnInitialize, '', false, false)]
    local procedure OnPOSSessionInitialize(FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        ProceedLicenseValidationFromPOS();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR License User", OnAfterValidateEvent, Status, false, false)]
    local procedure OnAfterValidateStatusEvent(var Rec: Record "NPR License User"; var xRec: Record "NPR License User")
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec.Status <> xRec.Status then
            case Rec.Status of
                Rec.Status::Active:
                    OnActivateLicensedUser(Rec);
            end;
    end;

    local procedure ProceedLicenseValidationFromPOS()
    var
        LicenseUser: Record "NPR License User";
        TempLicensePool: Record "NPR License Pool" temporary;
        RemoteValidationSuccessful: Boolean;
        UserIdentifier: Text;
    begin
        if _LicenseValidationDone then
            exit;

        if not IsFeatureEnabled() then begin
            _LicenseValidationDone := true;
            exit;
        end;

        if IsControlledEnvironment() and not IsDelegatedUser(UserSecurityId()) then begin
            InitGlobalVars();

            RemoteValidationSuccessful := GetCurrentPoolsFromApi(TempLicensePool);
            if RemoteValidationSuccessful then begin
                PersistPools(TempLicensePool);
                InvalidateLicensedUsers();
            end;

            if not LicenseUser.Get(UserSecurityId(), LicenseUser.Module::POS) then
                Error(UserNotLicensedErr, LicenseUser.Module::POS);

            if not (LicenseUser.Status in [LicenseUser.Status::Active]) then begin
                LicenseUser.CalcFields("User Name");
                if LicenseUser."User Name" <> '' then
                    UserIdentifier := LicenseUser."User Name"
                else
                    UserIdentifier := Format(LicenseUser."User Security ID");
                Error(UserLicenseNotActiveErr, UserIdentifier);
            end;

            UpdateLastLogin(LicenseUser.Module::POS);
        end;

        // Set only after the gate passes, so a blocked user can't slip in on a retry. Trade-off: repeated
        // retries re-hit the portal — could cache the remote sync separately if performance troubles occur.
        _LicenseValidationDone := true;
    end;

    local procedure IsFeatureEnabled(): Boolean
    var
        ModuleLicensingFeat: Codeunit "NPR Module Licensing Feat.";
        Result: Boolean;
    begin
        Result := false;
#if MODULE_LICENSING_INTEGRATION_DEV
        Result := true;
        ModuleLicensingFeat := ModuleLicensingFeat;
#else
        Result := ModuleLicensingFeat.IsFeatureEnabled();
#endif
        exit(Result);
    end;

    internal procedure IsControlledEnvironment(): Boolean
    var
        EnvInfo: Codeunit "Environment Information";
        Result: Boolean;
    begin
        Result := false;
#if MODULE_LICENSING_INTEGRATION_DEV
        Result := true;
        EnvInfo := EnvInfo;
#else
        if EnvInfo.IsSaaSInfrastructure() then
            if EnvInfo.IsProduction() then
                Result := true;
#endif
        exit(Result);
    end;

    [TryFunction]
    internal procedure IsPortalApiAccessible()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        InitGlobalVars();
        GetConfiguredHttpClient(Client);
        if not Client.Get(BuildApiUrl(StrSubstNo('/tenants/%1', _TenantId)), Response) then
            Error(ApiResponseErr, 0);
        if not (Response.IsSuccessStatusCode() or (Response.HttpStatusCode = 422)) then
            Error(ApiResponseErr, Response.HttpStatusCode);
    end;

    local procedure InitGlobalVars()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvInfo: Codeunit "Environment Information";
    begin
        if EnvInfo.IsSaaSInfrastructure() then
            _TenantId := AzureADTenant.GetAadTenantId();
        _TenantId := DelChr(_TenantId, '<>', '{}');
    end;

    local procedure UpdateLastLogin(Module: Enum "NPR License Module")
    var
        LicenseUser: Record "NPR License User";
        TypeHelper: Codeunit "Type Helper";
        CurrentDateTimeInUTC: DateTime;
        MarginDuration: Duration;
    begin
        CurrentDateTimeInUTC := TypeHelper.GetCurrUTCDateTime();
        MarginDuration := 5 * 60000; // Update max. every 5 minutes to avoid excessive writes (e.g. for WS calls).

        if LicenseUser.Get(UserSecurityId(), Module) then
            if LicenseUser."Last Login (DateTime)" < CurrentDateTimeInUTC - MarginDuration then begin
                LicenseUser."Last Login (DateTime)" := CurrentDateTimeInUTC;
                LicenseUser.Modify(true);
            end;
    end;

    [TryFunction]
    local procedure ApiGet(Endpoint: Text; var JsonResponse: Codeunit "NPR Json Parser")
    var
        Response: HttpResponseMessage;
    begin
        ExecuteApiRequest("Http Method"::GET, Endpoint, Response);
        HandleApiResponse(Response, JsonResponse, true);
    end;

    [TryFunction]
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
        HandleApiResponse(Response, JsonResponse, false);
    end;

    local procedure ExecuteApiRequest(Method: Enum "Http Method"; Endpoint: Text; var Response: HttpResponseMessage)
    var
        NullContent: HttpContent;
    begin
        ExecuteApiRequest(Method, Endpoint, NullContent, Response);
    end;

    local procedure ExecuteApiRequest(Method: Enum "Http Method"; Endpoint: Text; Content: HttpContent; var Response: HttpResponseMessage)
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

        if not IsSent then
            Error(ApiCallFailedErr, Method, Endpoint);
    end;

    local procedure HandleApiResponse(var Response: HttpResponseMessage; var JsonResponse: Codeunit "NPR Json Parser"; Tolerate422: Boolean)
    var
        JsonText: Text;
    begin
        case Response.HttpStatusCode of
            // 422 (e.g. missing tenant) is a valid "no data" for the pools GET; for POST creates it is a real
            // rejection that must surface, so only the GET caller tolerates it.
            422:
                if Tolerate422 then
                    exit
                else
                    Error(ApiResponseErr, Response.HttpStatusCode);
            200, 201, 204:
                if Response.Content().ReadAs(JsonText) then
                    JsonResponse.Parse(JsonText)
                else
                    if Response.HttpStatusCode <> 204 then
                        Error(ApiResponseReadErr);
            else
                Error(ApiResponseErr, Response.HttpStatusCode);
        end;
    end;

    local procedure BuildApiUrl(Endpoint: Text): Text
    begin
        if not Endpoint.StartsWith('/') then
            Endpoint := '/' + Endpoint;
        exit(ApiBaseUrlTok + Endpoint);
    end;

    local procedure GetConfiguredHttpClient(var Client: HttpClient)
    begin
        if not _IsHttpClientInitialized then begin
            _HttpClient.Timeout(5000);
            _HttpClient.DefaultRequestHeaders.Clear();
            _HttpClient.DefaultRequestHeaders.Add('Authorization', SecretStrSubstNo('Bearer %1', GetAuthSecret()));
            _IsHttpClientInitialized := true;
        end;
        Client := _HttpClient;
    end;

    local procedure LogError(ErrorMsg: Text; ErrorCallStack: Text)
    var
        ActiveSession: Record "Active Session";
        CustomDimensions: Dictionary of [Text, Text];
    begin
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_TenantId', _TenantId);
        CustomDimensions.Add('NPR_UserID', UserId());
        CustomDimensions.Add('NPR_UserSecurityId', UserSecurityId());
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");
        CustomDimensions.Add('NPR_Error_CallStack', ErrorCallStack);

        Session.LogMessage('NPR_LicenseApiError', ErrorMsg, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    [NonDebuggable]
    local procedure GetAuthSecret(): SecretText
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        if _ApiSecretToken.IsEmpty() then
            _ApiSecretToken := AzureKeyVaultMgt.GetAzureKeyVaultSecret(AkvApiKeyTok);
        exit(_ApiSecretToken);
    end;

    local procedure IsDelegatedUser(UserSecID: Guid): Boolean
    var
        EntraIDUserMgt: Codeunit "Azure AD User Management";
    begin
        exit(EntraIDUserMgt.IsUserDelegated(UserSecID));
    end;
}

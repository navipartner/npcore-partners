codeunit 6014590 "NPR Service Tier User Mgt."
{
    Access = Internal;

    var
        ClientDiagnostic: Record "NPR Client Diagnostic v2";
        Initialized: Boolean;

#if BC17 or BC18 or BC19
    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeLogInStart', '', true, false)]
    local procedure HandleOnBeforeLogInStart()
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', false, false)]
    local procedure OnAfterLogin();
#endif
    var
        TempClientDiagnostic: Record "NPR Client Diagnostic v2" temporary;
    begin
        TempClientDiagnostic."User Security ID" := UserSecurityId();
        TempClientDiagnostic."User Login Type" := TempClientDiagnostic."User Login Type"::BC;
        InitCaseSystemCallback(TempClientDiagnostic);
    end;

    [EventSubscriber(ObjectType::Page, Page::"NPR POS (Dragonglass)", 'OnOpenPageEvent', '', false, false)]
    local procedure HandlePosSessionOnBeforeInitialize()
    var
        TempClientDiagnostic: Record "NPR Client Diagnostic v2" temporary;
    begin
        TempClientDiagnostic."User Security ID" := UserSecurityId();
        TempClientDiagnostic."User Login Type" := TempClientDiagnostic."User Login Type"::POS;
        InitCaseSystemCallback(TempClientDiagnostic);
    end;

    local procedure InitCaseSystemCallback(TempClientDiagnostic: Record "NPR Client Diagnostic v2" temporary)
    var
        Company: Record Company;
        NPREnvironmentInfo: Record "NPR Environment Information";
        EnvironmentInformation: Codeunit "Environment Information";
        SessionId: Integer;
    begin
        if NavApp.IsInstalling() then
            exit;

        if not GuiAllowed then //we only want to work on user sessions = GuiAllowed.
            exit;

        if EnvironmentInformation.IsSandbox() then
            exit;

        if Company.Get(CompanyName()) then
            if Company."Evaluation Company" then
                exit;

        if NPREnvironmentInfo.IsEmpty then
            exit;


        if StartSession(SessionId, Codeunit::"NPR Invoke CaseSystem Login", CompanyName, TempClientDiagnostic) then;
    end;

    [EventSubscriber(ObjectType::Table, Database::User, 'OnAfterDeleteEvent', '', true, false)]
    local procedure UserOnAfterDelete(var Rec: Record User; RunTrigger: Boolean)
    var
        ClientDiag: Record "NPR Client Diagnostic v2";
    begin
        ClientDiag.SetRange("User Security ID", Rec."User Security ID");
        if not ClientDiag.IsEmpty() then
            ClientDiag.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnAfterInsertEvent', '', true, false)]
    local procedure PosUnitOnAfterInsert(var Rec: Record "NPR POS Unit")
    begin
        if Rec.IsTemporary() then
            exit;

        UpdatePosUnitsInTenantDiagnostic(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnAfterModifyEvent', '', true, false)]
    local procedure PosUnitOnAfterModify(var Rec: Record "NPR POS Unit"; var xRec: Record "NPR POS Unit")
    begin
        if Rec.IsTemporary() then
            exit;

        if xRec.Status = Rec.Status then
            exit;

        UpdatePosUnitsInTenantDiagnostic(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnAfterDeleteEvent', '', true, false)]
    local procedure PosUnitOnAfterDelete(var Rec: Record "NPR POS Unit")
    begin
        if Rec.IsTemporary() then
            exit;

        UpdatePosUnitsInTenantDiagnostic(Rec);
    end;

    local procedure UpdatePosUnitsInTenantDiagnostic(PosUnit: Record "NPR POS Unit")
    var
        TenantDiagnostic: Record "NPR Tenant Diagnostic";
        SaaSTenantDiagnostic: Record "NPR Saas Tenant Diagnostic";
        EnvironmentInformation: Codeunit "Environment Information";
        AzureAdTenant: Codeunit "Azure AD Tenant";
        PosUnits: Integer;
    begin
        PosUnit.SetFilter(Status, '<>%1', PosUnit.Status::INACTIVE);
        PosUnits := PosUnit.Count();
        if EnvironmentInformation.IsSaaS() then begin
            InitSaasTenantDiagnostic(AzureAdTenant.GetAadTenantId(), SaaSTenantDiagnostic);

            if SaaSTenantDiagnostic."POS Units" = PosUnits then
                exit;

            SaaSTenantDiagnostic."POS Units" := PosUnits;
            SaaSTenantDiagnostic."POS Units Last Updated" := CurrentDateTime();
            SaaSTenantDiagnostic.Modify();
        end else begin
            InitTenantDiagnostic(TenantDiagnostic);

            if TenantDiagnostic."POS Units" = PosUnits then
                exit;

            TenantDiagnostic."POS Units" := PosUnits;
            TenantDiagnostic."POS Units Last Updated" := CurrentDateTime();
            TenantDiagnostic.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnAfterInsertEvent', '', true, false)]
    local procedure PosStoreOnAFterInsert(var Rec: Record "NPR POS Store")
    begin
        if Rec.IsTemporary() then
            exit;

        UpdatePosStoresInTenantDiagnostic(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnAfterModifyEvent', '', true, false)]
    local procedure PosStoreOnAFterModify(var Rec: Record "NPR POS Store"; var xRec: Record "NPR POS Store")
    begin
        if Rec.IsTemporary() then
            exit;

        if xRec.Inactive = Rec.Inactive then
            exit;

        UpdatePosStoresInTenantDiagnostic(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnAfterDeleteEvent', '', true, false)]
    local procedure PosStoreOnAFterDelete(var Rec: Record "NPR POS Store")
    begin
        if Rec.IsTemporary() then
            exit;

        UpdatePosStoresInTenantDiagnostic(Rec);
    end;

    local procedure UpdatePosStoresInTenantDiagnostic(PosStore: Record "NPR POS Store")
    var
        TenantDiagnostic: Record "NPR Tenant Diagnostic";
        SaaSTenantDiagnostic: Record "NPR Saas Tenant Diagnostic";
        EnvironmentInformation: Codeunit "Environment Information";
        AzureAdTenant: Codeunit "Azure AD Tenant";
        PosStores: Integer;
    begin
        PosStore.SetRange(Inactive, false);
        PosStores := PosStore.Count();
        if EnvironmentInformation.IsSaaS() then begin
            InitSaasTenantDiagnostic(AzureAdTenant.GetAadTenantId(), SaaSTenantDiagnostic);
            if SaaSTenantDiagnostic."POS Stores" = PosStores then
                exit;

            SaaSTenantDiagnostic."POS Stores" := PosStores;
            SaaSTenantDiagnostic."POS Stores Last Updated" := CurrentDateTime();
            SaaSTenantDiagnostic.Modify();
        end else begin
            InitTenantDiagnostic(TenantDiagnostic);
            if TenantDiagnostic."POS Stores" = PosStores then
                exit;

            TenantDiagnostic."POS Stores" := PosStores;
            TenantDiagnostic."POS Stores Last Updated" := CurrentDateTime();
            TenantDiagnostic.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', true, false)]
    local procedure ResetTenantDiagnostic_OnAfterCopyCompany(NewCompanyName: Text[30])
    var
        TenantDiagnostic: Record "NPR Tenant Diagnostic";
    begin
        if not TenantDiagnostic.ChangeCompany(NewCompanyName) then
            exit;

        if not TenantDiagnostic.IsEmpty() then
            TenantDiagnostic.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::Company, 'OnAfterDeleteEvent', '', false, false)]
    local procedure ClearPosUnitAndStoresData_OnAfterDeleteCompany(RunTrigger: Boolean; Rec: Record Company)
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureAdTenant: Codeunit "Azure AD Tenant";
        IsSaas: Boolean;
        AzureAdTenantId: Text;
    begin
        if not RunTrigger then
            exit;

        IsSaas := EnvironmentInformation.IsSaaS(); //Just hardcode this to true if you want to simulate SaaS on container
        AzureAdTenantId := AzureAdTenant.GetAadTenantId(); //Just hardcode this to some AD ID if you want to simulate SaaS on container, otherwise it will be 'common'

        if IsSaas then
            SendPosStoreAndUnitQtyFromSaasEnvironmentOnCompanyDelete(AzureAdTenantId, Rec)
        else
            SendPosStoreAndUnitQtyOnCompanyDelete();
    end;

    procedure ValidateTenant()
    var
        TenantDiagnostic: Record "NPR Tenant Diagnostic";
        EnvironmentInformation: Codeunit "Environment Information";
        ResponseMessage: Text;
    begin
        if EnvironmentInformation.IsSaaS() then
            exit;

        InitTenantDiagnostic(TenantDiagnostic);
        if TenantDiagnostic."Last Tenant ID Sent to CS" = TenantId() then
            exit;

        if TryInitAndSendRequest('ValidateTenant', '', '', TenantId(), ResponseMessage) then begin
            TenantDiagnostic."Last Tenant ID Sent to CS" := CopyStr(TenantId(), 1, MaxStrLen(TenantDiagnostic."Last Tenant ID Sent to CS"));
            TenantDiagnostic."Last DT Tenant ID Sent to CS" := CurrentDateTime;
            TenantDiagnostic.Modify();
        end;
    end;

    procedure ValidateSaasTenant(AzureAdTenantId: Text)
    var
        SaasTenantDiagnostic: Record "NPR Saas Tenant Diagnostic";
        ResponseMessage: Text;
    begin
        InitSaasTenantDiagnostic(AzureAdTenantId, SaasTenantDiagnostic);
        if SaasTenantDiagnostic."Last DT AzTenant ID Sent to CS" <> 0DT then
            exit;

        if TryInitAndSendRequestFromSaasEnvironment('ValidateSaasTenant', SaasTenantDiagnostic."Azure AD Tenant ID", ResponseMessage) then begin
            SaasTenantDiagnostic."Last DT AzTenant ID Sent to CS" := CurrentDateTime;
            SaasTenantDiagnostic.Modify();
        end;
    end;

    procedure TestUserOnLogin(IsSaas: Boolean; AzureAdTenantId: Text; UserLoginType: Enum "NPR User Login Type")
    var
        NPREnvironmentMgt: Codeunit "NPR Environment Mgt.";
        CheckIsUsingRegularInvoicing, UsingRegularInvoicing, WebServiceCallSucceeded, Handled : Boolean;
    begin
        if NPREnvironmentMgt.IsDemo() or NPREnvironmentMgt.IsTest() then
            exit;

        OnShouldCheckIsUsingRegularInvoicing(CheckIsUsingRegularInvoicing);
        if CheckIsUsingRegularInvoicing then begin
            IsUsingRegularInvoicing(UsingRegularInvoicing, WebServiceCallSucceeded, IsSaas, AzureAdTenantId);
            if not WebServiceCallSucceeded then
                exit;

            OnBeforeTestUserOnLogin(UsingRegularInvoicing, Handled);
            if Handled then
                exit;
        end;

        UpdateExpirationMessage(IsSaas, AzureAdTenantId, UserLoginType);
        UpdateExpirationDate(IsSaas, AzureAdTenantId, UserLoginType);
        UpdateUserLockedMessage(IsSaas, AzureAdTenantId, UserLoginType);
    end;

    local procedure IsUsingRegularInvoicing(var UsingRegularInvoicing: Boolean; var WebServiceCallSucceeded: Boolean; IsSaas: Boolean; AzureAdTenantId: Text)
    var
        UseRegularInvoicing: Text;
    begin
        if IsSaas then begin
            if not TryInitAndSendRequestFromSaasEnvironment('GetSaasTenantUseRegularInvoicing', AzureAdTenantId, UseRegularInvoicing) then
                exit;
        end else begin
            if not TryInitAndSendRequest('GetTenantUseRegularInvoicing', '', '', TenantId(), UseRegularInvoicing) then
                exit;
        end;

        WebServiceCallSucceeded := true;

        if UseRegularInvoicing <> '' then
            if not Evaluate(UsingRegularInvoicing, UseRegularInvoicing) then
                WebServiceCallSucceeded := false;
    end;



    local procedure UpdateExpirationMessage(IsSaas: Boolean; AzureAdTenantId: Text; UserLoginType: Enum "NPR User Login Type")
    var
        ExpirationMessage: Text;
        ExpirationMessageLastChecked: DateTime;
        DurationFromLastCheck: Duration;
        DurationCondition: Integer;
    begin
        InitClientDiagnostic(UserLoginType);

        ExpirationMessageLastChecked := ClientDiagnostic."Expirat. Message Last Checked";
        if ExpirationMessageLastChecked = 0DT then
            Evaluate(ExpirationMessageLastChecked, '1970-01-01T00:00:00Z', 9);

        //In order to reduce number of calls to externall services (case system), send the request on login only:
        //  if user wasn't set to expire and if last check was done more than a day ago
        //  but if user was set to be expired (and now it should be unlocked) skip checking if one day has passed and send the request
        DurationFromLastCheck := CurrentDateTime() - ExpirationMessageLastChecked;
        DurationCondition := 1000 * 60 * 60 * 24; //miliseconds * seconds * minutes * hours = one day

        if (ClientDiagnostic."Expiration Message" = '') and (DurationFromLastCheck <= DurationCondition) then
            exit;

        if IsSaas then begin
            if not TryInitAndSendRequestFromSaasEnvironment('GetSaasUserExpirationMessage', UserId(), AzureAdTenantId, format(UserLoginType.AsInteger()), ExpirationMessage) then
                exit;
        end else begin
            if not TryInitAndSendRequest('GetUserExpirationMessage', UserId(), GetDatabaseName(), TenantId(), ExpirationMessage) then
                exit;
        end;

        if LowerCase(ExpirationMessage) = 'false' then
            ExpirationMessage := '';

        if ClientDiagnostic."Expiration Message" <> ExpirationMessage then begin
            ClientDiagnostic."Expiration Message" := CopyStr(ExpirationMessage, 1, MaxStrLen(ClientDiagnostic."Expiration Message"));
            ClientDiagnostic."Expirat. Message Last Updated" := CurrentDateTime();
        end;
        ClientDiagnostic."Expirat. Message Last Checked" := CurrentDateTime();
        if not ClientDiagnostic.Modify() then
            exit;
    end;

    local procedure UpdateExpirationDate(IsSaas: Boolean; AzureAdTenantId: Text; UserLoginType: Enum "NPR User Login Type")
    var
        ExpirationDateTime: DateTime;
        ExpiryDateLastChecked: DateTime;
        DurationFromLastCheck: Duration;
        DurationCondition: Integer;
    begin
        InitClientDiagnostic(UserLoginType);

        ExpiryDateLastChecked := ClientDiagnostic."Expiry Date Last Checked";
        if ExpiryDateLastChecked = 0DT then
            Evaluate(ExpiryDateLastChecked, '1970-01-01T00:00:00Z', 9);

        //In order to reduce number of calls to externall services (case system), send the request on login only:
        //  if user wasn't set to expire and if last check was done more than a day ago
        //  but if user was set to be expired (and now it should be unlocked) skip checking if one day has passed and send the request
        DurationFromLastCheck := CurrentDateTime() - ExpiryDateLastChecked;
        DurationCondition := 1000 * 60 * 60 * 24; //miliseconds * seconds * minutes * hours = one day

        if (ClientDiagnostic."Expiry Date" = 0DT) and (DurationFromLastCheck <= DurationCondition) then
            exit;

        ExpirationDateTime := GetExpirationDateTime(IsSaas, AzureAdTenantId, UserLoginType);
        if ClientDiagnostic."Expiry Date" <> ExpirationDateTime then begin
            ClientDiagnostic."Expiry Date" := ExpirationDateTime;
            ClientDiagnostic."Expiry Date Last Updated" := CurrentDateTime();
        end;
        ClientDiagnostic."Expiry Date Last Checked" := CurrentDateTime();
        if ClientDiagnostic.Modify() then
            Commit();
    end;

    local procedure GetExpirationDateTime(IsSaas: Boolean; AzureAdTenantId: Text; UserLoginType: Enum "NPR User Login Type"): DateTime
    var
        ExpirationDate: Text;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        Hour: Text[2];
        Minute: Text[2];
        Second: Text[2];
        ExpirationTime: Time;
    begin
        if IsSaas then begin
            if not TryInitAndSendRequestFromSaasEnvironment('GetSaasUserExpirationDate', UserId(), AzureAdTenantId, Format(UserLoginType.AsInteger()), ExpirationDate) then
                exit(0DT);
        end else begin
            if not TryInitAndSendRequest('GetUserExpirationDate', UserId(), GetDatabaseName(), TenantId(), ExpirationDate) then
                exit(0DT);
        end;

        if (ExpirationDate = '') or (ExpirationDate = '0001-01-01T00:00:00') then
            exit(0DT);

        Evaluate(Day, CopyStr(ExpirationDate, 9, 2));
        Evaluate(Month, CopyStr(ExpirationDate, 6, 2));
        Evaluate(Year, CopyStr(ExpirationDate, 1, 4));

        Hour := CopyStr(ExpirationDate, 12, 2);
        Minute := CopyStr(ExpirationDate, 15, 2);
        Second := CopyStr(ExpirationDate, 18, 2);
        Evaluate(ExpirationTime, Hour + Minute + Second);

        exit(CreateDateTime(DMY2Date(Day, Month, Year), ExpirationTime));
    end;

    local procedure InitClientDiagnostic(UserLoginType: Enum "NPR User Login Type")
    var
#IF CLOUD
        AzureADUserManagement: Codeunit "Azure AD User Management";
        DelegatedUser: Boolean;
#ENDIF
    begin
        if Initialized then
            exit;

        if ClientDiagnostic.Get(UserSecurityId(), UserLoginType) then begin
#IF CLOUD
            DelegatedUser := AzureADUserManagement.IsUserDelegated(UserSecurityId());
            if ClientDiagnostic."Delegated User" <> DelegatedUser then begin
                ClientDiagnostic."Delegated User" := DelegatedUser;
                ClientDiagnostic.Modify();
            end;
#ENDIF
            Initialized := true;
            exit;
        end;

        ClientDiagnostic.Init();
        ClientDiagnostic."User Security ID" := UserSecurityId();
        ClientDiagnostic."User Login Type" := UserLoginType;
#IF CLOUD
        ClientDiagnostic."Delegated User" := DelegatedUser;
#ENDIF
        if ClientDiagnostic.Insert() then
            Initialized := true;
    end;

    local procedure UpdateUserLockedMessage(IsSaas: Boolean; AzureAdTenantId: Text; UserLoginType: Enum "NPR User Login Type")
    var
        LockedMessage: Text;
        LockedMessageLastChecked: DateTime;
        DurationFromLastCheck: Duration;
        DurationCondition: Integer;
    begin
        InitClientDiagnostic(UserLoginType);

        LockedMessageLastChecked := ClientDiagnostic."Locked Message Last Checked";
        if LockedMessageLastChecked = 0DT then
            Evaluate(LockedMessageLastChecked, '1970-01-01T00:00:00Z', 9);

        //In order to reduce number of calls to externall services (case system), send the request on login only:
        //  if user wasn't locked and if last check was done more than a day ago
        //  but if user was set to be locked (and now it should be unlocked) skip checking if day has passed and send the request
        DurationFromLastCheck := CurrentDateTime() - LockedMessageLastChecked;
        DurationCondition := 1000 * 60 * 60 * 24; //miliseconds * seconds * minutes * hours = one day

        if (ClientDiagnostic."Locked Message" = '') and (DurationFromLastCheck <= DurationCondition) then
            exit;

        if IsSaas then begin
            if not TryInitAndSendRequestFromSaasEnvironment('GetSaasUserLockedMessage', UserId(), AzureAdTenantId, Format(UserLoginType.AsInteger()), LockedMessage) then
                exit;
        end else begin
            if not TryInitAndSendRequest('GetUserLockedMessage', UserId(), GetDatabaseName(), TenantId(), LockedMessage) then
                exit;
        end;

        if LowerCase(LockedMessage) = 'false' then
            LockedMessage := '';

        if ClientDiagnostic."Locked Message" <> LockedMessage then begin
            ClientDiagnostic."Locked Message" := CopyStr(LockedMessage, 1, MaxStrLen(ClientDiagnostic."Locked Message"));
            ClientDiagnostic."Locked Message Last Updated" := CurrentDateTime();
        end;
        ClientDiagnostic."Locked Message Last Checked" := CurrentDateTime();
        if ClientDiagnostic.Modify() then
            Commit();
    end;

    procedure SendPosStoreAndUnitQty()
    var
        TenantDiagnostic: Record "NPR Tenant Diagnostic";
        PosStore: Record "NPR POS Store";
        PosUnit: Record "NPR POS Unit";
        NPREnvironmentMgt: Codeunit "NPR Environment Mgt.";
        ResponseMessage: Text;
        ShouldSendRequest: Boolean;
        POSUnitsLastSent, POSStoresLastSent : DateTime;
    begin
        InitTenantDiagnostic(TenantDiagnostic);

        //In order to reduce number of calls to externall services (case system), send the request on login only:
        //  if it wasn't sent at least once in the past (because of initial sync after new App version is installed or new company is created) 
        //  if when there is a difference between current POS Store qty and POS Store qty previously sent through API. (same condition for POS Unit)
        //  and if more than 24 hours have passed after the last sync
        POSUnitsLastSent := TenantDiagnostic."POS Units Last Sent";
        POSStoresLastSent := TenantDiagnostic."POS Stores Last Sent";
        if not PosStoresAndUnitsSyncedInTheLast24Hours(POSUnitsLastSent, POSStoresLastSent) then
            ShouldSendRequest := true;

        PosStore.SetRange(Inactive, false);
        PosUnit.SetFilter(Status, '<>%1', PosUnit.Status::INACTIVE);
        TenantDiagnostic."POS Stores" := PosStore.Count();
        TenantDiagnostic."POS Units" := PosUnit.Count();
        TenantDiagnostic."POS Stores Last Updated" := CurrentDateTime();
        TenantDiagnostic."POS Units Last Updated" := CurrentDateTime();

        //This condition is handling situations when company had environment type "PROD" and had POS Stores and Units sent to case system in the past,
        //but was switched to DEMO,TEST,SANDBOX etc., so it will send 0 quantities in order to clear data in the case system.
        if NPREnvironmentMgt.IsDemo() or NPREnvironmentMgt.IsTest() then begin
            if (TenantDiagnostic."POS Units Last Sent" <> 0DT) OR (TenantDiagnostic."POS Stores Last Sent" <> 0DT) then begin
                TenantDiagnostic."POS Stores" := 0;
                TenantDiagnostic."POS Units" := 0;
                ShouldSendRequest := true;
            end;
        end;

        if not ShouldSendRequest then
            if (TenantDiagnostic."POS Stores" <> TenantDiagnostic."POS Stores Sent on Last Upd.") or (TenantDiagnostic."POS Units" <> TenantDiagnostic."POS Units Sent on Last Upd.") then
                ShouldSendRequest := true;

        if not ShouldSendRequest then
            exit;

        if not TryInitAndSendRequest('UpdatePosStoresAndUnits', GetDatabaseName(), TenantId(), CompanyName(), Format(TenantDiagnostic."POS Stores"), Format(TenantDiagnostic."POS Units"), ResponseMessage) then
            exit;

        if LowerCase(ResponseMessage) = 'true' then begin
            TenantDiagnostic."POS Stores Sent on Last Upd." := TenantDiagnostic."POS Stores";
            TenantDiagnostic."POS Units Sent on Last Upd." := TenantDiagnostic."POS Units";
            TenantDiagnostic."POS Stores Last Sent" := CurrentDateTime();
            TenantDiagnostic."POS Units Last Sent" := CurrentDateTime();
            TenantDiagnostic.Modify();
        end;
    end;

    procedure SendPosStoreAndUnitQtyOnCompanyDelete()
    var
        TenantDiagnostic: Record "NPR Tenant Diagnostic";
        ResponseMessage: Text;
    begin
        InitTenantDiagnostic(TenantDiagnostic);

        if (TenantDiagnostic."POS Units Last Sent" = 0DT) and (TenantDiagnostic."POS Stores Last Sent" = 0DT) then
            exit;

        TenantDiagnostic."POS Stores" := 0;
        TenantDiagnostic."POS Units" := 0;
        TenantDiagnostic."POS Stores Last Updated" := CurrentDateTime();
        TenantDiagnostic."POS Units Last Updated" := CurrentDateTime();

        if not TryInitAndSendRequest('UpdatePosStoresAndUnits', GetDatabaseName(), TenantId(), CompanyName(), Format(TenantDiagnostic."POS Stores"), Format(TenantDiagnostic."POS Units"), ResponseMessage) then
            exit;

        if LowerCase(ResponseMessage) = 'true' then begin
            TenantDiagnostic."POS Stores Sent on Last Upd." := TenantDiagnostic."POS Stores";
            TenantDiagnostic."POS Units Sent on Last Upd." := TenantDiagnostic."POS Units";
            TenantDiagnostic."POS Stores Last Sent" := CurrentDateTime();
            TenantDiagnostic."POS Units Last Sent" := CurrentDateTime();
            TenantDiagnostic.Modify();
        end;
    end;

    procedure SendPosStoreAndUnitQtyFromSaasEnvironment(AzureAdTenantId: Text)
    var
        SaasTenantDiagnostic: Record "NPR Saas Tenant Diagnostic";
        PosStore: Record "NPR POS Store";
        PosUnit: Record "NPR POS Unit";
        NPREnvironmentMgt: Codeunit "NPR Environment Mgt.";
        EnvironmentInformation: Codeunit "Environment Information";
        ResponseMessage: Text;
        ShouldSendRequest: Boolean;
        POSUnitsLastSent, POSStoresLastSent : DateTime;
    begin
        InitSaasTenantDiagnostic(AzureAdTenantId, SaasTenantDiagnostic);

        //In order to reduce number of calls to externall services (case system), send the request on login only:
        //  if it wasn't sent at least once in the past (because of initial sync after new App version is installed or new company is created) 
        //  if when there is a difference between current POS Store qty and POS Store qty previously sent through API. (same condition for POS Unit)
        //  and more than 24 hours have passed after the last sync
        POSUnitsLastSent := SaasTenantDiagnostic."POS Units Last Sent";
        POSStoresLastSent := SaasTenantDiagnostic."POS Stores Last Sent";
        if not PosStoresAndUnitsSyncedInTheLast24Hours(POSUnitsLastSent, POSStoresLastSent) then
            ShouldSendRequest := true;

        PosStore.SetRange(Inactive, false);
        PosUnit.SetFilter(Status, '<>%1', PosUnit.Status::INACTIVE);
        SaasTenantDiagnostic."POS Stores" := PosStore.Count();
        SaasTenantDiagnostic."POS Units" := PosUnit.Count();
        SaasTenantDiagnostic."POS Stores Last Updated" := CurrentDateTime();
        SaasTenantDiagnostic."POS Units Last Updated" := CurrentDateTime();

        //This condition is handling situations when company had environment type "PROD" and had POS Stores and Units sent to case system in the past,
        //but was switched to DEMO,TEST,SANDBOX etc., so it will send 0 quantities in order to clear data in the case system.
        if NPREnvironmentMgt.IsDemo() or NPREnvironmentMgt.IsTest() then begin
            if (SaasTenantDiagnostic."POS Units Last Sent" <> 0DT) or (SaasTenantDiagnostic."POS Stores Last Sent" <> 0DT) then begin
                SaasTenantDiagnostic."POS Stores" := 0;
                SaasTenantDiagnostic."POS Units" := 0;
                ShouldSendRequest := true;
            end;
        end;

        if not ShouldSendRequest then
            if (SaasTenantDiagnostic."POS Stores" <> SaasTenantDiagnostic."POS Stores Sent on Last Upd.") or (SaasTenantDiagnostic."POS Units" <> SaasTenantDiagnostic."POS Units Sent on Last Upd.") then
                ShouldSendRequest := true;

        if not ShouldSendRequest then
            exit;

        if not TryInitAndSendRequestFromSaasEnvironment('UpdateSaasPosStoresAndUnitsV2', AzureAdTenantId, CompanyName(), EnvironmentInformation.GetEnvironmentName(), Format(SaasTenantDiagnostic."POS Stores"), Format(SaasTenantDiagnostic."POS Units"), ResponseMessage) then
            exit;

        if LowerCase(ResponseMessage) = 'true' then begin
            SaasTenantDiagnostic."POS Stores Sent on Last Upd." := SaasTenantDiagnostic."POS Stores";
            SaasTenantDiagnostic."POS Units Sent on Last Upd." := SaasTenantDiagnostic."POS Units";
            SaasTenantDiagnostic."POS Stores Last Sent" := CurrentDateTime();
            SaasTenantDiagnostic."POS Units Last Sent" := CurrentDateTime();
            SaasTenantDiagnostic.Modify();
        end;
    end;

    procedure SendPosStoreAndUnitQtyFromSaasEnvironmentOnCompanyDelete(AzureAdTenantId: Text; DeletedCompany: Record Company)
    var
        SaasTenantDiagnostic: Record "NPR Saas Tenant Diagnostic";
        EnvironmentInformation: Codeunit "Environment Information";
        ResponseMessage: Text;
    begin
        InitSaasTenantDiagnostic(AzureAdTenantId, SaasTenantDiagnostic);

        if (SaasTenantDiagnostic."POS Units Last Sent" = 0DT) AND (SaasTenantDiagnostic."POS Stores Last Sent" = 0DT) then
            exit;

        SaasTenantDiagnostic.ChangeCompany(DeletedCompany.Name);
        SaasTenantDiagnostic."POS Stores" := 0;
        SaasTenantDiagnostic."POS Units" := 0;
        SaasTenantDiagnostic."POS Stores Last Updated" := CurrentDateTime();
        SaasTenantDiagnostic."POS Units Last Updated" := CurrentDateTime();

        if not TryInitAndSendRequestFromSaasEnvironment('UpdateSaasPosStoresAndUnitsV2', AzureAdTenantId, DeletedCompany.Name, EnvironmentInformation.GetEnvironmentName(), Format(SaasTenantDiagnostic."POS Stores"), Format(SaasTenantDiagnostic."POS Units"), ResponseMessage) then
            exit;

        if LowerCase(ResponseMessage) = 'true' then begin
            SaasTenantDiagnostic."POS Stores Sent on Last Upd." := 0;
            SaasTenantDiagnostic."POS Units Sent on Last Upd." := 0;
            SaasTenantDiagnostic."POS Stores Last Sent" := CurrentDateTime();
            SaasTenantDiagnostic."POS Units Last Sent" := CurrentDateTime();
            SaasTenantDiagnostic.Modify();
        end;
    end;

    local procedure PosStoresAndUnitsSyncedInTheLast24Hours(POSUnitsLastSent: DateTime; POSStoresLastSent: DateTime): Boolean
    var
        DurationFromLastPosUnitCheck, DurationFromLastPosStoreCheck : Duration;
        DurationCondition: Integer;
    begin
        if POSUnitsLastSent = 0DT then
            Evaluate(POSUnitsLastSent, '1970-01-01T00:00:00Z', 9);

        if POSStoresLastSent = 0DT then
            Evaluate(POSStoresLastSent, '1970-01-01T00:00:00Z', 9);

        DurationFromLastPosUnitCheck := CurrentDateTime() - POSUnitsLastSent;
        DurationFromLastPosStoreCheck := CurrentDateTime() - POSStoresLastSent;
        DurationCondition := 1000 * 60 * 60 * 24; //miliseconds * seconds * minutes * hours = one day

        if (DurationFromLastPosUnitCheck <= DurationCondition) and (DurationFromLastPosStoreCheck <= DurationCondition) then
            exit(true);
    end;

    local procedure InitTenantDiagnostic(var TenantDiagnostic: Record "NPR Tenant Diagnostic")
    begin
        if not TenantDiagnostic.Get(TenantId()) then begin
            TenantDiagnostic.Init();
            TenantDiagnostic."Tenant ID" := CopyStr(TenantId(), 1, MaxStrLen(TenantDiagnostic."Tenant ID"));
            TenantDiagnostic.Insert();
        end;
    end;

    local procedure InitSaasTenantDiagnostic(AzureAdTenantId: Text; var SaasTenantDiagnostic: Record "NPR Saas Tenant Diagnostic")
    begin
        if not SaasTenantDiagnostic.Get(AzureAdTenantId) then begin
            SaasTenantDiagnostic.Init();
            SaasTenantDiagnostic."Azure AD Tenant ID" := CopyStr(AzureAdTenantId, 1, MaxStrLen(SaasTenantDiagnostic."Azure AD Tenant ID"));
            SaasTenantDiagnostic.Insert();
        end;
    end;

    [TryFunction]
    local procedure TryInitAndSendRequest(serviceMethod: Text; ThisUserId: Text; DatabaseName: Text; ThisTenantId: Text; var responseMessage: Text)
    var
        Content: HttpContent;
    begin
        Content.WriteFrom(InitRequestContent(serviceMethod, ThisUserId, DatabaseName, ThisTenantId));
        TrySendRequest(Content, serviceMethod, false, responseMessage)
    end;

    [TryFunction]
    local procedure TryInitAndSendRequest(serviceMethod: Text; DatabaseName: Text; ThisTenantId: Text; ThisCompanyName: Text; ThisPosStores: Text; ThisPosUnits: Text; var responseMessage: Text)
    var
        Content: HttpContent;
    begin
        Content.WriteFrom(InitRequestContent(serviceMethod, DatabaseName, ThisTenantId, ThisCompanyName, ThisPosStores, ThisPosUnits));
        TrySendRequest(Content, serviceMethod, false, responseMessage)
    end;

    [TryFunction]
    local procedure TryInitAndSendRequestFromSaasEnvironment(serviceMethod: Text; ThisUserId: Text; AzureADTenantID: Text; UserLoginTypeIn: Text; var responseMessage: Text)
    var
        Content: HttpContent;
    begin
        Content.WriteFrom(InitRequestContentFromSaasEnvironment(serviceMethod, ThisUserId, AzureADTenantID, UserLoginTypeIn));
        TrySendRequest(Content, serviceMethod, true, responseMessage)
    end;

    [TryFunction]
    local procedure TryInitAndSendRequestFromSaasEnvironment(serviceMethod: Text; AzureADTenantID: Text; var responseMessage: Text)
    var
        Content: HttpContent;
    begin
        Content.WriteFrom(InitRequestContentFromSaasEnvironment(serviceMethod, AzureADTenantID));
        TrySendRequest(Content, serviceMethod, true, responseMessage)
    end;

    [TryFunction]
    local procedure TryInitAndSendRequestFromSaasEnvironment(serviceMethod: Text; AzureADTenantID: Text; ThisCompanyName: Text; ThisEnvironmentName: Text; ThisPosStores: Text; ThisPosUnits: Text; var responseMessage: Text)
    var
        Content: HttpContent;
    begin
        Content.WriteFrom(InitRequestContentFromSaasEnvironment(serviceMethod, AzureADTenantID, ThisCompanyName, ThisEnvironmentName, ThisPosStores, ThisPosUnits));
        TrySendRequest(Content, serviceMethod, true, responseMessage)
    end;

    [TryFunction]
    local procedure TrySendRequest(var Content: HttpContent; serviceMethod: Text; IsSaas: Boolean; var responseMessage: Text)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Client: HttpClient;
        Response: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
    begin
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'text/xml; charset=utf-8');
        if IsSaas then begin
            ContentHeaders.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/BCSaasUser:' + serviceMethod);
            ContentHeaders.Add('Ocp-Apim-Subscription-Key', AzureKeyVaultMgt.GetAzureKeyVaultSecret('CaseSystemSaasBCPhoneHomeAzureAPIKey'));
        end else begin
            ContentHeaders.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser:' + serviceMethod);
            ContentHeaders.Add('Ocp-Apim-Subscription-Key', AzureKeyVaultMgt.GetAzureKeyVaultSecret('CaseSystemBCPhoneHomeAzureAPIKey'));
        end;

        Client.Timeout(5000);

        if IsSaas then begin
            if not Client.Post('https://api.navipartner.dk/BCSaasUser', Content, Response) then
                Error(GetLastErrorText);
        end else begin
            if not Client.Post('https://api.navipartner.dk/ServiceTierUser', Content, Response) then
                Error(GetLastErrorText);
        end;

        if not Response.IsSuccessStatusCode then
            Error(Format(Response.HttpStatusCode));

        Response.Content().ReadAs(responseMessage);
        responseMessage := GetWebResponseResult(responseMessage, IsSaas);
    end;

    local procedure InitRequestContent(serviceMethod: Text; ThisUserId: Text; DatabaseName: Text; ThisTenantId: Text): Text
    var
        Builder: TextBuilder;
    begin
        Builder.Append('<?xml version="1.0" encoding="UTF-8"?>');
        Builder.Append('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" >');
        Builder.Append('  <soapenv:Header/>');
        Builder.Append('  <soapenv:Body>');
        Builder.Append('    <' + serviceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser">');

        if ThisUserId <> '' then
            Builder.Append('      <usernameIn>' + ThisUserId + '</usernameIn>');

        if DatabaseName <> '' then
            Builder.Append('      <databaseNameIn>' + DatabaseName + '</databaseNameIn>');

        if ThisTenantId <> '' then
            Builder.Append('      <tenantIDIn>' + ThisTenantId + '</tenantIDIn>');

        Builder.Append('    </' + serviceMethod + '>');
        Builder.Append('  </soapenv:Body>');
        Builder.Append('</soapenv:Envelope>');

        exit(Builder.ToText());
    end;

    local procedure InitRequestContentFromSaasEnvironment(serviceMethod: Text; ThisUserId: Text; ThisAzureAdTenantId: Text; ThisUserLoginTypeIn: Text): Text
    var
        Builder: TextBuilder;
    begin
        Builder.Append('<?xml version="1.0" encoding="UTF-8"?>');
        Builder.Append('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" >');
        Builder.Append('  <soapenv:Header/>');
        Builder.Append('  <soapenv:Body>');
        Builder.Append('    <' + serviceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/BCSaasUser">');

        if ThisUserId <> '' then
            Builder.Append('      <usernameIn>' + ThisUserId + '</usernameIn>');

        if ThisAzureAdTenantId <> '' then
            Builder.Append('      <azureAdTenantIDIn>' + ThisAzureAdTenantId + '</azureAdTenantIDIn>');

        if ThisUserLoginTypeIn <> '' then
            Builder.Append('      <userLoginTypeIn>' + ThisUserLoginTypeIn + '</userLoginTypeIn>');

        Builder.Append('    </' + serviceMethod + '>');
        Builder.Append('  </soapenv:Body>');
        Builder.Append('</soapenv:Envelope>');

        exit(Builder.ToText());
    end;

    local procedure InitRequestContentFromSaasEnvironment(serviceMethod: Text; ThisAzureAdTenantId: Text; ThisCompanyName: Text; ThisEnvironmentName: Text; ThisPosStores: Text; ThisPosUnits: Text): Text
    var
        Builder: TextBuilder;
    begin
        Builder.Append('<?xml version="1.0" encoding="UTF-8"?>');
        Builder.Append('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" >');
        Builder.Append('  <soapenv:Header/>');
        Builder.Append('  <soapenv:Body>');
        Builder.Append('    <' + serviceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/BCSaasUser">');

        if ThisAzureAdTenantId <> '' then
            Builder.Append('      <azureAdTenantIDIn>' + ThisAzureAdTenantId + '</azureAdTenantIDIn>');

        if ThisCompanyName <> '' then
            Builder.Append('      <companyNameIn>' + ThisCompanyName + '</companyNameIn>');

        if ThisEnvironmentName <> '' then
            Builder.Append('      <environmentNameIn>' + ThisEnvironmentName + '</environmentNameIn>');

        if ThisPosStores <> '' then
            Builder.Append('      <posStoresIn>' + ThisPosStores + '</posStoresIn>');

        if ThisPosUnits <> '' then
            Builder.Append('      <posUnitsIn>' + ThisPosUnits + '</posUnitsIn>');

        Builder.Append('    </' + serviceMethod + '>');
        Builder.Append('  </soapenv:Body>');
        Builder.Append('</soapenv:Envelope>');

        exit(Builder.ToText());
    end;

    local procedure InitRequestContentFromSaasEnvironment(serviceMethod: Text; AzureAdTenantId: Text): Text
    var
        Builder: TextBuilder;
    begin
        Builder.Append('<?xml version="1.0" encoding="UTF-8"?>');
        Builder.Append('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" >');
        Builder.Append('  <soapenv:Header/>');
        Builder.Append('  <soapenv:Body>');
        Builder.Append('    <' + serviceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/BCSaasUser">');
        Builder.Append('      <azureAdTenantIDIn>' + AzureAdTenantId + '</azureAdTenantIDIn>');
        Builder.Append('    </' + serviceMethod + '>');
        Builder.Append('  </soapenv:Body>');
        Builder.Append('</soapenv:Envelope>');

        exit(Builder.ToText());
    end;

    local procedure InitRequestContent(serviceMethod: Text; DatabaseName: Text; ThisTenantId: Text; ThisCompanyName: Text; ThisPosStores: Text; ThisPosUnits: Text): Text
    var
        Builder: TextBuilder;
    begin
        Builder.Append('<?xml version="1.0" encoding="UTF-8"?>');
        Builder.Append('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" >');
        Builder.Append('  <soapenv:Header/>');
        Builder.Append('  <soapenv:Body>');
        Builder.Append('    <' + serviceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser">');

        if DatabaseName <> '' then
            Builder.Append('      <databaseNameIn>' + DatabaseName + '</databaseNameIn>');

        if ThisTenantId <> '' then
            Builder.Append('      <tenantIDIn>' + ThisTenantId + '</tenantIDIn>');

        if ThisCompanyName <> '' then
            Builder.Append('      <companyNameIn>' + ThisCompanyName + '</companyNameIn>');

        if ThisPosStores <> '' then
            Builder.Append('      <posStoresIn>' + ThisPosStores + '</posStoresIn>');

        if ThisPosUnits <> '' then
            Builder.Append('      <posUnitsIn>' + ThisPosUnits + '</posUnitsIn>');

        Builder.Append('    </' + serviceMethod + '>');
        Builder.Append('  </soapenv:Body>');
        Builder.Append('</soapenv:Envelope>');

        exit(Builder.ToText());
    end;

    local procedure GetWebResponseResult(response: Text; IsSaas: Boolean) ResponseText: Text
    var
        XmlDoc: XmlDocument;
        XmlNode: XmlNode;
        XmlNamespace: XmlNamespaceManager;
    begin
        XmlDocument.ReadFrom(response, XmlDoc);
        if IsSaas then
            XmlNamespace.AddNamespace('BC', 'urn:microsoft-dynamics-schemas/codeunit/BCSaasUser')
        else
            XmlNamespace.AddNamespace('BC', 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser');

        XmlDoc.SelectSingleNode('//BC:return_value', XmlNamespace, XmlNode);
        ResponseText := XmlNode.AsXmlElement().InnerText;
        exit(ResponseText);
    end;

    local procedure GetDatabaseName(): Text
    var
        activeSession: Record "Active Session";
    begin
        FindMySession(activeSession);
        exit(activeSession."Database Name")
    end;

    local procedure FindMySession(var activeSession: Record "Active Session")
    var
        Itt: Integer;
    begin
        if (activeSession."Server Instance ID" = ServiceInstanceId()) and
           (activeSession."Session ID" = SessionId())
        then
            exit;

        while (not activeSession.Get(ServiceInstanceId(), SessionId())) do begin
            Sleep(10);
            Itt += 1;
            if Itt > 50 then begin
                if not GuiAllowed then
                    exit;
                activeSession.Get(ServiceInstanceId(), SessionId());
            end;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShouldCheckIsUsingRegularInvoicing(var CheckIsUsingRegularInvoicing: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestUserOnLogin(UsingRegularInvoicing: Boolean; var Handled: Boolean)
    begin
    end;

    [Obsolete('Not used anymore.', 'NPR23.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestUserOnPOSSessionInitialize(UsingRegularInvoicing: Boolean; var Handled: Boolean)
    begin
    end;
}

codeunit 6014590 "NPR Service Tier User Mgt."
{
    Access = Internal;

    var
        ClientDiagnostic: Record "NPR Client Diagnostic";
        Initialized: Boolean;

#if BC20
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", 'OnAfterLogin', '', true, false)]
    local procedure HandleOnAfterLogin()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if NavApp.IsInstalling() then
            exit;

        if not (CurrentClientType in [ClientType::Windows, ClientType::Web, ClientType::Tablet, ClientType::Phone, ClientType::Desktop]) then
            exit;

        if EnvironmentInformation.IsSandbox() then
            exit;

        ValidateBCOnlineTenant();
        TestUserOnLogin();
        SendPosUnitQty();
    end;
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeLogInStart', '', true, false)]
    local procedure HandleOnBeforeLogInStart()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if NavApp.IsInstalling() then
            exit;

        if not (CurrentClientType in [ClientType::Windows, ClientType::Web, ClientType::Tablet, ClientType::Phone, ClientType::Desktop]) then
            exit;

        if EnvironmentInformation.IsSandbox() then
            exit;

        ValidateBCOnlineTenant();
        TestUserOnLogin();
        SendPosUnitQty();
    end;
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Session", 'OnInitialize', '', false, false)]
    local procedure HandleOnInitialize()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not (CurrentClientType in [ClientType::Windows, ClientType::Web, ClientType::Tablet, ClientType::Phone, ClientType::Desktop]) then
            exit;

        if EnvironmentInformation.IsSandbox() then
            exit;

        TestUserOnPOSSessionInitialize();
    end;

    [EventSubscriber(ObjectType::Table, Database::User, 'OnAfterDeleteEvent', '', true, false)]
    local procedure UserOnAfterDelete(var Rec: Record User; RunTrigger: Boolean)
    var
        ClientDiag: Record "NPR Client Diagnostic";
    begin
        ClientDiag.SetRange("User Security ID", Rec."User Security ID");
        if not ClientDiag.IsEmpty() then
            ClientDiag.Delete();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnAfterInsertEvent', '', true, false)]
    local procedure PosUnitOnAFterInsert(var Rec: Record "NPR POS Unit")
    begin
        UpdatePosUnitsInTenantDiagnostic(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Unit", 'OnAfterDeleteEvent', '', true, false)]
    local procedure PosUnitOnAFterDelete(var Rec: Record "NPR POS Unit")
    begin
        UpdatePosUnitsInTenantDiagnostic(Rec);
    end;

    local procedure UpdatePosUnitsInTenantDiagnostic(PosUnit: Record "NPR POS Unit")
    var
        TenantDiagnostic: Record "NPR Tenant Diagnostic";
        PosUnits: Integer;
    begin
        PosUnits := PosUnit.Count();
        InitTenantDiagnostic(TenantDiagnostic);

        if TenantDiagnostic."POS Units" = PosUnits then
            exit;

        TenantDiagnostic."POS Units" := PosUnits;
        TenantDiagnostic."POS Units Last Updated" := CurrentDateTime();
        TenantDiagnostic.Modify();
        SendPosUnitQty();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnAfterInsertEvent', '', true, false)]
    local procedure PosStoreOnAFterInsert(var Rec: Record "NPR POS Store")
    begin
        UpdatePosStoresInTenantDiagnostic(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Store", 'OnAfterDeleteEvent', '', true, false)]
    local procedure PosStoreOnAFterDelete(var Rec: Record "NPR POS Store")
    begin
        UpdatePosStoresInTenantDiagnostic(Rec);
    end;

    local procedure UpdatePosStoresInTenantDiagnostic(PosStore: Record "NPR POS Store")
    var
        TenantDiagnostic: Record "NPR Tenant Diagnostic";
        PosStores: Integer;
    begin
        PosStores := PosStore.Count();
        InitTenantDiagnostic(TenantDiagnostic);

        if TenantDiagnostic."POS Stores" = PosStores then
            exit;

        TenantDiagnostic."POS Stores" := PosStores;
        TenantDiagnostic."POS Stores Last Updated" := CurrentDateTime();
        TenantDiagnostic.Modify();
        SendPosUnitQty();
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

    local procedure ValidateBCOnlineTenant()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        ResponseMessage: Text;
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit;

        if not TryInitAndSendRequest('ValidateBCOnlineTenant', '', '', TenantId(), ResponseMessage) then
            exit;
    end;

    local procedure TestUserOnLogin()
    var
        CheckIsUsingRegularInvoicing, UsingRegularInvoicing, WebServiceCallSucceeded, Handled : Boolean;
    begin
        OnShouldCheckIsUsingRegularInvoicing(CheckIsUsingRegularInvoicing);
        if CheckIsUsingRegularInvoicing then begin
            IsUsingRegularInvoicing(UsingRegularInvoicing, WebServiceCallSucceeded);
            if not WebServiceCallSucceeded then
                exit;

            OnBeforeTestUserOnLogin(UsingRegularInvoicing, Handled);
            if Handled then
                exit;
        end;

        TestUserExpired();
        TestUserLocked(false);
    end;

    local procedure TestUserOnPOSSessionInitialize()
    var
        POSSession: Codeunit "NPR POS Session";
        CheckIsUsingRegularInvoicing, UsingRegularInvoicing, WebServiceCallSucceeded, Handled : Boolean;
    begin
        OnShouldCheckIsUsingRegularInvoicing(CheckIsUsingRegularInvoicing);
        if CheckIsUsingRegularInvoicing then begin
            IsUsingRegularInvoicing(UsingRegularInvoicing, WebServiceCallSucceeded);
            if not WebServiceCallSucceeded then
                exit;

            OnBeforeTestUserOnPOSSessionInitialize(UsingRegularInvoicing, Handled);
            if Handled then
                exit;
        end;

        TestUserExpired();
        if not TryTestUserLocked() then
            POSSession.SetErrorOnInitialize(true);
    end;

    local procedure IsUsingRegularInvoicing(var UsingRegularInvoicing: Boolean; var WebServiceCallSucceeded: Boolean)
    var
        UseRegularInvoicing: Text;
    begin
        if not TryInitAndSendRequest('GetTenantUseRegularInvoicing', '', '', TenantId(), UseRegularInvoicing) then
            exit;

        WebServiceCallSucceeded := true;

        if UseRegularInvoicing <> '' then
            if not Evaluate(UsingRegularInvoicing, UseRegularInvoicing) then
                WebServiceCallSucceeded := false;
    end;

    local procedure TestUserExpired()
    var
        ExpirationMessage: Text;
    begin
        UpdateExpirationMessage(ExpirationMessage);
        if ExpirationMessage <> '' then
            Message(ExpirationMessage);

        UpdateExpirationDate();
        PreventLoginIfUserIsExpired();
    end;

    local procedure UpdateExpirationMessage(var ExpirationMessage: Text)
    var
        ExpirationMessageLastChecked: DateTime;
        DurationFromLastCheck: Duration;
        DurationCondition: Integer;
    begin
        InitClientDiagnostic();

        ExpirationMessageLastChecked := ClientDiagnostic."Expirat. Message Last Checked";
        if ExpirationMessageLastChecked = 0DT then
            Evaluate(ExpirationMessageLastChecked, '1970-01-01T00:00:00Z', 9);

        //In order to reduce number of calls to externall services (case system), send the request on login only:
        //  if user wasn't set to expire and if last check was done more than an hour ago
        //  but if user was set to be expired (and now it should be unlocked) skip checking if an hour has passed and send the request
        DurationFromLastCheck := CurrentDateTime() - ExpirationMessageLastChecked;
        DurationCondition := 1000 * 60 * 60; //miliseconds * seconds * minutes = one hour

        if (ClientDiagnostic."Expiration Message" = '') and (DurationFromLastCheck <= DurationCondition) then
            exit;

        if not TryInitAndSendRequest('GetUserExpirationMessage', UserId(), GetDatabaseName(), TenantId(), ExpirationMessage) then
            exit;

        if LowerCase(ExpirationMessage) = 'false' then
            ExpirationMessage := '';

        if ClientDiagnostic."Expiration Message" <> ExpirationMessage then begin
            ClientDiagnostic."Expiration Message" := CopyStr(ExpirationMessage, 1, MaxStrLen(ClientDiagnostic."Expiration Message"));
            ClientDiagnostic."Expirat. Message Last Updated" := CurrentDateTime();
        end;
        ClientDiagnostic."Expirat. Message Last Checked" := CurrentDateTime();
        ClientDiagnostic.Modify();
    end;

    local procedure UpdateExpirationDate()
    var
        ExpirationDateTime: DateTime;
        ExpiryDateLastChecked: DateTime;
        DurationFromLastCheck: Duration;
        DurationCondition: Integer;
    begin
        InitClientDiagnostic();

        ExpiryDateLastChecked := ClientDiagnostic."Expiry Date Last Checked";
        if ExpiryDateLastChecked = 0DT then
            Evaluate(ExpiryDateLastChecked, '1970-01-01T00:00:00Z', 9);

        //In order to reduce number of calls to externall services (case system), send the request on login only:
        //  if user wasn't set to expire and if last check was done more than an hour ago
        //  but if user was set to be expired (and now it should be unlocked) skip checking if an hour has passed and send the request
        DurationFromLastCheck := CurrentDateTime() - ExpiryDateLastChecked;
        DurationCondition := 1000 * 60 * 60; //miliseconds * seconds * minutes = one hour

        if (ClientDiagnostic."Expiry Date" = 0DT) and (DurationFromLastCheck <= DurationCondition) then
            exit;

        ExpirationDateTime := GetExpirationDateTime();
        if ClientDiagnostic."Expiry Date" <> ExpirationDateTime then begin
            ClientDiagnostic."Expiry Date" := ExpirationDateTime;
            ClientDiagnostic."Expiry Date Last Updated" := CurrentDateTime();
        end;
        ClientDiagnostic."Expiry Date Last Checked" := CurrentDateTime();
        ClientDiagnostic.Modify();
        Commit();
    end;

    local procedure GetExpirationDateTime(): DateTime
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
        if not TryInitAndSendRequest('GetUserExpirationDate', UserId(), GetDatabaseName(), TenantId(), ExpirationDate) then
            exit(0DT);
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

    local procedure InitClientDiagnostic()
    begin
        if Initialized then
            exit;

        if ClientDiagnostic.Get(UserSecurityId()) then begin
            Initialized := true;
            exit;
        end;

        ClientDiagnostic.Init();
        ClientDiagnostic."User Security ID" := UserSecurityId();
        ClientDiagnostic.Insert();
        Initialized := true;
    end;

    local procedure PreventLoginIfUserIsExpired()
    var
        UserExpired: Label 'Your account has expired on %1. Expiration Message was: "%2". In order to continue, contact NaviPartner support or uninstall NP Retail extension.', Comment = '%1 = Expiration Date, %2 = Expiration Message';
    begin
        if ClientDiagnostic."Expiry Date" = 0DT then
            exit;

        if CurrentDateTime >= ClientDiagnostic."Expiry Date" then
            Error(UserExpired, ClientDiagnostic."Expiry Date", ClientDiagnostic."Expiration Message");
    end;

    local procedure TestUserLocked(ThrowAnError: Boolean)
    var
        LockedMessage: Text;
    begin
        UpdateUserLockedMessage(LockedMessage);
        if LockedMessage = '' then
            exit;

        if ThrowAnError then
            Error(LockedMessage)
        else
            Message(LockedMessage);
    end;

    local procedure UpdateUserLockedMessage(var LockedMessage: Text)
    var
        LockedMessageLastChecked: DateTime;
        DurationFromLastCheck: Duration;
        DurationCondition: Integer;
    begin
        InitClientDiagnostic();

        LockedMessageLastChecked := ClientDiagnostic."Locked Message Last Checked";
        if LockedMessageLastChecked = 0DT then
            Evaluate(LockedMessageLastChecked, '1970-01-01T00:00:00Z', 9);

        //In order to reduce number of calls to externall services (case system), send the request on login only:
        //  if user wasn't locked and if last check was done more than an hour ago
        //  but if user was set to be locked (and now it should be unlocked) skip checking if an hour has passed and send the request
        DurationFromLastCheck := CurrentDateTime() - LockedMessageLastChecked;
        DurationCondition := 1000 * 60 * 60; //miliseconds * seconds * minutes = one hour

        if (ClientDiagnostic."Locked Message" = '') and (DurationFromLastCheck <= DurationCondition) then
            exit;

        if not TryInitAndSendRequest('GetUserLockedMessage', UserId(), GetDatabaseName(), TenantId(), LockedMessage) then
            exit;

        if LowerCase(LockedMessage) = 'false' then
            LockedMessage := '';

        if ClientDiagnostic."Locked Message" <> LockedMessage then begin
            ClientDiagnostic."Locked Message" := CopyStr(LockedMessage, 1, MaxStrLen(ClientDiagnostic."Locked Message"));
            ClientDiagnostic."Locked Message Last Updated" := CurrentDateTime();
        end;
        ClientDiagnostic."Locked Message Last Checked" := CurrentDateTime();
        ClientDiagnostic.Modify();
        Commit();
    end;

    [TryFunction]
    local procedure TryTestUserLocked()
    begin
        TestUserLocked(true);
    end;

    local procedure SendPosUnitQty()
    var
        TenantDiagnostic: Record "NPR Tenant Diagnostic";
        PosStore: Record "NPR POS Store";
        PosUnit: Record "NPR POS Unit";
        ResponseMessage: Text;
        ShouldSendRequest: Boolean;
    begin
        InitTenantDiagnostic(TenantDiagnostic);

        //In order to reduce number of calls to externall services (case system), send the request on login only:
        //  if it wasn't sent at least once in the past (because of initial sync after new App version is installed or new company is created) 
        //  and when there is a difference between current POS Store qty and POS Store qty previously sent through API. (same condition for POS Unit)
        if (TenantDiagnostic."POS Units Last Sent" = 0DT) or (TenantDiagnostic."POS Stores Last Sent" = 0DT) then begin
            ShouldSendRequest := true;
            TenantDiagnostic."POS Stores" := PosStore.Count();
            TenantDiagnostic."POS Units" := PosUnit.Count();
            TenantDiagnostic."POS Stores Last Updated" := CurrentDateTime();
            TenantDiagnostic."POS Units Last Updated" := CurrentDateTime();
        end;

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

    local procedure InitTenantDiagnostic(var TenantDiagnostic: Record "NPR Tenant Diagnostic")
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        if not TenantDiagnostic.Get(TenantId()) then begin
            TenantDiagnostic.Init();
            TenantDiagnostic."Tenant ID" := CopyStr(TenantId(), 1, MaxStrLen(TenantDiagnostic."Tenant ID"));
            TenantDiagnostic."Azure AD Tenant ID" := CopyStr(AzureADTenant.GetAadTenantId(), 1, MaxStrLen(TenantDiagnostic."Azure AD Tenant ID"));
            TenantDiagnostic.Insert();
        end;
    end;

    [TryFunction]
    local procedure TryInitAndSendRequest(serviceMethod: Text; ThisUserId: Text; DatabaseName: Text; ThisTenantId: Text; var responseMessage: Text)
    var
        Content: HttpContent;
    begin
        Content.WriteFrom(InitRequestContent(serviceMethod, ThisUserId, DatabaseName, ThisTenantId));
        TrySendRequest(Content, serviceMethod, responseMessage)
    end;

    [TryFunction]
    local procedure TryInitAndSendRequest(serviceMethod: Text; DatabaseName: Text; ThisTenantId: Text; ThisCompanyName: Text; ThisPosStores: Text; ThisPosUnits: Text; var responseMessage: Text)
    var
        Content: HttpContent;
    begin
        Content.WriteFrom(InitRequestContent(serviceMethod, DatabaseName, ThisTenantId, ThisCompanyName, ThisPosStores, ThisPosUnits));
        TrySendRequest(Content, serviceMethod, responseMessage)
    end;

    [TryFunction]
    local procedure TrySendRequest(var Content: HttpContent; serviceMethod: Text; var responseMessage: Text)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Client: HttpClient;
        Response: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
    begin
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeaders.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser:' + serviceMethod);
        ContentHeaders.Add('Ocp-Apim-Subscription-Key', AzureKeyVaultMgt.GetAzureKeyVaultSecret('CaseSystemBCPhoneHomeAzureAPIKey'));
        Client.Timeout(5000);

        if not Client.Post('https://api.navipartner.dk/ServiceTierUser', Content, Response) then
            Error(GetLastErrorText);

        if not Response.IsSuccessStatusCode then
            Error(Format(Response.HttpStatusCode));

        Response.Content().ReadAs(responseMessage);
        responseMessage := GetWebResponseResult(responseMessage);
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

    local procedure GetWebResponseResult(response: Text) ResponseText: Text
    var
        XmlDoc: XmlDocument;
        XmlNode: XmlNode;
        XmlNamespace: XmlNamespaceManager;
    begin
        XmlDocument.ReadFrom(response, XmlDoc);
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestUserOnPOSSessionInitialize(UsingRegularInvoicing: Boolean; var Handled: Boolean)
    begin
    end;
}

codeunit 6014590 "NPR Service Tier User Mgt."
{
    Access = Internal;

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

    local procedure ValidateBCOnlineTenant()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        ResponseMessage: Text;
    begin
        if not EnvironmentInformation.IsSaaS() then
            exit;

        if not TrySendRequest('ValidateBCOnlineTenant', '', '', TenantId(), ResponseMessage) then
            exit;
    end;

    local procedure TestUserOnLogin()
    var
        Handled: Boolean;
    begin
        OnBeforeTestUserOnLogin(IsUsingRegularInvoicing(), Handled);
        if Handled then
            exit;

        TestUserExpired();
        TestUserLocked(false);
    end;

    local procedure TestUserOnPOSSessionInitialize()
    var
        POSSession: Codeunit "NPR POS Session";
        Handled: Boolean;
    begin
        OnBeforeTestUserOnPOSSessionInitialize(IsUsingRegularInvoicing(), Handled);
        if Handled then
            exit;

        TestUserExpired();
        if not TryTestUserLocked() then
            POSSession.SetErrorOnInitialize(true);
    end;

    local procedure IsUsingRegularInvoicing(): Boolean
    var
        UsingRegularInvoicing: Boolean;
        UseRegularInvoicing: Text;
    begin
        if not TrySendRequest('GetTenantUseRegularInvoicing', '', '', TenantId(), UseRegularInvoicing) then
            exit;

        if UseRegularInvoicing = '' then
            exit(false);

        if not Evaluate(UsingRegularInvoicing, UseRegularInvoicing) then
            exit(false);

        exit(UsingRegularInvoicing);
    end;

    local procedure TestUserExpired()
    var
        ExpirationMessage: Text;
    begin
        if not TrySendRequest('GetUserExpirationMessage', UserId(), GetDatabaseName(), TenantId(), ExpirationMessage) then
            exit;
        if ExpirationMessage = '' then
            exit;

        if LowerCase(ExpirationMessage) <> 'false' then
            Message(ExpirationMessage);
        UpdateExpirationDate();
    end;

    local procedure UpdateExpirationDate()
    var
        User: Record User;
    begin
        User.Get(UserSecurityId());
        User."Expiry Date" := GetExpirationDateTime();
        User.Modify();
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
        if not TrySendRequest('GetUserExpirationDate', UserId(), GetDatabaseName(), TenantId(), ExpirationDate) then
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

    local procedure TestUserLocked(ThrowAnError: Boolean)
    var
        LockedMessage: Text;
    begin
        if not TrySendRequest('GetUserLockedMessage', UserId(), GetDatabaseName(), TenantId(), LockedMessage) then
            exit;
        if LockedMessage = '' then
            exit;

        if LowerCase(LockedMessage) <> 'false' then
            if ThrowAnError then
                Error(LockedMessage)
            else
                Message(LockedMessage);
    end;

    [TryFunction]
    local procedure TryTestUserLocked()
    begin
        TestUserLocked(true);
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure TrySendRequest(serviceMethod: Text; ThisUserId: Text; DatabaseName: Text; ThisTenantId: Text; var responseMessage: Text)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Client: HttpClient;
        Response: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        Content: HttpContent;
    begin
        Content.WriteFrom(InitRequestContent(serviceMethod, ThisUserId, DatabaseName, ThisTenantId));

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
    local procedure OnBeforeTestUserOnLogin(UsingRegularInvoicing: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestUserOnPOSSessionInitialize(UsingRegularInvoicing: Boolean; var Handled: Boolean)
    begin
    end;
}

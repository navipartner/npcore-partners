codeunit 6014590 "NPR Service Tier User Mgt."
{
    Access = Internal;
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
           (activeSession."Session ID" = SessionId()) then
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

    local procedure TestUserExpired()
    var
        ExpirationMessage: Text;
    begin
        if not TrySendRequest('GetUserExpirationMessage', ExpirationMessage) then
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
        if not TrySendRequest('GetUserExpirationDate', ExpirationDate) then
            exit(0DT);
        if (ExpirationDate = '') OR (ExpirationDate = '0001-01-01T00:00:00') then
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

    local procedure TestUserLocked()
    var
        LockedMessage: Text;
    begin
        if not TrySendRequest('GetUserLockedMessage', LockedMessage) then
            exit;
        if LockedMessage = '' then
            exit;

        if LowerCase(LockedMessage) <> 'false' then
            Error(LockedMessage);
    end;

    [NonDebuggable]
    [TryFunction]
    local procedure TrySendRequest(serviceMethod: text; var responseMessage: Text)
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        Content: HttpContent;
    begin
        Content.WriteFrom(
          '<?xml version="1.0" encoding="UTF-8"?>' +
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" >' +
              '<soapenv:Header/>' +
              '<soapenv:Body>' +
                  '<' + serviceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser">' +
                      '<usernameIn>' + UserId + '</usernameIn>' +
                      '<databaseNameIn>' + GetDatabaseName() + '</databaseNameIn>' +
                      '<tenantIDIn>' + TenantId() + '</tenantIDIn>' +
                  '</' + serviceMethod + '>' +
              '</soapenv:Body>' +
          '</soapenv:Envelope>');

        Content.GetHeaders(contentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeaders.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser:' + serviceMethod);
        ContentHeaders.Add('Ocp-Apim-Subscription-Key', GetAzureKeyVaultSecret('CaseSystemBCPhoneHomeAzureAPIKey'));
        Client.Timeout(5000);

        if not Client.Post('https://api.navipartner.dk/ServiceTierUser', Content, Response) then
            Error(GetLastErrorText);

        if not response.IsSuccessStatusCode then
            Error(format(response.HttpStatusCode));

        Response.Content().ReadAs(responseMessage);
        responseMessage := GetWebResponseResult(responseMessage);
    end;

    local procedure GetWebResponseResult(response: Text) ResponseText: Text
    var
        XmlDoc: XmlDocument;
        XmlNode: XMLNode;
        XmlNamespace: XmlNamespaceManager;
    begin
        XmlDocument.ReadFrom(response, XmlDoc);
        XmlNamespace.AddNamespace('BC', 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser');
        XmlDoc.SelectSingleNode('//BC:return_value', XmlNamespace, XmlNode);
        ResponseText := XmlNode.AsXmlElement().InnerText;
        exit(ResponseText);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeLogInStart', '', true, false)]
    local procedure OnBeforeLogInStart()
    var
        EnvironmentHandler: Codeunit "NPR Environment Handler";
    begin
        if NavApp.IsInstalling() then
            exit;

        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop]) then
            exit;

        EnvironmentHandler.EnableAllowHttpInSandbox();

        TestUserExpired();
        TestUserLocked();
    end;

    [NonDebuggable]
    local procedure GetAzureKeyVaultSecret(Name: Text) KeyValue: Text
    var
        AppKeyVaultSecretProvider: Codeunit "App Key Vault Secret Provider";
        InMemorySecretProvider: Codeunit "In Memory Secret Provider";
        TextMgt: Codeunit "NPR Text Mgt.";
        AppKeyVaultSecretProviderInitialised: Boolean;
    begin
        if not InMemorySecretProvider.GetSecret(Name, KeyValue) then begin
            if not AppKeyVaultSecretProviderInitialised then
                AppKeyVaultSecretProviderInitialised := AppKeyVaultSecretProvider.TryInitializeFromCurrentApp();

            if not AppKeyVaultSecretProviderInitialised then
                Error(GetLastErrorText());

            if AppKeyVaultSecretProvider.GetSecret(Name, KeyValue) then
                InMemorySecretProvider.AddSecret(Name, KeyValue)
            else
                Error(TextMgt.GetSecretFailedErr(), Name);
        end;
    end;
}

codeunit 6014590 "NPR Service Tier User Mgt."
{
    local procedure GetDatabaseName(): Text
    var
        activeSession: Record "Active Session";
    begin
        FindMySession(activeSession);
        exit(activeSession."Database Name")
    end;

    local procedure FindMySession(activeSession: Record "Active Session")
    var
        Itt: Integer;
    begin
        if (activeSession."Server Instance ID" = ServiceInstanceId) and
           (activeSession."Session ID" = SessionId) then
            exit;

        while (not activeSession.Get(ServiceInstanceId, SessionId)) do begin
            Sleep(10);
            Itt += 1;
            if Itt > 50 then begin
                if not GuiAllowed then
                    exit;
                activeSession.Get(ServiceInstanceId, SessionId);
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
        if LowerCase(ExpirationMessage) = 'false' then
            exit;

        Message(ExpirationMessage);
    end;

    local procedure TestUserLocked()
    var
        LockedMessage: Text;
    begin
        if not TrySendRequest('GetUserLockedMessage', LockedMessage) then
            exit;
        if LockedMessage = '' then
            exit;
        if LowerCase(LockedMessage) = 'false' then
            exit;

        Message(LockedMessage);
    end;

    [TryFunction]
    local procedure TrySendRequest(serviceMethod: text; var responseMessage: Text)
    var
        XmlDoc: XmlDocument;
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        Content: HttpContent;
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        Content.WriteFrom(
          '<?xml version="1.0" encoding="UTF-8"?>' +
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" >' +
              '<soapenv:Header/>' +
              '<soapenv:Body>' +
                  '<' + serviceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser">' +
                      '<usernameIn>' + UserId + '</usernameIn>' +
                      '<databaseNameIn>' + GetDatabaseName() + '</databaseNameIn>' +
                      '<tenantIDIn>' + TenantId + '</tenantIDIn>' +
                  '</' + serviceMethod + '>' +
              '</soapenv:Body>' +
          '</soapenv:Envelope>');

        Content.GetHeaders(contentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeaders.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser:' + serviceMethod);
        ContentHeaders.Add('Ocp-Apim-Subscription-Key', AzureKeyVaultMgt.GetSecret('CaseSystemBCPhoneHomeAzureAPIKey'));
        Client.Timeout(5000);

        if not Client.Post('https://api.navipartner.dk/ServiceTierUser', Content, Response) then
            Error(GetLastErrorText);

        if not response.IsSuccessStatusCode then
            Error(format(response.HttpStatusCode));

        Response.Content().ReadAs(responseMessage);
        responseMessage := GetWebResponseResult(responseMessage, serviceMethod);
    end;

    local procedure GetWebResponseResult(response: Text; ServiceMethod: Text) ResponseText: Text
    var
        XmlDoc: XmlDocument;
        PersonXmlNode: XmlNode;
        Text: Text;
        XmlNode: XMLNode;
        XmlNodeList: XMLNodeList;
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
        this: Codeunit "NPR Service Tier User Mgt.";
    begin
        if NavApp.IsInstalling() then
            exit;

        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop]) then
            exit;

        TestUserExpired();
        TestUserLocked();
    end;
}
codeunit 6014590 "NPR Service Tier User Mgt."
{
    trigger OnRun()
    begin
        if not GuiAllowed then exit;
        TestUserExpired();
        TestUserLocked();
    end;

    var
        ActiveSession: Record "Active Session";

    local procedure "-- Aux"()
    begin
    end;

    local procedure CloseNavision()
    var
        closenavisionpage: Page "NPR Close Navision";
    begin
        Commit;
        closenavisionpage.RunModal();
    end;

    local procedure GetUsername(): Text
    var
        Environment: Codeunit "NPR Environment Mgt.";
    begin
        FindMySession;
        exit(ActiveSession."User ID");
    end;

    local procedure GetDatabaseName(): Text
    begin
        FindMySession;
        exit(ActiveSession."Database Name")
    end;

    local procedure GetTenantID(): Text
    begin
        exit(TenantId);
    end;

    local procedure "-- Setup"()
    begin
    end;

    local procedure FindMySession()
    var
        Itt: Integer;
    begin
        if (ActiveSession."Server Instance ID" = ServiceInstanceId) and
           (ActiveSession."Session ID" = SessionId) then
            exit;

        while (not ActiveSession.Get(ServiceInstanceId, SessionId)) do begin
            Sleep(10);
            Itt += 1;
            if Itt > 50 then begin
                if not GuiAllowed then
                    exit;
                ActiveSession.Get(ServiceInstanceId, SessionId);
            end;
        end;
    end;

    local procedure "--Ws"()
    begin
    end;

    local procedure TestUserExpired()
    var
        ExpirationMessage: Text;
    begin
        if not TryGetUserExpirationMessage(ExpirationMessage) then
            exit;
        if ExpirationMessage = '' then
            exit;
        if LowerCase(ExpirationMessage) = 'false' then
            exit;

        Message(ExpirationMessage);
    end;

    [TryFunction]
    local procedure TryGetUserExpirationMessage(var ExpirationMessage: Text)
    var
        XmlDoc: XmlDocument;
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        Content: HttpContent;
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Uri: Text;
        ServiceMethod: Text;
    begin
        ServiceMethod := 'GetUserExpirationMessage';
        Uri := strsubstno('%1/ServiceTierUser', AzureKeyVaultMgt.GetSecret('ApiHostUri'));

        Content.WriteFrom(InitTestRequest(ServiceMethod));

        Content.GetHeaders(contentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeaders.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser:' + ServiceMethod);
        ContentHeaders.Add('Ocp-Apim-Subscription-Key', '75b39a018dbf40fa83f9470a9eafe854');
        Client.Timeout(5000);

        if not Client.Post(Uri, Content, Response) then
            Error(GetLastErrorText);

        if not response.IsSuccessStatusCode then
            Error(format(response.HttpStatusCode));

        Response.Content().ReadAs(ExpirationMessage);
        ExpirationMessage := GetWebResponseResult(ExpirationMessage, ServiceMethod);
    end;

    local procedure InitTestRequest(ServiceMethod: Text): Text
    var
        UsernameIn: Text;
        DatabaseNameIn: Text;
        TenantIDIn: Text;
    begin
        UsernameIn := GetUsername();
        DatabaseNameIn := GetDatabaseName();
        TenantIDIn := GetTenantID();

        exit(
          '<?xml version="1.0" encoding="UTF-8"?>' +
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" >' +
          '   <soapenv:Header/>' +
          '   <soapenv:Body>' +
          '      <' + ServiceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser">' +
          '            <usernameIn>' + UsernameIn + '</usernameIn>' +
          '            <databaseNameIn>' + DatabaseNameIn + '</databaseNameIn>' +
          '            <tenantIDIn>' + TenantIDIn + '</tenantIDIn>' +
          '      </' + ServiceMethod + '>' +
          '   </soapenv:Body>' +
          '</soapenv:Envelope>');
    end;

    local procedure TestUserLocked()
    var
        LockedMessage: Text;
    begin
        if not TryGetUserLockedMessage(LockedMessage) then
            exit;
        if LockedMessage = '' then
            exit;
        if LowerCase(LockedMessage) = 'false' then
            exit;

        CloseNavision();
    end;

    [TryFunction]
    local procedure TryGetUserLockedMessage(var ExpirationMessage: Text)
    var
        XmlDoc: XmlDocument;
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        ContentHeaders: HttpHeaders;
        Content: HttpContent;
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Uri: Text;
        ServiceMethod: Text;
    begin
        ServiceMethod := 'GetUserLockedMessage';
        Uri := strsubstno('%1/ServiceTierUser', AzureKeyVaultMgt.GetSecret('ApiHostUri'));

        Content.WriteFrom(InitTestRequest(ServiceMethod));

        Content.GetHeaders(contentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeaders.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser:' + ServiceMethod);
        ContentHeaders.Add('Ocp-Apim-Subscription-Key', '75b39a018dbf40fa83f9470a9eafe854');
        Client.Timeout(5000);

        if not Client.Post(Uri, Content, Response) then
            Error(GetLastErrorText);

        if not response.IsSuccessStatusCode then
            Error(format(response.HttpStatusCode));

        Response.Content().ReadAs(ExpirationMessage);
        ExpirationMessage := GetWebResponseResult(ExpirationMessage, ServiceMethod);
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
}


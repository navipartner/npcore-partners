codeunit 6014590 "NPR Service Tier User Mgt."
{
    // NPR4.14/HSK /20152906  CASE 216503 Add IP Address and change the login method
    // NPR4.14/JDH /20150706  CASE 218049 Changed how My session is found, since it was loaded from server multible times
    // NPR4.14/JDH /20150930  CASE 224331 Switched the IP Log off, since it wasnt working
    // NPR4.15/LS  /20151008  CASE 223428 correcting to register Login, Logout Date/Time + IP Address
    // NPR5.23/MHA /20160426  CASE 239972 Added exception to FindMySession() In case of rapid logins when NOT GUIALLOWED
    // NPR5.23/TTH /20160520              Checking for clienttype to allow the web client to Invoke web service to record time to Case system
    // NPR5.25/TJ  /20160617  CASE 233872 Changed calling of UserLogon to use service method UserLogon3 so we can send extra parameters
    // NPR5.26/CLVA/20160622  CASE 244800 Added function IsUserWebClient
    // NPR5.26/JDH /20160919  CASE 248141 Deleted unused text constants
    // NPR5.38/CLVA/20170622  CASE 300166 Added functions SetUserLicenseName and SearchForLicensText
    // NPR5.38/MHA /20180105  CASE 301053 Removed unused automation variable, nodelist, from OnRun()
    // NPR5.38/MHA /20180108  CASE 298399 Added functions for tracking POSClientType: SetPOSClientType(),OnOpenPOSStandard(),OnOpenPOSTranscendence()
    // NPR5.38.02/JDH/20180207 Removed reference to CU that was deleted
    // NPR5.40/MMV /20180314  CASE 307453 Refactored FindMySession -> shorter sleeps and no cache skip.
    // NPR5.40/MHA /20180328  CASE 308907 Data Collection functions moved to Cu 6059998 "Client Diagnostics Data Mgt."
    // NPR5.40/MHA /20180328  CASE 308968 Replaced special char with html code in SetWebserviceInfo()
    // NPR5.44/CLVA/20180716  CASE 322085 Added TryTestUserExpired and TryTestUserLocked to support try/catch
    // NPR5.49/MHA /20190206  CASE 344580 Changed Try functions to actual Try functions
    // NPR5.49/MHA /20190206  CASE 340731 Changed WS endpoint to Azure Api Management, removed deprecated WebInvoke functionality, and cleared green code


    trigger OnRun()
    begin
        if not GuiAllowed then exit;

        //-NPR5.49 [344580]
        TestUserExpired();
        TestUserLocked();
        //+NPR5.49 [322085]
    end;

    var
        NodeList: DotNet NPRNetXmlNodeList;
        Node: DotNet NPRNetXmlNode;
        ActiveSession: Record "Active Session";
        INVALIDXMLRESULT: Label 'XML is not valid';

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
        //-NPR5.49 [322085]
        if not TryGetUserExpirationMessage(ExpirationMessage) then
            exit;
        if ExpirationMessage = '' then
            exit;
        if LowerCase(ExpirationMessage) = 'false' then
            exit;

        Message(ExpirationMessage);
        //+NPR5.49 [322085]
    end;

    [TryFunction]
    local procedure TryGetUserExpirationMessage(var ExpirationMessage: Text)
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        Uri: DotNet NPRNetUri;
        WebException: DotNet NPRNetWebException;
        XmlDoc: DotNet "NPRNetXmlDocument";
        ServiceMethod: Text;
    begin
        //-NPR5.49 [340731]
        ServiceMethod := 'GetUserExpirationMessage';
        Uri := Uri.Uri('https://api.navipartner.dk/ServiceTierUser');
        HttpWebRequest := HttpWebRequest.Create(Uri);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser:' + ServiceMethod);
        HttpWebRequest.Headers.Add('Ocp-Apim-Subscription-Key', '75b39a018dbf40fa83f9470a9eafe854');
        HttpWebRequest.Timeout(5000);

        InitTestRequest(ServiceMethod, XmlDoc);

        if not NpXmlDomMgt.SendWebRequest(XmlDoc, HttpWebRequest, HttpWebResponse, WebException) then
            Error(GetLastErrorText);

        ExpirationMessage := GetWebResponseResult(HttpWebResponse, ServiceMethod);
        //+NPR5.49 [340731]
    end;

    local procedure TestUserLocked()
    var
        LockedMessage: Text;
    begin
        //-NPR5.49 [322085]
        if not TryGetUserLockedMessage(LockedMessage) then
            exit;
        if LockedMessage = '' then
            exit;
        if LowerCase(LockedMessage) = 'false' then
            exit;

        CloseNavision();
        //+NPR5.49 [322085]
    end;

    [TryFunction]
    local procedure TryGetUserLockedMessage(var ExpirationMessage: Text)
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        Uri: DotNet NPRNetUri;
        WebException: DotNet NPRNetWebException;
        XmlDoc: DotNet "NPRNetXmlDocument";
        ServiceMethod: Text;
    begin
        //-NPR5.49 [340731]
        ServiceMethod := 'GetUserLockedMessage';
        Uri := Uri.Uri('https://api.navipartner.dk/ServiceTierUser');
        HttpWebRequest := HttpWebRequest.Create(Uri);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser:' + ServiceMethod);
        HttpWebRequest.Headers.Add('Ocp-Apim-Subscription-Key', '75b39a018dbf40fa83f9470a9eafe854');
        HttpWebRequest.Timeout(5000);

        InitTestRequest(ServiceMethod, XmlDoc);

        if not NpXmlDomMgt.SendWebRequest(XmlDoc, HttpWebRequest, HttpWebResponse, WebException) then
            Error(GetLastErrorText);

        ExpirationMessage := GetWebResponseResult(HttpWebResponse, ServiceMethod);
        //+NPR5.49 [340731]
    end;

    local procedure InitTestRequest(ServiceMethod: Text; var XmlDoc: DotNet "NPRNetXmlDocument")
    var
        UsernameIn: Text;
        DatabaseNameIn: Text;
        TenantIDIn: Text;
    begin
        //-NPR5.44 [322085]
        UsernameIn := GetUsername();
        DatabaseNameIn := GetDatabaseName();
        TenantIDIn := GetTenantID();

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<?xml version="1.0" encoding="UTF-8"?>' +
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" >' +
          '   <soapenv:Header/>' +
          '   <soapenv:Body>' +
          //-NPR5.49 [340731]
          '      <' + ServiceMethod + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser">' +
          //+NPR5.49 [340731]
          '            <usernameIn>' + UsernameIn + '</usernameIn>' +
          '            <databaseNameIn>' + DatabaseNameIn + '</databaseNameIn>' +
          '            <tenantIDIn>' + TenantIDIn + '</tenantIDIn>' +
          '      </' + ServiceMethod + '>' +
          '   </soapenv:Body>' +
          '</soapenv:Envelope>');
        //+NPR5.44 [322085]
    end;

    local procedure GetWebResponseResult(HttpWebResponse: DotNet NPRNetHttpWebResponse; ServiceMethod: Text) ResponseText: Text
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDocOut: DotNet "NPRNetXmlDocument";
    begin
        //-NPR5.44 [322085]
        XmlDocOut := XmlDocOut.XmlDocument;
        XmlDocOut.Load(HttpWebResponse.GetResponseStream());
        //+NPR5.44 [322085]
        //-NPR5.49 [340731]
        NpXmlDomMgt.RemoveNameSpaces(XmlDocOut);
        ResponseText := NpXmlDomMgt.GetXmlText(XmlDocOut.DocumentElement, '//return_value', 0, true);
        exit(ResponseText);
        //+NPR5.49 [340731]
    end;
}


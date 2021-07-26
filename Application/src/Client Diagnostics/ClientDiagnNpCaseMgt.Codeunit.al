codeunit 6059999 "NPR Client Diagn. NpCase Mgt."
{
    trigger OnRun()
    begin
        SendClientDiagnostics();
    end;

    var
        UserLoggedOut: Boolean;

    local procedure SendClientDiagnostics()
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDoc: XmlDocument;
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        Response: HttpResponseMessage;
        ContentText: Text;
        Uri: Text;
        ErrorMessage: Text;
        Document: XmlDocument;
        Node: XmlNode;
    begin
        Uri := 'https://api.navipartner.dk/ClientDiagnostics';

        InitRequest(XmlDoc);

        XmlDoc.WriteTo(ContentText);
        RequestContent.WriteFrom(ContentText);
        RequestContent.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=UTF-8');
        ContentHeader.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/ClientDiagnostics:UpsertUser');
        ContentHeader.Add('Ocp-Apim-Subscription-Key', '0deed0dee9e44975827b623077b875e0');

        Client.Timeout(5000);
        Client.Post(Uri, RequestContent, Response);

        if not Response.IsSuccessStatusCode then begin
            Response.Content().ReadAs(ErrorMessage);
            if XmlDocument.ReadFrom(ErrorMessage, Document) then begin
                if NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//faultstring', Node) then
                    ErrorMessage := Node.AsXmlElement().InnerText();
            end;

            Error(CopyStr(ErrorMessage, 1, 1020));
        end;
    end;

    local procedure InitRequest(var XmlDoc: XmlDocument)
    var
        ActiveSession: Record "Active Session";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Node: XmlNode;
        Element: XmlElement;
        MethodName: Text;
        MethodNS: Text;
        Xml: Text;
    begin
        FindMySession(ActiveSession);

        MethodName := 'UpsertUser';
        MethodNS := 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser';

        Xml :=
          '<?xml version="1.0" encoding="UTF-8"?>' +
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" >' +
          '   <soapenv:Header/>' +
          '   <soapenv:Body>' +
          '      <' + MethodName + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ClientDiagnostics">' +
          '         <nav_service_tier_user>' +
          '            <NAVServiceTierUser xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser" />' +
          '         </nav_service_tier_user>' +
          '      </' + MethodName + '>' +
          '   </soapenv:Body>' +
          '</soapenv:Envelope>';
        XmlDocument.ReadFrom(Xml, XmlDoc);

        XmlDoc.SelectSingleNode('.//*[local-name()="NAVServiceTierUser"]', Node);
        NpXmlDomMgt.AddAttribute(Node, 'username', UserId);
        NpXmlDomMgt.AddAttribute(Node, 'database_name', ActiveSession."Database Name");
        NpXmlDomMgt.AddAttribute(Node, 'tenant_id', Database.TenantId());

        Element := Node.AsXmlElement();
        MethodNS := Element.NamespaceUri();
        AppendLoginInfo(ActiveSession, MethodNS, Element);
        AppendLicenseInfo(ActiveSession, MethodNS, Element);
        AppendComputerInfo(ActiveSession, MethodNS, Element);
        AppendPosInfo(MethodNS, Element);
        AppendLogoutInfo(MethodNS, Element);
    end;

    local procedure AppendLoginInfo(ActiveSession: Record "Active Session"; MethodNS: Text; var Element: XmlElement)
    var
        User: Record User;
        IComm: Record "NPR I-Comm";
        SystemEventWrapper: Codeunit "NPR System Event Wrapper";
        XmlElementLoginInfo: XmlElement;
        UserLoginType: Text[10];
    begin
        if User.Get(ActiveSession."User SID") then;
        if IComm.Get() then;

        UserLoginType := 'NAV';
        if User."Windows Security ID" <> '' then
            UserLoginType := 'Windows';

        XmlElementLoginInfo := XmlElement.Create('login_info', MethodNS);
        XmlElementLoginInfo.Add(AddElement('last_logon_date', Format(Today(), 0, 9), MethodNS));
        XmlElementLoginInfo.Add(AddElement('last_logon_time', Format(Time(), 0, 9), MethodNS));
        XmlElementLoginInfo.Add(AddElement('full_name', User."Full Name", MethodNS));
        XmlElementLoginInfo.Add(AddElement('service_server_name', ActiveSession."Server Computer Name", MethodNS));
        XmlElementLoginInfo.Add(AddElement('service_instance', ActiveSession."Server Instance Name", MethodNS));
        XmlElementLoginInfo.Add(AddElement('company_name', CompanyName(), MethodNS));
        XmlElementLoginInfo.Add(AddElement('company_id', IComm."Customer No.", MethodNS));
        XmlElementLoginInfo.Add(AddElement('user_security_id', ActiveSession."User SID", MethodNS));
        XmlElementLoginInfo.Add(AddElement('windows_security_id', Format(User."Windows Security ID"), MethodNS));
        XmlElementLoginInfo.Add(AddElement('user_login_type', UserLoginType, MethodNS));
        XmlElementLoginInfo.Add(AddElement('application_version', SystemEventWrapper.ApplicationBuild(), MethodNS));

        Element.Add(XmlElementLoginInfo);
    end;

    local procedure AppendLicenseInfo(ActiveSession: Record "Active Session"; MethodNS: Text; var Element: XmlElement)
    var
        User: Record User;
        XmlElementLicenseInfo: XmlElement;
        LicenseType: Text;
    begin
        LicenseType := '';
        if User.Get(ActiveSession."User SID") then
            LicenseType := Format(User."License Type", 0, 2);

        XmlElementLicenseInfo := XmlElement.Create('license_info', MethodNS);
        XmlElementLicenseInfo.Add(AddElement('license_type', LicenseType, MethodNS));
        XmlElementLicenseInfo.Add(AddElement('license_name', SearchForLicenseText('Licensed to             : '), MethodNS));
        XmlElementLicenseInfo.Add(AddElement('no_of_full_users', Format(SearchForGranule('450'), 0, 9), MethodNS));
        XmlElementLicenseInfo.Add(AddElement('no_of_isv_users', Format(SearchForGranule('490'), 0, 9), MethodNS));
        XmlElementLicenseInfo.Add(AddElement('no_of_limited_users', Format(SearchForGranule('460'), 0, 9), MethodNS));

        Element.Add(XmlElementLicenseInfo);
    end;

    local procedure SearchForLicenseText(TextToFind: Text) InfoText: Text
    var
        LicenseInformation: Record "License Information";
    begin
        if TextToFind = '' then
            exit('');

        InfoText := '';
        LicenseInformation.SetFilter(Text, '%1*', TextToFind);
        if not LicenseInformation.FindFirst() then
            exit('');

        InfoText := DelStr(LicenseInformation.Text, 1, StrLen(TextToFind));
        exit(InfoText);
    end;

    local procedure SearchForGranule(GranuleIDText: Text) NoOfUsers: Integer
    var
        LicenseInfo: Record "License Information";
        LineFound: Boolean;
        InfoText: Text;
        NumberGroupSeparatorList: Text;
    begin
        NoOfUsers := 0;
        if LicenseInfo.FindSet() then
            repeat
                LineFound := StrPos(LicenseInfo.Text, GranuleIDText) = 1;
                if LineFound then begin
                    NumberGroupSeparatorList := '., ';
                    InfoText := DelChr(LicenseInfo.Text, '=', NumberGroupSeparatorList);
                    NoOfUsers += GetNoOfUsers(InfoText);
                end;
            until LicenseInfo.Next() = 0;
        exit(NoOfUsers);
    end;

    local procedure GetNoOfUsers(InputString: Text): Integer
    var
        Pattern: Text;
        Regex: Codeunit DotNet_Regex;
        IntFound: Integer;
        Match: Codeunit DotNet_Match;
        GroupCollection: Codeunit DotNet_GroupCollection;
        GroupOne: Codeunit DotNet_Group;
    begin
        Pattern := '.*?\d+.*?(\d+)';
        Regex.Regex(Pattern);
        Regex.Match(InputString, Match);
        if Match.Success() then begin
            Match.Groups(GroupCollection);
            GroupCollection.Item(1, GroupOne);
            if Evaluate(IntFound, GroupOne.Value()) then
                exit(IntFound);
        end;
        exit(0);
    end;

    local procedure AppendComputerInfo(ActiveSession: Record "Active Session"; MethodNS: Text; var Element: XmlElement)
    var
        XmlElementComputerInfo: XmlElement;
    begin
        XmlElementComputerInfo := XmlElement.Create('computer_info', MethodNS);
        XmlElementComputerInfo.Add(AddElement('client_name', ActiveSession."Client Computer Name", MethodNS));
        XmlElementComputerInfo.Add(AddElement('serial_number', SerialNumber(), MethodNS));
        XmlElementComputerInfo.Add(AddElement('os_version', '', MethodNS));
        XmlElementComputerInfo.Add(AddElement('mac_addresses', '', MethodNS));
        XmlElementComputerInfo.Add(AddElement('platform_version', '', MethodNS));

        Element.Add(XmlElementComputerInfo);
    end;

    local procedure AppendPosInfo(MethodNS: Text; var Element: XmlElement)
    var
        //GeoLocation: Codeunit Geolocation;
        GeoLatitude: Decimal;
        GeoLongitude: Decimal;
        XmlElementPosInfo: XmlElement;
    begin
        GeoLatitude := 0;
        GeoLongitude := 0;

        /*
        if GeoLocation.RequestGeolocation() then begin
            GeoLocation.GetGeolocation(GeoLatitude, GeoLongitude);
        end;
        */

        XmlElementPosInfo := XmlElement.Create('pos_info', MethodNS);
        XmlElementPosInfo.Add(AddElement('pos_client_type', '', MethodNS));
        XmlElementPosInfo.Add(AddElement('ip_address', '', MethodNS));
        XmlElementPosInfo.Add(AddElement('geolocation_latitude', Format(GeoLatitude, 0, 9), MethodNS));
        XmlElementPosInfo.Add(AddElement('geolocation_longitude', Format(GeoLongitude, 0, 9), MethodNS));

        Element.Add(XmlElementPosInfo);
    end;

    local procedure AppendLogoutInfo(MethodNS: Text; var Element: XmlElement)
    var
        XmlElementLogoutInfo: XmlElement;
    begin
        if not UserLoggedOut then
            exit;

        XmlElementLogoutInfo := XmlElement.Create('logout_info', MethodNS);
        XmlElementLogoutInfo.Add(AddElement('last_logout_date', Format(Today(), 0, 9), MethodNS));
        XmlElementLogoutInfo.Add(AddElement('last_logout_time', Format(Time(), 0, 9), MethodNS));

        Element.Add(XmlElementLogoutInfo);
    end;

    local procedure AddElement(Name: Text; ElementValue: Text; XmlNs: Text): XmlElement
    var
        Element: XmlElement;
    begin
        Element := XmlElement.Create(Name, XmlNs);
        Element.Add(ElementValue);
        exit(Element);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnBeforeLogInStart', '', true, false)]
    local procedure OnBeforeLogInStart()
    var
        NewSessionID: Integer;
    begin
        if not GuiAllowed then
            exit;

        if NavApp.IsInstalling() then
            exit;

        if not (CurrentClientType in [CLIENTTYPE::Windows, CLIENTTYPE::Web, CLIENTTYPE::Tablet, CLIENTTYPE::Phone, CLIENTTYPE::Desktop]) then
            exit;

        StartSession(NewSessionID, Codeunit::"NPR Client Diagn. NpCase Mgt.", CompanyName);
    end;
}


﻿codeunit 6059999 "NPR Client Diagn. NpCase Mgt."
{
    Access = Internal;

    var
        _ActiveSession: Record "Active Session";

    procedure CollectAndSendClientDiagnostics()
    var
        ClientDiagnostic: Record "NPR Client Diagnostic";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        if not ShouldSendClientDiagnostic(ClientDiagnostic) then
            exit;

        FindMySession(_ActiveSession);

        if not SendClientDiagnostics() then
            Error(GetLastErrorText())
        else begin
            ClientDiagnostic."Client Diagnostic Last Sent" := CurrentDateTime();
            if ClientDiagnostic.Modify() then
                Commit();
        end;
    end;

    local procedure ShouldSendClientDiagnostic(var ClientDiagnostic: Record "NPR Client Diagnostic"): Boolean
    var
        DiagnosticLastSent: DateTime;
        DurationFromLastRequest: Duration;
        DurationCondition: Integer;
    begin
        InitClientDiagnostic(ClientDiagnostic);

        DiagnosticLastSent := ClientDiagnostic."Client Diagnostic Last Sent";
        if DiagnosticLastSent = 0DT then
            Evaluate(DiagnosticLastSent, '1970-01-01T00:00:00Z', 9);

        //In order to reduce number of calls to externall services (case system), send the request on login only:
        //  if last check was done more than a hour ago        
        DurationFromLastRequest := CurrentDateTime() - DiagnosticLastSent;
        DurationCondition := 1000 * 60 * 60 * 1; //miliseconds * seconds * minutes * hours = one hour

        if DurationFromLastRequest <= DurationCondition then
            exit(false);

        exit(true);
    end;

    local procedure InitClientDiagnostic(var ClientDiagnostic: Record "NPR Client Diagnostic")
    begin
        if ClientDiagnostic.Get(UserSecurityId()) then
            exit;

        ClientDiagnostic.Init();
        ClientDiagnostic."User Security ID" := UserSecurityId();
        if ClientDiagnostic.Insert() then;
    end;

    [TryFunction]
    [NonDebuggable]
    local procedure SendClientDiagnostics()
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
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
        ContentHeader.Add('Ocp-Apim-Subscription-Key', AzureKeyVaultMgt.GetAzureKeyVaultSecret('ClientDiagnosticsKey'));

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
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        AzureADTenant: Codeunit "Azure AD Tenant";
        Node: XmlNode;
        Element: XmlElement;
        MethodName: Text;
        MethodNS: Text;
        Xml: Text;
    begin
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
        NpXmlDomMgt.AddAttribute(Node, 'username', CopyStr(UserId, 1, 260));
        NpXmlDomMgt.AddAttribute(Node, 'database_name', _ActiveSession."Database Name");
        NpXmlDomMgt.AddAttribute(Node, 'tenant_id', CopyStr(TenantId(), 1, 260));
        NpXmlDomMgt.AddAttribute(Node, 'azure_ad_tenant_id', CopyStr(AzureADTenant.GetAadTenantId(), 1, 260));

        Element := Node.AsXmlElement();
        MethodNS := Element.NamespaceUri();
        AppendLoginInfo(MethodNS, Element);
        AppendLicenseInfo(MethodNS, Element);
        AppendComputerInfo(MethodNS, Element);
    end;

    local procedure AppendLoginInfo(MethodNS: Text; var Element: XmlElement)
    var
        User: Record User;
        IComm: Record "NPR I-Comm";
        EnvironmentInformation: Codeunit "Environment Information";
        XmlElementLoginInfo: XmlElement;
        UserLoginType: Text[10];
    begin
        if User.Get(_ActiveSession."User SID") then;
        if IComm.Get() then;

        UserLoginType := 'NAV';
        if User."Windows Security ID" <> '' then
            UserLoginType := 'Windows';

        XmlElementLoginInfo := XmlElement.Create('login_info', MethodNS);
        XmlElementLoginInfo.Add(AddElement('last_logon_date', Format(Today(), 0, 9), MethodNS));
        XmlElementLoginInfo.Add(AddElement('last_logon_time', Format(Time(), 0, 9), MethodNS));
        XmlElementLoginInfo.Add(AddElement('full_name', User."Full Name", MethodNS));
        XmlElementLoginInfo.Add(AddElement('service_server_name', _ActiveSession."Server Computer Name", MethodNS));
        XmlElementLoginInfo.Add(AddElement('service_instance', _ActiveSession."Server Instance Name", MethodNS));
        XmlElementLoginInfo.Add(AddElement('company_name', CompanyName(), MethodNS));
        XmlElementLoginInfo.Add(AddElement('company_id', IComm."Customer No.", MethodNS));
        XmlElementLoginInfo.Add(AddElement('user_security_id', _ActiveSession."User SID", MethodNS));
        XmlElementLoginInfo.Add(AddElement('windows_security_id', Format(User."Windows Security ID"), MethodNS));
        XmlElementLoginInfo.Add(AddElement('user_login_type', UserLoginType, MethodNS));
        XmlElementLoginInfo.Add(AddElement('application_version', GetRetailVersion() + ' ' + GetBaseAppVersion(), MethodNS));
        XmlElementLoginInfo.Add(AddElement('environment_name', EnvironmentInformation.GetEnvironmentName(), MethodNS));
        XmlElementLoginInfo.Add(AddElement('pos_unit_no', GetPosUnitNo(), MethodNS));

        Element.Add(XmlElementLoginInfo);
    end;

    local procedure GetRetailVersion(): Text
    var
        NPRApp: ModuleInfo;
        RetailAppLabel: Label 'NPR: %1', Comment = '%1=Version', Locked = true;
    begin
        NavApp.GetCurrentModuleInfo(NPRApp);
        exit(StrSubstNo(RetailAppLabel, (format(NPRApp.AppVersion()))));
    end;

    local procedure GetBaseAppVersion(): Text
    var
        BaseAppModInfo: ModuleInfo;
        BaseAppLabel: Label 'Base: %1', Comment = '%1=Version', Locked = true;
        BaseAppID: Guid;
    begin
        BaseAppID := '437dbf0e-84ff-417a-965d-ed2bb9650972';
        NavApp.GetModuleInfo(BaseAppID, BaseAppModInfo);
        exit(StrSubstNo(BaseAppLabel, format(BaseAppModInfo.AppVersion())));
    end;

    local procedure GetPosUnitNo(): text[10]
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(CopyStr(UserId(), 1, MaxStrLen(UserSetup."User ID"))) then
            exit('');

        exit(UserSetup."NPR POS Unit No.");
    end;

    local procedure AppendLicenseInfo(MethodNS: Text; var Element: XmlElement)
    var
        User: Record User;
        XmlElementLicenseInfo: XmlElement;
        LicenseType: Integer;
    begin
        if User.Get(_ActiveSession."User SID") then
            LicenseType := User."License Type" + 1; //The case system field for license type has ordinal one higher than baseapp.

        XmlElementLicenseInfo := XmlElement.Create('license_info', MethodNS);
        XmlElementLicenseInfo.Add(AddElement('license_type', Format(LicenseType), MethodNS));
        XmlElementLicenseInfo.Add(AddElement('license_name', '', MethodNS));
        XmlElementLicenseInfo.Add(AddElement('no_of_full_users', '', MethodNS));
        XmlElementLicenseInfo.Add(AddElement('no_of_isv_users', '', MethodNS));
        XmlElementLicenseInfo.Add(AddElement('no_of_limited_users', '', MethodNS));

        Element.Add(XmlElementLicenseInfo);
    end;

    local procedure AppendComputerInfo(MethodNS: Text; var Element: XmlElement)
    var
        XmlElementComputerInfo: XmlElement;
    begin
        XmlElementComputerInfo := XmlElement.Create('computer_info', MethodNS);
        XmlElementComputerInfo.Add(AddElement('client_name', _ActiveSession."Client Computer Name", MethodNS));
        XmlElementComputerInfo.Add(AddElement('serial_number', SerialNumber(), MethodNS));
        XmlElementComputerInfo.Add(AddElement('os_version', '', MethodNS));
        XmlElementComputerInfo.Add(AddElement('mac_addresses', '', MethodNS));
        XmlElementComputerInfo.Add(AddElement('platform_version', '', MethodNS));

        Element.Add(XmlElementComputerInfo);
    end;

    local procedure AddElement(Name: Text; ElementValue: Text; XmlNs: Text): XmlElement
    var
        Element: XmlElement;
    begin
        Element := XmlElement.Create(Name, XmlNs);
        Element.Add(ElementValue);
        exit(Element);
    end;

    local procedure FindMySession(var ActiveSession: Record "Active Session")
    var
        Itt: Integer;
    begin
        if (ActiveSession."Server Instance ID" = ServiceInstanceId()) and
           (ActiveSession."Session ID" = SessionId()) then
            exit;

        while (not ActiveSession.Get(ServiceInstanceId(), SessionId())) do begin
            Sleep(10);
            Itt += 1;
            if Itt > 50 then begin
                ActiveSession.Get(ServiceInstanceId(), SessionId());
            end;
        end;
    end;
}


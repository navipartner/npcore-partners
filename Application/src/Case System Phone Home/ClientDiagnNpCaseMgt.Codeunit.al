codeunit 6059999 "NPR Client Diagn.NpCase Mgt"
{
    TableNo = "NPR Client Diagnostics";

    trigger OnRun()
    begin
        SendClientDiagnostics(Rec);
    end;

    var
        ActiveSession: Record "Active Session";
        ClientDiagnosticsDataMgt: Codeunit "NPR Client Diag. Data Mgt.";

    procedure ScheduleSendClientDiagnostics(ClientDiagnostics: Record "NPR Client Diagnostics")
    var
        NewSessionID: Integer;
    begin
        StartSession(NewSessionID, CODEUNIT::"NPR Client Diagn.NpCase Mgt", CompanyName, ClientDiagnostics);
    end;

    local procedure SendClientDiagnostics(ClientDiagnostics: Record "NPR Client Diagnostics")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        Credential: DotNet NPRNetNetworkCredential;
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        Uri: DotNet NPRNetUri;
        WebException: DotNet NPRNetWebException;
        XmlDoc: DotNet "NPRNetXmlDocument";
        MethodName: Text;
        ServiceName: Text;
        ErrorMessage: Text;
    begin
        Uri := Uri.Uri(AzureKeyVaultMgt.GetSecret('ApiHostUri'));
        Uri := Uri.Uri(Uri, 'ClientDiagnostics');

        HttpWebRequest := HttpWebRequest.Create(Uri);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction', 'urn:microsoft-dynamics-schemas/codeunit/ClientDiagnostics:UpsertUser');
        HttpWebRequest.Headers.Add('Ocp-Apim-Subscription-Key', AzureKeyVaultMgt.GetSecret('ClientDiagnosticsKey'));
        HttpWebRequest.Timeout(5000);

        InitRequest(ClientDiagnostics, XmlDoc);

        if not NpXmlDomMgt.SendWebRequest(XmlDoc, HttpWebRequest, HttpWebResponse, WebException) then begin
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            Error(CopyStr(ErrorMessage, 1, 1000));
        end;
    end;

    local procedure InitRequest(ClientDiagnostics: Record "NPR Client Diagnostics"; var XmlDoc: DotNet "NPRNetXmlDocument")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlElement: DotNet NPRNetXmlElement;
        XmlElement2: DotNet NPRNetXmlElement;
        XmlElementPosInfo: DotNet NPRNetXmlElement;
        MethodName: Text;
        MethodNS: Text;
    begin
        MethodName := 'UpsertUser';
        MethodNS := 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser';

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
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
          '</soapenv:Envelope>');

        XmlElement := XmlDoc.DocumentElement.LastChild.FirstChild.FirstChild.FirstChild;
        NpXmlDomMgt.AddAttribute(XmlElement, 'username', ClientDiagnostics.Username);
        NpXmlDomMgt.AddAttribute(XmlElement, 'database_name', ClientDiagnostics."Database Name");
        NpXmlDomMgt.AddAttribute(XmlElement, 'tenant_id', ClientDiagnostics."Tenant ID");

        AppendLoginInfo(ClientDiagnostics, MethodNS, XmlElement);
        AppendLicenseInfo(ClientDiagnostics, MethodNS, XmlElement);
        AppendComputerInfo(ClientDiagnostics, MethodNS, XmlElement);
        AppendPosInfo(ClientDiagnostics, MethodNS, XmlElement);
        AppendLogoutInfo(ClientDiagnostics, MethodNS, XmlElement);
    end;

    local procedure AppendLoginInfo(ClientDiagnostics: Record "NPR Client Diagnostics"; MethodNS: Text; var XmlElement: DotNet NPRNetXmlElement)
    var
        XmlElementNew: DotNet NPRNetXmlElement;
        XmlElementPosInfo: DotNet NPRNetXmlElement;
    begin
        if not ClientDiagnostics."Login Info" then
            exit;

        AddXmlElement(XmlElement, 'login_info', MethodNS, '', XmlElementPosInfo);

        AddXmlElement(XmlElementPosInfo, 'last_logon_date', MethodNS, Format(ClientDiagnostics."Last Logon Date", 0, 9), XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'last_logon_time', MethodNS, Format(ClientDiagnostics."Last Logon Time", 0, 9), XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'full_name', MethodNS, ClientDiagnostics."Full Name", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'service_server_name', MethodNS, ClientDiagnostics."Service Server Name", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'service_instance', MethodNS, ClientDiagnostics."Service Instance", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'company_name', MethodNS, ClientDiagnostics."Company Name", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'company_id', MethodNS, ClientDiagnostics."Company ID", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'user_security_id', MethodNS, ClientDiagnostics."User Security ID", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'windows_security_id', MethodNS, ClientDiagnostics."Windows Security ID", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'user_login_type', MethodNS, Format(ClientDiagnostics."User Login Type", 0, 2), XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'application_version', MethodNS, ClientDiagnostics."Application Version", XmlElementNew);
    end;

    local procedure AppendLicenseInfo(ClientDiagnostics: Record "NPR Client Diagnostics"; MethodNS: Text; var XmlElement: DotNet NPRNetXmlElement)
    var
        XmlElementNew: DotNet NPRNetXmlElement;
        XmlElementPosInfo: DotNet NPRNetXmlElement;
    begin
        if not ClientDiagnostics."License Info" then
            exit;

        AddXmlElement(XmlElement, 'license_info', MethodNS, '', XmlElementPosInfo);

        AddXmlElement(XmlElementPosInfo, 'license_type', MethodNS, Format(ClientDiagnostics."License Type", 0, 2), XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'license_name', MethodNS, ClientDiagnostics."License Name", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'no_of_full_users', MethodNS, Format(ClientDiagnostics."No. of Full Users", 0, 9), XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'no_of_isv_users', MethodNS, Format(ClientDiagnostics."No. of ISV Users", 0, 9), XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'no_of_limited_users', MethodNS, Format(ClientDiagnostics."No. of Limited Users", 0, 9), XmlElementNew);
    end;

    local procedure AppendComputerInfo(ClientDiagnostics: Record "NPR Client Diagnostics"; MethodNS: Text; var XmlElement: DotNet NPRNetXmlElement)
    var
        XmlElementNew: DotNet NPRNetXmlElement;
        XmlElementPosInfo: DotNet NPRNetXmlElement;
    begin
        if not ClientDiagnostics."Computer Info" then
            exit;

        AddXmlElement(XmlElement, 'computer_info', MethodNS, '', XmlElementPosInfo);

        AddXmlElement(XmlElementPosInfo, 'client_name', MethodNS, ClientDiagnostics."Client Name", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'serial_number', MethodNS, ClientDiagnostics."Serial Number", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'os_version', MethodNS, ClientDiagnostics."OS Version", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'mac_addresses', MethodNS, ClientDiagnostics."Mac Adresses", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'platform_version', MethodNS, ClientDiagnostics."Platform Version", XmlElementNew);
    end;

    local procedure AppendPosInfo(ClientDiagnostics: Record "NPR Client Diagnostics"; MethodNS: Text; var XmlElement: DotNet NPRNetXmlElement)
    var
        XmlElementNew: DotNet NPRNetXmlElement;
        XmlElementPosInfo: DotNet NPRNetXmlElement;
    begin
        if not ClientDiagnostics."POS Info" then
            exit;

        AddXmlElement(XmlElement, 'pos_info', MethodNS, '', XmlElementPosInfo);

        AddXmlElement(XmlElementPosInfo, 'pos_client_type', MethodNS, Format(ClientDiagnostics."POS Client Type", 0, 2), XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'ip_address', MethodNS, ClientDiagnostics."IP Address", XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'geolocation_latitude', MethodNS, Format(ClientDiagnostics."Geolocation Latitude", 0, 9), XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'geolocation_longitude', MethodNS, Format(ClientDiagnostics."Geolocation Longitude", 0, 9), XmlElementNew);
    end;

    local procedure AppendLogoutInfo(ClientDiagnostics: Record "NPR Client Diagnostics"; MethodNS: Text; var XmlElement: DotNet NPRNetXmlElement)
    var
        XmlElementNew: DotNet NPRNetXmlElement;
        XmlElementPosInfo: DotNet NPRNetXmlElement;
    begin
        if not ClientDiagnostics."Logout Info" then
            exit;

        AddXmlElement(XmlElement, 'logout_info', MethodNS, '', XmlElementPosInfo);

        AddXmlElement(XmlElementPosInfo, 'last_logout_date', MethodNS, Format(ClientDiagnostics."Last Logout Date", 0, 9), XmlElementNew);
        AddXmlElement(XmlElementPosInfo, 'last_logout_time', MethodNS, Format(ClientDiagnostics."Last Logout Time", 0, 9), XmlElementNew);
    end;

    local procedure AddXmlElement(var XmlElement: DotNet NPRNetXmlElement; ElementName: Text; Namespace: Text; InnerText: Text; var XmlElementNew: DotNet NPRNetXmlElement)
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
    begin
        NpXmlDomMgt.AddElementNamespace(XmlElement, ElementName, Namespace, XmlElementNew);
        XmlElementNew.InnerText := InnerText;
    end;
}
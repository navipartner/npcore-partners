codeunit 6059999 "Client Diagnostics NpCase Mgt."
{
    // NPR5.38/CLVA/20171109 CASE 293179 Collecting client-side information
    // NPR5.40/MHA /20180328 CASE 308907 Data Collection functions moved to Cu 6059998 "Client Diagnostics Data Mgt."
    // NPR5.49/MHA /20190206  CASE 340731 Changed WS endpoint to Azure Api Management
    // NPR5.50/MMV /20190529 CASE 356506 Skip message on success.

    TableNo = "Client Diagnostics";

    trigger OnRun()
    begin
        //-NPR5.40 [308907]
        SendClientDiagnostics(Rec);
        //+NPR5.40 [308907]
    end;

    var
        ActiveSession: Record "Active Session";
        ClientDiagnosticsDataMgt: Codeunit "Client Diagnostics Data Mgt.";

    procedure ScheduleSendClientDiagnostics(ClientDiagnostics: Record "Client Diagnostics")
    var
        NewSessionID: Integer;
    begin
        //-NPR5.40 [308907]
        StartSession(NewSessionID,CODEUNIT::"Client Diagnostics NpCase Mgt.",CompanyName,ClientDiagnostics);
        //+NPR5.40 [308907]
    end;

    local procedure SendClientDiagnostics(ClientDiagnostics: Record "Client Diagnostics")
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet NetworkCredential;
        HttpWebRequest: DotNet HttpWebRequest;
        HttpWebResponse: DotNet HttpWebResponse;
        Uri: DotNet Uri;
        WebException: DotNet WebException;
        XmlDoc: DotNet XmlDocument;
        MethodName: Text;
        ServiceName: Text;
    begin
        //-NPR5.40 [308907]
        //-NPR5.49 [340731]
        Uri := Uri.Uri('https://api.navipartner.dk/ClientDiagnostics');
        HttpWebRequest := HttpWebRequest.Create(Uri);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','urn:microsoft-dynamics-schemas/codeunit/ClientDiagnostics:UpsertUser');
        HttpWebRequest.Headers.Add('Ocp-Apim-Subscription-Key','0deed0dee9e44975827b623077b875e0');
        HttpWebRequest.Timeout(5000);

        InitRequest(ClientDiagnostics,XmlDoc);
        //+NPR5.49 [340731]

        //-NPR5.50 [356506]
        // IF NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) THEN
        //  MESSAGE('%1',NpXmlDomMgt.GetWebResponseText(HttpWebResponse))
        // ELSE
        //  ERROR('%1\\%2',NpXmlDomMgt.GetWebExceptionInnerMessage(WebException),NpXmlDomMgt.GetWebExceptionMessage(WebException));
        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then
          Error('%1\\%2',NpXmlDomMgt.GetWebExceptionInnerMessage(WebException),NpXmlDomMgt.GetWebExceptionMessage(WebException));
        //+NPR5.50 [356506]
        //+NPR5.40 [308907]
    end;

    local procedure InitRequest(ClientDiagnostics: Record "Client Diagnostics";var XmlDoc: DotNet XmlDocument)
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement: DotNet XmlElement;
        XmlElement2: DotNet XmlElement;
        XmlElementPosInfo: DotNet XmlElement;
        MethodName: Text;
        MethodNS: Text;
    begin
        //-NPR5.40 [308907]
        MethodName := 'UpsertUser';
        MethodNS := 'urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser';

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<?xml version="1.0" encoding="UTF-8"?>' +
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" >' +
          '   <soapenv:Header/>' +
          '   <soapenv:Body>' +
          //-NPR5.49 [340731]
          '      <' + MethodName + ' xmlns="urn:microsoft-dynamics-schemas/codeunit/ClientDiagnostics">' +
          //+NPR5.49 [340731]
          '         <nav_service_tier_user>' +
          '            <NAVServiceTierUser xmlns="urn:microsoft-dynamics-schemas/codeunit/ServiceTierUser" />' +
          '         </nav_service_tier_user>' +
          '      </' + MethodName + '>' +
          '   </soapenv:Body>' +
          '</soapenv:Envelope>');

        XmlElement := XmlDoc.DocumentElement.LastChild.FirstChild.FirstChild.FirstChild;
        NpXmlDomMgt.AddAttribute(XmlElement,'username',ClientDiagnostics.Username);
        NpXmlDomMgt.AddAttribute(XmlElement,'database_name',ClientDiagnostics."Database Name");
        NpXmlDomMgt.AddAttribute(XmlElement,'tenant_id',ClientDiagnostics."Tenant ID");

        AppendLoginInfo(ClientDiagnostics,MethodNS,XmlElement);
        AppendLicenseInfo(ClientDiagnostics,MethodNS,XmlElement);
        AppendComputerInfo(ClientDiagnostics,MethodNS,XmlElement);
        AppendPosInfo(ClientDiagnostics,MethodNS,XmlElement);
        AppendLogoutInfo(ClientDiagnostics,MethodNS,XmlElement);
        //+NPR5.40 [308907]
    end;

    local procedure AppendLoginInfo(ClientDiagnostics: Record "Client Diagnostics";MethodNS: Text;var XmlElement: DotNet XmlElement)
    var
        XmlElementNew: DotNet XmlElement;
        XmlElementPosInfo: DotNet XmlElement;
    begin
        //-NPR5.40 [308907]
        if not ClientDiagnostics."Login Info" then
          exit;

        AddXmlElement(XmlElement,'login_info',MethodNS,'',XmlElementPosInfo);

        AddXmlElement(XmlElementPosInfo,'last_logon_date',MethodNS,Format(ClientDiagnostics."Last Logon Date",0,9),XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'last_logon_time',MethodNS,Format(ClientDiagnostics."Last Logon Time",0,9),XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'full_name',MethodNS,ClientDiagnostics."Full Name",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'service_server_name',MethodNS,ClientDiagnostics."Service Server Name",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'service_instance',MethodNS,ClientDiagnostics."Service Instance",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'company_name',MethodNS,ClientDiagnostics."Company Name",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'company_id',MethodNS,ClientDiagnostics."Company ID",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'user_security_id',MethodNS,ClientDiagnostics."User Security ID",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'windows_security_id',MethodNS,ClientDiagnostics."Windows Security ID",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'user_login_type',MethodNS,Format(ClientDiagnostics."User Login Type",0,2),XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'application_version',MethodNS,ClientDiagnostics."Application Version",XmlElementNew);
        //+NPR5.40 [308907]
    end;

    local procedure AppendLicenseInfo(ClientDiagnostics: Record "Client Diagnostics";MethodNS: Text;var XmlElement: DotNet XmlElement)
    var
        XmlElementNew: DotNet XmlElement;
        XmlElementPosInfo: DotNet XmlElement;
    begin
        //-NPR5.40 [308907]
        if not ClientDiagnostics."License Info" then
          exit;

        AddXmlElement(XmlElement,'license_info',MethodNS,'',XmlElementPosInfo);

        AddXmlElement(XmlElementPosInfo,'license_type',MethodNS,Format(ClientDiagnostics."License Type",0,2),XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'license_name',MethodNS,ClientDiagnostics."License Name",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'no_of_full_users',MethodNS,Format(ClientDiagnostics."No. of Full Users",0,9),XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'no_of_isv_users',MethodNS,Format(ClientDiagnostics."No. of ISV Users",0,9),XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'no_of_limited_users',MethodNS,Format(ClientDiagnostics."No. of Limited Users",0,9),XmlElementNew);
        //+NPR5.40 [308907]
    end;

    local procedure AppendComputerInfo(ClientDiagnostics: Record "Client Diagnostics";MethodNS: Text;var XmlElement: DotNet XmlElement)
    var
        XmlElementNew: DotNet XmlElement;
        XmlElementPosInfo: DotNet XmlElement;
    begin
        //-NPR5.40 [308907]
        if not ClientDiagnostics."Computer Info" then
          exit;

        AddXmlElement(XmlElement,'computer_info',MethodNS,'',XmlElementPosInfo);

        AddXmlElement(XmlElementPosInfo,'client_name',MethodNS,ClientDiagnostics."Client Name",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'serial_number',MethodNS,ClientDiagnostics."Serial Number",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'os_version',MethodNS,ClientDiagnostics."OS Version",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'mac_addresses',MethodNS,ClientDiagnostics."Mac Adresses",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'platform_version',MethodNS,ClientDiagnostics."Platform Version",XmlElementNew);
        //+NPR5.40 [308907]
    end;

    local procedure AppendPosInfo(ClientDiagnostics: Record "Client Diagnostics";MethodNS: Text;var XmlElement: DotNet XmlElement)
    var
        XmlElementNew: DotNet XmlElement;
        XmlElementPosInfo: DotNet XmlElement;
    begin
        //-NPR5.40 [308907]
        if not ClientDiagnostics."POS Info" then
          exit;

        AddXmlElement(XmlElement,'pos_info',MethodNS,'',XmlElementPosInfo);

        AddXmlElement(XmlElementPosInfo,'pos_client_type',MethodNS,Format(ClientDiagnostics."POS Client Type",0,2),XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'ip_address',MethodNS,ClientDiagnostics."IP Address",XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'geolocation_latitude',MethodNS,Format(ClientDiagnostics."Geolocation Latitude",0,9),XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'geolocation_longitude',MethodNS,Format(ClientDiagnostics."Geolocation Longitude",0,9),XmlElementNew);
        //+NPR5.40 [308907]
    end;

    local procedure AppendLogoutInfo(ClientDiagnostics: Record "Client Diagnostics";MethodNS: Text;var XmlElement: DotNet XmlElement)
    var
        XmlElementNew: DotNet XmlElement;
        XmlElementPosInfo: DotNet XmlElement;
    begin
        //-NPR5.40 [308907]
        if not ClientDiagnostics."Logout Info" then
          exit;

        AddXmlElement(XmlElement,'logout_info',MethodNS,'',XmlElementPosInfo);

        AddXmlElement(XmlElementPosInfo,'last_logout_date',MethodNS,Format(ClientDiagnostics."Last Logout Date",0,9),XmlElementNew);
        AddXmlElement(XmlElementPosInfo,'last_logout_time',MethodNS,Format(ClientDiagnostics."Last Logout Time",0,9),XmlElementNew);
        //+NPR5.40 [308907]
    end;

    local procedure AddXmlElement(var XmlElement: DotNet XmlElement;ElementName: Text;Namespace: Text;InnerText: Text;var XmlElementNew: DotNet XmlElement)
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        //-NPR5.40 [308907]
        NpXmlDomMgt.AddElementNamespace(XmlElement,ElementName,Namespace,XmlElementNew);
        XmlElementNew.InnerText := InnerText;
        //+NPR5.40 [308907]
    end;
}


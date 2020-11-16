codeunit 6014697 "NPR Embedded Video Mgt."
{
    // NPR5.37/MHA /20171009  CASE 289471 Object created - Display Embedded Videos


    trigger OnRun()
    begin
    end;

    procedure ShowEmbeddedVideos(ModuleCode: Text)
    var
        EmbeddedVideos: Page "NPR Embedded Videos";
    begin
        EmbeddedVideos.SetModuleCode(ModuleCode);
        EmbeddedVideos.Run;
    end;

    procedure FindEmbeddedVideos(VideoModule: Code[20]; var EmbeddedVideoBuffer: Record "NPR Embedded Video Buffer" temporary): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        WebException: DotNet NPRNetWebException;
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        Response: Text;
    begin
        EmbeddedVideoBuffer.DeleteAll;

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="urn:microsoft-dynamics-schemas/codeunit/managed_nav_modules">' +
          '   <soapenv:Header/>' +
          '   <soapenv:Body>' +
          '      <GetEmbeddedVideos xmlns="urn:microsoft-dynamics-schemas/codeunit/embedded_video_service">' +
          '         <video_modules>' +
          '           <video_module code="' + VideoModule + '" />' +
          '         </video_modules>' +
          '      </GetEmbeddedVideos>' +
          '   </soapenv:Body>' +
          '</soapenv:Envelope>');

        InitEmbeddedVideoHttpWebRequest('GetEmbeddedVideos', HttpWebRequest);
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);
        if not NpXmlDomMgt.SendWebRequest(XmlDoc, HttpWebRequest, HttpWebResponse, WebException) then
            exit;

        Response := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        if Response = '' then
            exit;

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(Response);
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        if not NpXmlDomMgt.FindNode(XmlDoc.DocumentElement, 'Body/GetEmbeddedVideos_Result/video_modules/video_module', XmlElement) then
            exit;

        repeat
            ParseVideoModule2Buffer(XmlElement, EmbeddedVideoBuffer);
            XmlElement := XmlElement.NextSibling;
        until IsNull(XmlElement);

        exit(EmbeddedVideoBuffer.FindFirst);
    end;

    local procedure ParseVideoModule2Buffer(XmlElement: DotNet NPRNetXmlElement; var EmbeddedVideoBuffer: Record "NPR Embedded Video Buffer" temporary)
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlElement2: DotNet NPRNetXmlElement;
        ModuleCode: Code[20];
        ModuleName: Text[50];
        Columns: Integer;
    begin
        if XmlElement.Name <> 'video_module' then
            exit;

        if not NpXmlDomMgt.FindNode(XmlElement, 'videos/video', XmlElement2) then
            exit;

        ModuleCode := CopyStr(UpperCase(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'module_code', false)), 1, MaxStrLen(EmbeddedVideoBuffer."Module Code"));
        ModuleName := NpXmlDomMgt.GetXmlText(XmlElement, 'name', MaxStrLen(ModuleName), false);
        if not Evaluate(Columns, NpXmlDomMgt.GetXmlText(XmlElement, 'columns', 0, false), 9) then
            Columns := 1;

        repeat
            ParseVideo2Buffer(ModuleCode, ModuleName, Columns, XmlElement2, EmbeddedVideoBuffer);
            XmlElement2 := XmlElement2.NextSibling;
        until IsNull(XmlElement2);
    end;

    local procedure ParseVideo2Buffer(ModuleCode: Code[20]; ModuleName: Text[50]; Columns: Integer; XmlElement: DotNet NPRNetXmlElement; var EmbeddedVideoBuffer: Record "NPR Embedded Video Buffer" temporary)
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        LineNo: Integer;
    begin
        if XmlElement.Name <> 'video' then
            exit;

        if not Evaluate(LineNo, NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'line_no', false), 9) then
            exit;
        if EmbeddedVideoBuffer.Get(ModuleCode, LineNo) then
            exit;

        EmbeddedVideoBuffer.Init;
        EmbeddedVideoBuffer."Module Code" := ModuleCode;
        EmbeddedVideoBuffer."Module Name" := ModuleName;
        EmbeddedVideoBuffer.Columns := Columns;
        EmbeddedVideoBuffer."Line No." := LineNo;
        EmbeddedVideoBuffer."Video Html" := NpXmlDomMgt.GetXmlText(XmlElement, 'video_html', MaxStrLen(EmbeddedVideoBuffer."Video Html"), false);
        if Evaluate(EmbeddedVideoBuffer."Width (px)", NpXmlDomMgt.GetXmlText(XmlElement, 'width', 0, false), 9) then;
        if Evaluate(EmbeddedVideoBuffer."Height (px)", NpXmlDomMgt.GetXmlText(XmlElement, 'height', 0, false), 9) then;
        EmbeddedVideoBuffer.Insert;
    end;

    local procedure InitEmbeddedVideoHttpWebRequest(SoapAction: Text; var HttpWebRequest: DotNet NPRNetHttpWebRequest)
    var
        Credential: DotNet NPRNetNetworkCredential;
        Position: Text;
    begin
        HttpWebRequest := HttpWebRequest.Create('https://dev100.dynamics-retail.com:7107/NPmarketing/WS/NPmarketing/Codeunit/embedded_video_service');
        HttpWebRequest.Timeout := 1000 * 60;
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential('VIDEO_HTML_WS_USER', 'uixwyWOd+1');
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction', SoapAction);
    end;
}


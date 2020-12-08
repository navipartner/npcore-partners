codeunit 6014697 "NPR Embedded Video Mgt."
{
    procedure ShowEmbeddedVideos(ModuleCode: Text)
    var
        EmbeddedVideos: Page "NPR Embedded Videos";
    begin
        EmbeddedVideos.SetModuleCode(ModuleCode);
        EmbeddedVideos.Run();
    end;

    procedure FindEmbeddedVideos(VideoModule: Code[20]; var EmbeddedVideoBuffer: Record "NPR Embedded Video Buffer" temporary): Boolean
    var
        Document: XmlDocument;
        Element: XmlElement;
        Node: XmlNode;
        NodeList: XmlNodeList;
        Request, Response, XPathExcludeNamespacePattern : Text;
    begin
        EmbeddedVideoBuffer.DeleteAll();

        Request :=
          '<?xml version="1.0" encoding="utf-8"?>' +
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:man="urn:microsoft-dynamics-schemas/codeunit/managed_nav_modules">' +
          '   <soapenv:Header/>' +
          '   <soapenv:Body>' +
          '      <GetEmbeddedVideos xmlns="urn:microsoft-dynamics-schemas/codeunit/embedded_video_service">' +
          '         <video_modules>' +
          '           <video_module code="' + VideoModule + '" />' +
          '         </video_modules>' +
          '      </GetEmbeddedVideos>' +
          '   </soapenv:Body>' +
          '</soapenv:Envelope>';


        if not SendEmbeddedVideoHttpWebRequest('GetEmbeddedVideos', Request, Response) then
            exit;

        XmlDocument.ReadFrom(Response, Document);
        if not Document.GetRoot(Element) then
            exit;
        XPathExcludeNamespacePattern := '//*[local-name()=''%1'']';

        if not Element.SelectNodes(StrSubstNo(XPathExcludeNamespacePattern, 'video_modules'), NodeList) then
            exit;

        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            ParseVideoModule2Buffer(Element, EmbeddedVideoBuffer, XPathExcludeNamespacePattern);
        end;

        exit(EmbeddedVideoBuffer.FindFirst());
    end;

    local procedure ParseVideoModule2Buffer(Element: XmlElement; var EmbeddedVideoBuffer: Record "NPR Embedded Video Buffer" temporary; XPathExcludeNamespacePattern: Text)
    var
        NodeList: XmlNodeList;
        Node: XmlNode;
        Element2: XmlElement;
        Attribute: XmlAttribute;
        AttributeCollection: XmlAttributeCollection;
        ModuleCode, ModuleName : Text;
        Columns, i, LineNo : Integer;
    begin
        if not Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'video_module'), Node) then
            exit;

        Element2 := Node.AsXmlElement();
        if not Element2.HasAttributes() then
            exit;
        AttributeCollection := Element2.Attributes();
        if not AttributeCollection.get('code', Attribute) then
            exit;
        ModuleCode := Attribute.Value();

        if Element2.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'name'), Node) then
            ModuleName := Node.AsXmlElement().InnerText();

        if Element2.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'columns'), Node) then
            if Evaluate(Columns, Node.AsXmlElement().InnerText(), 9) then;
        if Columns = 0 then
            Columns := 1;

        if not Element2.SelectNodes(StrSubstNo(XPathExcludeNamespacePattern, 'video'), NodeList) then
            exit;

        foreach Node in NodeList do begin
            AttributeCollection := Node.AsXmlElement().Attributes();
            if AttributeCollection.Get('line_no', Attribute) then begin
                if Evaluate(LineNo, Attribute.Value(), 9) then
                    ParseVideo2Buffer(ModuleCode, ModuleName, LineNo, Columns, Node.AsXmlElement(), EmbeddedVideoBuffer, XPathExcludeNamespacePattern);
            end;
        end;
    end;

    local procedure ParseVideo2Buffer(ModuleCode: Text; ModuleName: Text; LineNo: Integer; Columns: Integer; Element: XmlElement; var EmbeddedVideoBuffer: Record "NPR Embedded Video Buffer" temporary; XPathExcludeNamespacePattern: Text)
    var
        Node: XmlNode;
    begin
        if EmbeddedVideoBuffer.Get(ModuleCode, LineNo) then
            exit;

        EmbeddedVideoBuffer.Init();
        EmbeddedVideoBuffer."Module Code" := ModuleCode;
        EmbeddedVideoBuffer."Module Name" := Copystr(ModuleName, 1, MaxStrLen(EmbeddedVideoBuffer."Module Name"));
        EmbeddedVideoBuffer.Columns := Columns;
        EmbeddedVideoBuffer."Line No." := LineNo;
        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'video_html'), Node) then
            EmbeddedVideoBuffer."Video Html" := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(EmbeddedVideoBuffer."Video Html"));
        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'width'), Node) then
            if evaluate(EmbeddedVideoBuffer."Width (px)", Node.AsXmlElement().InnerText(), 9) then;
        if Element.SelectSingleNode(StrSubstNo(XPathExcludeNamespacePattern, 'height'), Node) then
            if evaluate(EmbeddedVideoBuffer."Height (px)", Node.AsXmlElement().InnerText(), 9) then;
        EmbeddedVideoBuffer.Insert();
    end;

    local procedure SendEmbeddedVideoHttpWebRequest(SoapAction: Text; Request: Text; var Response: Text): Boolean
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        TempBlob: Codeunit "Temp Blob";
        Headers: HttpHeaders;
        Content: HttpContent;
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        OutStr: OutStream;
        ContentText: Text;
    begin
        Response := '';
        Content.WriteFrom(Request);
        Content.GetHeaders(Headers);
        Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'text/xml; charset=utf-8');
        Headers.Add('SOAPAction', SoapAction);

        InitRequest(Client, RequestMessage);
        RequestMessage.Method := 'POST';
        RequestMessage.Content(Content);
        Client.Timeout := 1000 * 60;

        if not Client.Send(RequestMessage, ResponseMessage) then
            exit;
        if not ResponseMessage.IsSuccessStatusCode() then
            exit;
        if not ResponseMessage.Content().ReadAs(Response) then
            exit;

        exit(Response <> '');
    end;

    [NonDebuggable]
    local procedure InitRequest(var Client: HttpClient; var RequestMessage: HttpRequestMessage)
    var
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
    begin
        Client.UseWindowsAuthentication(AzureKeyVaultMgt.GetSecret('EmbeddedVideoUsername'), AzureKeyVaultMgt.GetSecret('EmbeddedVideoPassword'));
        RequestMessage.SetRequestUri(AzureKeyVaultMgt.GetSecret('EmbeddedVideoUrl'));
    end;
}
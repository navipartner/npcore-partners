codeunit 6151022 "NPR NpRv Partner Mgt."
{
    procedure InitLocalPartner(var NpRvPartner: Record "NPR NpRv Partner")
    begin
        if NpRvPartner.Name = '' then
            NpRvPartner.Name := CompanyName;

        if NpRvPartner."Service Url" = '' then begin
            InitGlobalVoucherService();
            NpRvPartner."Service Url" := GetGlobalVoucherWSUrl(CompanyName);
        end;
    end;

    local procedure InitGlobalVoucherService()
    var
        WebService: Record "Web Service";
        PrevRec: Text;
    begin
        if not WebService.ReadPermission then
            exit;

        if not WebService.WritePermission then
            exit;

        if not WebService.Get(WebService."Object Type"::Codeunit, 'global_voucher_service') then begin
            WebService.Init;
            WebService."Object Type" := WebService."Object Type"::Codeunit;
            WebService."Object ID" := GlobalVoucherWsCodeunitId();
            WebService."Service Name" := 'global_voucher_service';
            WebService.Published := true;
            WebService.Insert(true);
        end;

        PrevRec := Format(WebService);
        WebService."Object ID" := GlobalVoucherWsCodeunitId();
        WebService.Published := true;
        if PrevRec <> Format(WebService) then
            WebService.Modify(true);
    end;

    [TryFunction]
    procedure TryValidateGlobalVoucherService(NpRvPartner: Record "NPR NpRv Partner")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        XmlDomManagement: codeunit "XML DOM Management";
        Client: HttpClient;
        RequestContent: HttpContent;
        ContentHeader: HttpHeaders;
        Response: HttpResponseMessage;
        Document: XmlDocument;
        Node: XmlNode;
        RequestXmlText: Text;
        ErrorMessage: Text;
    begin
        NpRvPartner.TestField("Service Url");

        RequestXmlText :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
             '<soapenv:Body>' +
               '<UpsertPartners xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvPartner) + '">' +
                 '<retail_voucher_partners />' +
               '</UpsertPartners>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        RequestContent.WriteFrom(RequestXmlText);
        RequestContent.GetHeaders(ContentHeader);

        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeader.Add('SOAPAction', 'UpsertPartners');
        ContentHeader := Client.DefaultRequestHeaders();

        Client.UseWindowsAuthentication(NpRvPartner."Service Username", NpRvPartner."Service Password");
        Client.Post(NpRvPartner."Service Url", RequestContent, Response);

        if Response.IsSuccessStatusCode then
            exit;

        ErrorMessage := XmlDomManagement.RemoveNamespaces(Response.ReasonPhrase);
        if XmlDocument.ReadFrom(ErrorMessage, Document) then
            if NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//faultstring', Node) then
                ErrorMessage := Node.AsXmlElement.InnerText();
        Error(CopyStr(ErrorMessage, 1, 1000));
    end;

    procedure GetGlobalVoucherWSUrl(ServiceCompanyName: Text) Url: Text
    begin
        exit(GetUrl(CLIENTTYPE::SOAP, ServiceCompanyName, OBJECTTYPE::Codeunit, GlobalVoucherWsCodeunitId()));
    end;

    procedure GetServiceName(NpRvPartner: Record "NPR NpRv Partner") ServiceName: Text
    var
        Position: Integer;
    begin
        ServiceName := NpRvPartner."Service Url";
        Position := StrPos(ServiceName, '?');
        if Position > 0 then
            ServiceName := DelStr(ServiceName, Position);

        if ServiceName = '' then
            exit('');

        if ServiceName[StrLen(ServiceName)] = '/' then
            ServiceName := DelStr(ServiceName, StrLen(ServiceName));

        Position := StrPos(ServiceName, '/');
        while Position > 0 do begin
            ServiceName := DelStr(ServiceName, 1, Position);
            Position := StrPos(ServiceName, '/');
        end;

        exit(ServiceName);
    end;

    local procedure GlobalVoucherWsCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpRv Global Voucher WS");
    end;
}


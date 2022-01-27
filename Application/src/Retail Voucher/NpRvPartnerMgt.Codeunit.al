codeunit 6151022 "NPR NpRv Partner Mgt."
{
    Access = Internal;
    procedure InitLocalPartner(var NpRvPartner: Record "NPR NpRv Partner")
    var
        ServiceUrl: Text;
        ServiceURLErr: Label 'ServiceURL returned in GetGlobalVoucherWSUrl function is too big to be stored in "Service Url" field. Please contact administrator.';
    begin
        if NpRvPartner.Name = '' then
            NpRvPartner.Name := CopyStr(CompanyName(), 1, MaxStrLen(NpRvPartner.Name));

        if NpRvPartner."Service Url" = '' then begin
            InitGlobalVoucherService();
            ServiceUrl := GetGlobalVoucherWSUrl(CompanyName());
            if StrLen(ServiceUrl) > MaxStrLen(NpRvPartner."Service Url") then
                Error(ServiceURLErr) else
                NpRvPartner."Service Url" := CopyStr(ServiceUrl, 1, MaxStrLen(NpRvPartner."Service Url"));
        end;
    end;

    local procedure InitGlobalVoucherService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        if not WebService.ReadPermission then
            exit;

        if not WebService.WritePermission then
            exit;

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, GlobalVoucherWsCodeunitId(), 'global_voucher_service', true);
    end;

    [TryFunction]
    procedure TryValidateGlobalVoucherService(NpRvPartner: Record "NPR NpRv Partner")
    var
        NpRvModuleValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ContentHeader: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        RequestXmlText: Text;
        ResponseText: Text;
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

        RequestMessage.GetHeaders(RequestHeaders);

        NpRvPartner.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Content.WriteFrom(RequestXmlText);
        RequestMessage.Content.GetHeaders(ContentHeader);
        ContentHeader.Clear();
        ContentHeader.Remove('Content-Type');
        ContentHeader.Add('Content-Type', 'text/xml; charset=utf-8');
        ContentHeader.Add('SOAPAction', 'UpsertPartners');

        RequestMessage.Method := 'POST';
        RequestMessage.SetRequestUri(NpRvPartner."Service Url");

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then begin
            ResponseMessage.Content.ReadAs(ResponseText);
            NpRvModuleValidGlobal.ThrowGlobalVoucherWSError(ResponseMessage.ReasonPhrase, ResponseText);
        end;
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
        exit(Codeunit::"NPR NpRv Global Voucher WS");
    end;
}


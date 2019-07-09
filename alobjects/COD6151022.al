codeunit 6151022 "NpRv Partner Mgt."
{
    // NPR5.49/MHA /20190228  CASE 342811 Object created - Retail Voucher Partner used with Cross Company Vouchers


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Webservice User for (Global) Retail Voucher';

    local procedure "--- Init"()
    begin
    end;

    [Scope('Personalization')]
    procedure InitLocalPartner(var NpRvPartner: Record "NpRv Partner")
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

        if not WebService.Get(WebService."Object Type"::Codeunit,'global_voucher_service') then begin
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
    [Scope('Personalization')]
    procedure TryValidateGlobalVoucherService(NpRvPartner: Record "NpRv Partner")
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        WebException: DotNet npNetWebException;
        ErrorMessage: Text;
        LastErrorText: Text;
    begin
        //-NPR5.49 [342811]
        NpRvPartner.TestField("Service Url");

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
             '<soapenv:Body>' +
               '<UpsertPartners xmlns="urn:microsoft-dynamics-schemas/codeunit/' + GetServiceName(NpRvPartner) + '">' +
                 '<retail_voucher_partners />' +
               '</UpsertPartners>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>'
        );

        HttpWebRequest := HttpWebRequest.Create(NpRvPartner."Service Url");
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpRvPartner."Service Username",NpRvPartner."Service Password");
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction','UpsertPartners');
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then
          exit;

        LastErrorText := GetLastErrorText;
        ErrorMessage := NpXmlDomMgt.GetWebExceptionInnerMessage(WebException);
        if NpXmlDomMgt.TryLoadXml(ErrorMessage,XmlDoc) then begin
          NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
          if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement,'//faultstring',XmlElement) then begin
            ErrorMessage := XmlElement.InnerText;
            Error(ErrorMessage);
          end;
        end;
        if ErrorMessage = '' then
          ErrorMessage := LastErrorText;

        Error(ErrorMessage);
        //+NPR5.49 [342811]
    end;

    local procedure "--- Get/Find"()
    begin
    end;

    [Scope('Personalization')]
    procedure GetGlobalVoucherWSUrl(ServiceCompanyName: Text) Url: Text
    begin
        exit(GetUrl(CLIENTTYPE::SOAP,ServiceCompanyName,OBJECTTYPE::Codeunit,GlobalVoucherWsCodeunitId()));
    end;

    [Scope('Personalization')]
    procedure GetServiceName(NpRvPartner: Record "NpRv Partner") ServiceName: Text
    var
        Position: Integer;
    begin
        //-NPR5.49 [342811]
        ServiceName := NpRvPartner."Service Url";
        Position := StrPos(ServiceName,'?');
        if Position > 0 then
          ServiceName := DelStr(ServiceName,Position);

        if ServiceName = '' then
          exit('');

        if ServiceName[StrLen(ServiceName)] = '/' then
          ServiceName := DelStr(ServiceName,StrLen(ServiceName));

        Position := StrPos(ServiceName,'/');
        while Position > 0 do begin
          ServiceName := DelStr(ServiceName,1,Position);
          Position := StrPos(ServiceName,'/');
        end;

        exit(ServiceName);
        //+NPR5.49 [342811]
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure GlobalVoucherWsCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpRv Global Voucher Webservice");
    end;
}


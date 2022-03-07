codeunit 6151402 "NPR Magento Mgt."
{
    var
        MagentoSetup: Record "NPR Magento Setup";

    procedure GetCustTemplate(Customer: Record Customer) TemplateCode: Code[20]
    var
        MagentoCustomerMapping: Record "NPR Magento Customer Mapping";
    begin
        if MagentoCustomerMapping.Get(Customer."Country/Region Code", Customer."Post Code") then
            exit(MagentoCustomerMapping."Customer Template Code");

        if MagentoCustomerMapping.Get(Customer."Country/Region Code", '') then
            exit(MagentoCustomerMapping."Customer Template Code");

        if MagentoCustomerMapping.Get('', '') then
            exit(MagentoCustomerMapping."Customer Template Code");

        if MagentoSetup.Get() then
            exit(MagentoSetup."Customer Template Code");

        exit('');
    end;

    procedure GetCustConfigTemplate(TaxClass: Text; Customer: Record Customer) ConfigTemplateCode: Code[10]
    var
        MagentoTaxClass: Record "NPR Magento Tax Class";
        MagentoCustomerMapping: Record "NPR Magento Customer Mapping";
    begin
        if MagentoCustomerMapping.Get(Customer."Country/Region Code", Customer."Post Code") then
            exit(MagentoCustomerMapping."Config. Template Code");

        if MagentoCustomerMapping.Get(Customer."Country/Region Code", '') then
            exit(MagentoCustomerMapping."Config. Template Code");

        if MagentoCustomerMapping.Get('', '') then
            exit(MagentoCustomerMapping."Config. Template Code");

        if not MagentoSetup.Get() then
            exit('');

        ConfigTemplateCode := MagentoSetup."Customer Config. Template Code";
        if MagentoTaxClass.Get(TaxClass, MagentoTaxClass.Type::Customer) and (MagentoTaxClass."Customer Config. Template Code" <> '') then
            ConfigTemplateCode := MagentoTaxClass."Customer Config. Template Code";

        exit(ConfigTemplateCode);
    end;

    internal procedure GetCustomerConfigTemplate(TaxClass: Text) ConfigTemplateCode: Code[10]
    var
        MagentoTaxClass: Record "NPR Magento Tax Class";
    begin
        if not MagentoSetup.Get() then
            exit('');

        ConfigTemplateCode := MagentoSetup."Customer Config. Template Code";
        if MagentoTaxClass.Get(TaxClass, MagentoTaxClass.Type::Customer) and (MagentoTaxClass."Customer Config. Template Code" <> '') then
            ConfigTemplateCode := MagentoTaxClass."Customer Config. Template Code";

        exit(ConfigTemplateCode);
    end;

    procedure GetVATBusPostingGroup(TaxClass: Text): Code[20]
    var
        MagentoVatBusGroup: Record "NPR Magento VAT Bus. Group";
        VATBusPostingGroup: Record "VAT Business Posting Group";
    begin
        if TaxClass = '' then
            exit('');

        MagentoVatBusGroup.SetRange("Magento Tax Class", CopyStr(TaxClass, 1, MaxStrLen(MagentoVatBusGroup."Magento Tax Class")));
        MagentoVatBusGroup.FindFirst();
        MagentoVatBusGroup.TestField("VAT Business Posting Group");
        VATBusPostingGroup.Get(MagentoVatBusGroup."VAT Business Posting Group");
        exit(VATBusPostingGroup.Code);
    end;

    procedure GetFixedCustomerNo(Customer: Record Customer): Code[20]
    var
        MagentoCustomerMapping: Record "NPR Magento Customer Mapping";
    begin
        if MagentoCustomerMapping.Get(Customer."Country/Region Code", Customer."Post Code") then begin
            MagentoCustomerMapping.TestField("Fixed Customer No.");
            exit(MagentoCustomerMapping."Fixed Customer No.");
        end;

        if MagentoCustomerMapping.Get(Customer."Country/Region Code", '') then begin
            MagentoCustomerMapping.TestField("Fixed Customer No.");
            exit(MagentoCustomerMapping."Fixed Customer No.");
        end;

        if MagentoCustomerMapping.Get('', '') then begin
            MagentoCustomerMapping.TestField("Fixed Customer No.");
            exit(MagentoCustomerMapping."Fixed Customer No.");
        end;

        MagentoSetup.Get();
        MagentoSetup.TestField("Fixed Customer No.");
        exit(MagentoSetup."Fixed Customer No.");
    end;

    #region Magento Api

    internal procedure MagentoApiGet(MagentoApiUrl: Text; Method: Text; var XmlDoc: XmlDocument) Result: Boolean
    var
        XmlDom: Codeunit "XML DOM Management";
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        HeadersReq: HttpHeaders;
        Response: Text;
    begin
        if MagentoApiUrl = '' then
            exit(false);

        HttpWebRequest.GetHeaders(HeadersReq);

        MagentoSetup.Get();
        if MagentoSetup."Api Authorization" <> '' then begin
            HeadersReq.Add('Accept', 'application/xml');
            HeadersReq.Add('Authorization', MagentoSetup."Api Authorization");
        end
        else begin
            HeadersReq.Add('Accept', 'navision/xml');
            HeadersReq.Add('Authorization', 'Basic ' + MagentoSetup.GetBasicAuthInfo());
        end;

        HttpWebRequest.SetRequestUri(MagentoApiUrl + Method);
        HttpWebRequest.Method := 'GET';

        Client.Timeout(300000);
        Client.Send(HttpWebRequest, HttpWebResponse);

        Clear(XmlDoc);
        HttpWebResponse.Content.ReadAs(Response);
        XmlDocument.ReadFrom(Response, XmlDoc);

        if not HttpWebResponse.IsSuccessStatusCode then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);

        XmlDocument.ReadFrom(XmlDom.RemoveNamespaces(Response), XmlDoc);
        exit(true);
    end;

    internal procedure MagentoApiPost(MagentoApiUrl: Text; Method: Text; var XmlDoc: XmlDocument) Result: Boolean
    var
        XmlDom: Codeunit "XML DOM Management";
        TempBlob: Codeunit "Temp Blob";
        HttpWebRequest: HttpRequestMessage;
        HttpWebResponse: HttpResponseMessage;
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        HeadersReq: HttpHeaders;
        StreamIn: InStream;
        StreamOut: OutStream;
        Response: Text;
    begin
        if MagentoApiUrl = '' then
            exit(false);
        TempBlob.CreateOutStream(StreamOut, TEXTENCODING::UTF8);
        XmlDoc.WriteTo(StreamOut);
        TempBlob.CreateInStream(StreamIn, TEXTENCODING::UTF8);

        HttpWebRequest.GetHeaders(HeadersReq);
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');

        MagentoSetup.Get();
        if MagentoSetup."Api Authorization" <> '' then begin
            Headers.Add('Content-Type', 'naviconnect/xml');
            HeadersReq.Add('Accept', 'application/xml');
            HeadersReq.Add('Authorization', MagentoSetup."Api Authorization");
        end
        else begin
            Headers.Add('Content-Type', 'navision/xml');
            HeadersReq.Add('Accept', 'navision/xml');
            HeadersReq.Add('Authorization', 'Basic ' + MagentoSetup.GetBasicAuthInfo());
        end;

        Content.WriteFrom(StreamIn);
        HttpWebRequest.Content(Content);
        HttpWebRequest.SetRequestUri(MagentoApiUrl + Method);
        HttpWebRequest.Method := 'POST';

        Client.Timeout(300000);
        Client.Send(HttpWebRequest, HttpWebResponse);

        Clear(XmlDoc);
        HttpWebResponse.Content.ReadAs(Response);
        XmlDocument.ReadFrom(Response, XmlDoc);

        if not HttpWebResponse.IsSuccessStatusCode then
            Error('%1 - %2  \%3', HttpWebResponse.HttpStatusCode, HttpWebResponse.ReasonPhrase, Response);

        XmlDocument.ReadFrom(XmlDom.RemoveNamespaces(Response), XmlDoc);
        exit(true);
    end;

    #endregion

    internal procedure InitItemSync()
    var
        Item: Record Item;
        RecRef: RecordRef;
        DataLogMgt: Codeunit "NPR Data Log Management";
    begin
        Item.SetRange("NPR Magento Item", true);
        if not Item.FindSet() then
            exit;

        repeat
            RecRef.GetTable(Item);
            DataLogMgt.LogDatabaseInsert(RecRef);
        until Item.Next() = 0;
    end;
}

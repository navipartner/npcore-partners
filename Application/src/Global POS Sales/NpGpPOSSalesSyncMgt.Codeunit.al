codeunit 6151168 "NPR NpGp POS Sales Sync Mgt."
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales
    // NPR5.51/ALST/20190711  CASE 337539 modified the web request message
    // NPR5.52/ALST/20191009  CASE 372010 added permissions to service password
    // NPR5.52/MHA /20191016 CASE 371388 "Global POS Sales Setup" moved from Np Retail Setup to POS Unit
    // NPR5.52/MHA /20191017  CASE 373420 Added function XmlEscape()
    // NPR5.53/THRO/20191206  CASE 381416 Added extension_fields in xml and publisher OnInitReqBody

    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        case Rec."Table No." of
            DATABASE::"NPR POS Entry":
                begin
                    ExportPOSEntry(Rec);
                end;
        end;
    end;

    var
        ServicePasswordErr: Label 'Please check there is a password set up in %1';

    procedure ExportPOSEntry(var NcTask: Record "NPR Nc Task")
    var
        POSEntry: Record "NPR POS Entry";
        NpGpGlobalSalesSetup: Record "NPR NpGp POS Sales Setup";
        POSUnit: Record "NPR POS Unit";
        ServicePassword: Text;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NpGpPOSSalesSetupCard: Page "NPR NpGp POS Sales Setup Card";
        Credential: DotNet NPRNetNetworkCredential;
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        XmlDoc: DotNet "NPRNetXmlDocument";
        WebException: DotNet NPRNetWebException;
        OutStr: OutStream;
        ErrorMessage: Text;
        Response: Text;
        ServiceName: Text;
    begin
        if NcTask.Type <> NcTask.Type::Insert then
            exit;

        POSEntry.SetPosition(NcTask."Record Position");
        if not POSEntry.Find then
            exit;

        //-NPR5.52 [371388]
        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit;
        if POSUnit."Global POS Sales Setup" = '' then
            exit;
        if not NpGpGlobalSalesSetup.Get(POSUnit."Global POS Sales Setup") then
            exit;
        //+NPR5.52 [371388]
        NpGpGlobalSalesSetup.TestField("Service Url");

        ServiceName := GetServiceName(NpGpGlobalSalesSetup."Service Url");
        InitReqBody(POSEntry, ServiceName, XmlDoc);
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        NcTask."Data Output".CreateOutStream(OutStr, TEXTENCODING::UTF8);
        XmlDoc.Save(OutStr);
        NcTask.Modify;
        Commit;

        if not IsolatedStorage.Get(NpGpGlobalSalesSetup."Service Password", DataScope::Company, ServicePassword) then
            Error(ServicePasswordErr, NpGpPOSSalesSetupCard.Caption);

        HttpWebRequest := HttpWebRequest.Create(NpGpGlobalSalesSetup."Service Url");
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpGpGlobalSalesSetup."Service Username", ServicePassword);
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.ContentType := 'text/xml; charset=utf-8';
        HttpWebRequest.Headers.Add('SOAPAction', 'InsertPosSalesEntries');
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if not NpXmlDomMgt.SendWebRequest(XmlDoc, HttpWebRequest, HttpWebResponse, WebException) then begin
            ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
            Error(NpXmlDomMgt.PrettyPrintXml(ErrorMessage));
        end;

        Response := NpXmlDomMgt.GetWebResponseText(HttpWebResponse);
        NcTask.Response.CreateOutStream(OutStr, TEXTENCODING::UTF8);
        OutStr.WriteText(NpXmlDomMgt.PrettyPrintXml(Response));
        NcTask.Modify;
    end;

    local procedure InitReqBody(POSEntry: Record "NPR POS Entry"; ServiceName: Text; var XmlDoc: DotNet "NPRNetXmlDocument")
    var
        POSSalesLine: Record "NPR POS Sales Line";
        POSInfoPOSEntry: Record "NPR POS Info POS Entry";
        RetailCrossReference: Record "NPR Retail Cross Reference";
        Xml: Text;
    begin
        XmlDoc := XmlDoc.XmlDocument;
        Xml :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
             '<soapenv:Body>' +
               '<InsertPosSalesEntries xmlns="urn:microsoft-dynamics-schemas/codeunit/' + ServiceName + '">' +
                 '<sales_entries>' +
                   '<sales_entry xmlns="urn:microsoft-dynamics-nav/xmlports/global_pos_sales" ' +
                   '  pos_store_code="' + POSEntry."POS Store Code" + '"' +
                   '  pos_unit_no="' + POSEntry."POS Unit No." + '"' +
                   '  document_no="' + POSEntry."Document No." + '"' +
                   //-NPR5.52 [373420]
                   '  company="' + XmlEscape(CompanyName) + '">' +
                     //-NPR5.52 [373420]
                     '<entry_time>' + Format(CreateDateTime(POSEntry."Entry Date", POSEntry."Ending Time"), 0, 9) + '</entry_time>' +
                     '<entry_type>' + Format(POSEntry."Entry Type", 0, 2) + '</entry_type>' +
                     '<retail_id>' + Format(POSEntry."Retail ID") + '</retail_id>' +
                     '<posting_date>' + Format(POSEntry."Posting Date", 0, 9) + '</posting_date>' +
                     '<fiscal_no>' + POSEntry."Fiscal No." + '</fiscal_no>' +
                     '<salesperson_code>' + POSEntry."Salesperson Code" + '</salesperson_code>' +
                     '<currency_code>' + POSEntry."Currency Code" + '</currency_code>' +
                     '<currency_factor>' + Format(POSEntry."Currency Factor", 0, 9) + '</currency_factor>' +
                     '<sales_amount>' + Format(POSEntry."Item Sales (LCY)", 0, 9) + '</sales_amount>' +
                     '<discount_amount>' + Format(POSEntry."Discount Amount", 0, 9) + '</discount_amount>' +
                     '<total_amount>' + Format(POSEntry."Amount Excl. Tax", 0, 9) + '</total_amount>' +
                     '<total_tax_amount>' + Format(POSEntry."Tax Amount", 0, 9) + '</total_tax_amount>' +
                     '<total_amount_incl_tax>' + Format(POSEntry."Amount Incl. Tax", 0, 9) + '</total_amount_incl_tax>' +
                     '<sales_lines>';

        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSSalesLine.FindSet then
            repeat
                if RetailCrossReference.Get(POSSalesLine."Retail ID") then;
                Xml +=
                            '<sales_line line_no="' + Format(POSSalesLine."Line No.", 0, 9) + '">' +
                              '<retail_id>' + Format(POSSalesLine."Retail ID") + '</retail_id>' +
                              '<type>' + Format(POSSalesLine.Type, 0, 2) + '</type>' +
                              '<no>' + POSSalesLine."No." + '</no>' +
                              '<variant_code>' + POSSalesLine."Variant Code" + '</variant_code>' +
                              '<cross_reference_no>' + POSSalesLine."Cross-Reference No." + '</cross_reference_no>' +
                              '<bom_item_no>' + POSSalesLine."BOM Item No." + '</bom_item_no>' +
                              '<location_code>' + POSSalesLine."Location Code" + '</location_code>' +
                              '<description><![CDATA[' + POSSalesLine.Description + ']]></description>' +
                              '<description_2></description_2>' +
                              '<quantity>' + Format(POSSalesLine.Quantity, 0, 9) + '</quantity>' +
                              '<unit_of_measure_code>' + POSSalesLine."Unit of Measure Code" + '</unit_of_measure_code>' +
                              '<qty_per_unit_of_measure>' + Format(POSSalesLine."Qty. per Unit of Measure", 0, 9) + '</qty_per_unit_of_measure>' +
                              '<quantity_base>' + Format(POSSalesLine."Quantity (Base)", 0, 9) + '</quantity_base>' +
                              '<unit_price>' + Format(POSSalesLine."Unit Price", 0, 9) + '</unit_price>' +
                              '<currency_code>' + POSSalesLine."Currency Code" + '</currency_code>' +
                              '<vat_pct>' + Format(POSSalesLine."VAT %", 0, 9) + '</vat_pct>' +
                              '<line_discount_pct>' + Format(POSSalesLine."Line Discount %", 0, 9) + '</line_discount_pct>' +
                              '<line_discount_amount_excl_vat>' + Format(POSSalesLine."Line Discount Amount Excl. VAT", 0, 9) + '</line_discount_amount_excl_vat>' +
                              '<line_discount_amount_incl_vat>' + Format(POSSalesLine."Line Discount Amount Incl. VAT", 0, 9) + '</line_discount_amount_incl_vat>' +
                              '<line_amount>' + Format(POSSalesLine."Line Amount", 0, 9) + '</line_amount>' +
                              '<amount_excl_vat>' + Format(POSSalesLine."Amount Excl. VAT", 0, 9) + '</amount_excl_vat>' +
                              '<amount_incl_vat>' + Format(POSSalesLine."Amount Incl. VAT", 0, 9) + '</amount_incl_vat>' +
                              '<line_discount_amount_excl_vat_lcy>' + Format(POSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)", 0, 9) + '</line_discount_amount_excl_vat_lcy>' +
                              '<line_discount_amount_incl_vat_lcy>' + Format(POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)", 0, 9) + '</line_discount_amount_incl_vat_lcy>' +
                              '<amount_excl_vat_lcy>' + Format(POSSalesLine."Amount Excl. VAT (LCY)", 0, 9) + '</amount_excl_vat_lcy>' +
                              '<amount_incl_vat_lcy>' + Format(POSSalesLine."Amount Incl. VAT (LCY)", 0, 9) + '</amount_incl_vat_lcy>' +
                              '<global_reference>' + RetailCrossReference."Reference No." + '</global_reference>' +
                              //-NPR5.53 [381416]
                              '<extension_fields/>' +
                            //+NPR5.53 [381416]
                            '</sales_line>';
            until POSSalesLine.Next = 0;
        Xml +=
                     '</sales_lines>' +
                     '<pos_info_entries>';
        POSInfoPOSEntry.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSInfoPOSEntry.FindSet then
            repeat
                Xml +=
                            '<pos_info_entry pos_info_code="' + POSInfoPOSEntry."POS Info Code" + '" entry_no="' + Format(POSInfoPOSEntry."Entry No.", 0, 9) + '">' +
                              '<sales_line_no>' + Format(POSInfoPOSEntry."Sales Line No.", 0, 9) + '</sales_line_no>' +
                              '<pos_info>' + POSInfoPOSEntry."POS Info" + '</pos_info>' +
                              '<no>' + POSInfoPOSEntry."No." + '</no>' +
                              '<quantity>' + Format(POSInfoPOSEntry.Quantity, 0, 9) + '</quantity>' +
                              '<price>' + Format(POSInfoPOSEntry.Price, 0, 9) + '</price>' +
                              '<net_amount>' + Format(POSInfoPOSEntry."Net Amount", 0, 9) + '</net_amount>' +
                              '<gross_amount>' + Format(POSInfoPOSEntry."Gross Amount", 0, 9) + '</gross_amount>' +
                              '<discount_amount>' + Format(POSInfoPOSEntry."Discount Amount", 0, 9) + '</discount_amount>' +
                          '</pos_info_entry>';
            until POSInfoPOSEntry.Next = 0;
        Xml += '</pos_info_entries>' +
                   '</sales_entry>' +
                 '</sales_entries>' +
               '</InsertPosSalesEntries>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        XmlDoc.LoadXml(Xml);
        //-NPR5.53 [381416]
        OnInitReqBody(POSEntry, XmlDoc);
        //+NPR5.53 [381416]
    end;

    procedure InitGlobalPosSalesService()
    var
        WebService: Record "Web Service";
        PrevRec: Text;
    begin
        if not WebService.ReadPermission then
            exit;

        if not WebService.WritePermission then
            exit;

        if not WebService.Get(WebService."Object Type"::Codeunit, 'global_pos_sales_service') then begin
            WebService.Init;
            WebService."Object Type" := WebService."Object Type"::Codeunit;
            WebService."Object ID" := GlobalPosSalesCodeunitId();
            WebService."Service Name" := 'global_pos_sales_service';
            WebService.Published := true;
            WebService.Insert(true);
        end;

        PrevRec := Format(WebService);
        WebService."Object ID" := GlobalPosSalesCodeunitId();
        WebService.Published := true;
        if PrevRec <> Format(WebService) then
            WebService.Modify(true);
    end;

    local procedure GetServiceName(Url: Text) ServiceName: Text
    var
        Position: Integer;
    begin
        ServiceName := Url;
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

    local procedure GlobalPosSalesCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpGp POS Sales WS");
    end;

    [TryFunction]
    procedure TryGetGlobalPosSalesService(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    var
        ServicePassword: Text;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Credential: DotNet NPRNetNetworkCredential;
        HttpWebRequest: DotNet NPRNetHttpWebRequest;
        HttpWebResponse: DotNet NPRNetHttpWebResponse;
        XmlDoc: DotNet "NPRNetXmlDocument";
        XmlElement: DotNet NPRNetXmlElement;
        WebException: DotNet NPRNetWebException;
        ErrorMessage: Text;
    begin
        NpGpPOSSalesSetup.TestField("Service Url");

        HttpWebRequest := HttpWebRequest.Create(NpGpPOSSalesSetup."Service Url");
        HttpWebRequest.UseDefaultCredentials(false);

        IsolatedStorage.Get(NpGpPOSSalesSetup."Service Password", DataScope::Company, ServicePassword);

        Credential := Credential.NetworkCredential(NpGpPOSSalesSetup."Service Username", ServicePassword);
        HttpWebRequest.Credentials(Credential);
        HttpWebRequest.Method := 'GET';
        NpXmlDomMgt.SetTrustedCertificateValidation(HttpWebRequest);

        if TryGetWebResponse(HttpWebRequest, HttpWebResponse) then
            exit;

        WebException := GetLastErrorObject;
        ErrorMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
        if NpXmlDomMgt.TryLoadXml(ErrorMessage, XmlDoc) then begin
            NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
            if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement, '//faultstring', XmlElement) then begin
                ErrorMessage := XmlElement.InnerText;
                Error(ErrorMessage);
            end;
        end;

        Error(ErrorMessage);
    end;

    [TryFunction]
    local procedure TryGetWebResponse(HttpWebRequest: DotNet NPRNetHttpWebRequest; var HttpWebResponse: DotNet NPRNetHttpWebResponse)
    begin
        HttpWebResponse := HttpWebRequest.GetResponse;
    end;

    local procedure XmlEscape(Input: Text) Output: Text
    var
        SecurityElement: DotNet NPRNetSecurityElement;
    begin
        //-NPR5.52 [373420]
        Output := SecurityElement.Escape(Input);
        exit(Output);
        //+NPR5.52 [373420]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitReqBody(POSEntry: Record "NPR POS Entry"; var XmlDoc: DotNet "NPRNetXmlDocument")
    begin
    end;
}


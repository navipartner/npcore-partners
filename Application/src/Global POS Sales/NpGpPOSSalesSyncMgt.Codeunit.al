codeunit 6151168 "NPR NpGp POS Sales Sync Mgt."
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        case Rec."Table No." of
            Database::"NPR POS Entry":
                begin
                    ExportPOSEntry(Rec);
                end;
        end;
    end;

    procedure ExportPOSEntry(var NcTask: Record "NPR Nc Task")
    var
        POSEntry: Record "NPR POS Entry";
        NpGpGlobalSalesSetup: Record "NPR NpGp POS Sales Setup";
        POSUnit: Record "NPR POS Unit";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        Client: HttpClient;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ContentHeaders: HttpHeaders;
        XmlDoc: XmlDocument;
        OutStr: OutStream;
        InStr: InStream;
        Response: Text;
        ServiceName: Text;
        XmlText: Text;
        TempBlob: Codeunit "Temp Blob";
    begin
        if NcTask.Type <> NcTask.Type::Insert then
            exit;

        POSEntry.SetPosition(NcTask."Record Position");
        if not POSEntry.Find() then
            exit;

        if not POSUnit.Get(POSEntry."POS Unit No.") then
            exit;
        if POSUnit."Global POS Sales Setup" = '' then
            exit;
        if not NpGpGlobalSalesSetup.Get(POSUnit."Global POS Sales Setup") then
            exit;

        NpGpGlobalSalesSetup.TestField("Service Url");

        ServiceName := GetServiceName(NpGpGlobalSalesSetup."Service Url");
        InitReqBody(POSEntry, ServiceName, XmlText);
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        XmlDocument.ReadFrom(XmlText, XmlDoc);
        NcTask."Data Output".CreateOutStream(OutStr, TextEncoding::UTF8);
        XmlDoc.WriteTo(OutStr);

        NcTask.Modify();

        Commit();

        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        TempBlob.CreateInStream(InStr, TextEncoding::UTF8);
        RequestMessage.Content.WriteFrom(XmlText);

        RequestMessage.GetHeaders(RequestHeaders);
        RequestMessage.Content.GetHeaders(ContentHeaders);

        if ContentHeaders.Contains('Content-Type') then
            ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'text/xml; charset=utf-8');

        if ContentHeaders.Contains('SOAPAction') then
            ContentHeaders.Remove('SOAPAction');
        ContentHeaders.Add('SOAPAction', 'InsertPosSalesEntries');

        NpGpGlobalSalesSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.SetRequestUri(NpGpGlobalSalesSetup."Service Url");
        RequestMessage.Method := 'POST';

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then
            Error(ResponseMessage.ReasonPhrase);

        ResponseMessage.Content.ReadAs(Response);

        NcTask.Response.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NpXmlDomMgt.PrettyPrintXml(Response));
        NcTask.Modify();
    end;

    local procedure InitReqBody(POSEntry: Record "NPR POS Entry"; ServiceName: Text; var Xml: Text)
    var
        POSSalesLine: Record "NPR POS Entry Sales Line";
        POSInfoPOSEntry: Record "NPR POS Info POS Entry";
        POSCrossReference: Record "NPR POS Cross Reference";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        POSSalesWS: Codeunit "NPR NpGp POS Sales WS";
    begin
        Xml :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:glob="urn:microsoft-dynamics-schemas/codeunit/' + ServiceName + '" xmlns:glob1="urn:microsoft-dynamics-nav/xmlports/global_pos_sales">' +
             '<soapenv:Body>' +
               '<glob:InsertPosSalesEntries>' +
                 '<glob:sales_entries>' +
                   '<glob1:sales_entry' +
                   '  pos_store_code="' + POSEntry."POS Store Code" + '"' +
                   '  pos_unit_no="' + POSEntry."POS Unit No." + '"' +
                   '  document_no="' + POSEntry."Document No." + '"' +
                   '  company="' + XmlEscape(CompanyName) + '">' +
                     '<glob1:entry_time>' + Format(CreateDateTime(POSEntry."Entry Date", POSEntry."Ending Time"), 0, 9) + '</glob1:entry_time>' +
                     '<glob1:entry_type>' + Format(POSEntry."Entry Type", 0, 2) + '</glob1:entry_type>' +
                     '<glob1:customer_no>' + Format(POSEntry."Customer No.") + '</glob1:customer_no>' +
                     '<glob1:retail_id>' + Format(POSEntry.SystemId) + '</glob1:retail_id>' +
                     '<glob1:posting_date>' + Format(POSEntry."Posting Date", 0, 9) + '</glob1:posting_date>' +
                     '<glob1:fiscal_no>' + POSEntry."Fiscal No." + '</glob1:fiscal_no>' +
                     '<glob1:salesperson_code>' + POSEntry."Salesperson Code" + '</glob1:salesperson_code>' +
                     '<glob1:currency_code>' + POSEntry."Currency Code" + '</glob1:currency_code>' +
                     '<glob1:currency_factor>' + Format(POSEntry."Currency Factor", 0, 9) + '</glob1:currency_factor>' +
                     '<glob1:sales_amount>' + Format(POSEntry."Item Sales (LCY)", 0, 9) + '</glob1:sales_amount>' +
                     '<glob1:discount_amount>' + Format(POSEntry."Discount Amount", 0, 9) + '</glob1:discount_amount>' +
                     '<glob1:total_amount>' + Format(POSEntry."Amount Excl. Tax", 0, 9) + '</glob1:total_amount>' +
                     '<glob1:total_tax_amount>' + Format(POSEntry."Tax Amount", 0, 9) + '</glob1:total_tax_amount>' +
                     '<glob1:total_amount_incl_tax>' + Format(POSEntry."Amount Incl. Tax", 0, 9) + '</glob1:total_amount_incl_tax>' +
                     '<glob1:sales_lines>';

        POSSalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSSalesLine.FindSet() then
            repeat
                if not POSCrossReference.GetBySystemId(POSSalesLine.SystemId) then
                    POSCrossReference.Init();
                Xml +=
                            '<glob1:sales_line line_no="' + Format(POSSalesLine."Line No.", 0, 9) + '">' +
                              '<glob1:retail_id>' + Format(POSSalesLine.SystemId) + '</glob1:retail_id>' +
                              '<glob1:type>' + Format(POSSalesLine.Type, 0, 2) + '</glob1:type>' +
                              '<glob1:no>' + POSSalesLine."No." + '</glob1:no>' +
                              '<glob1:variant_code>' + POSSalesLine."Variant Code" + '</glob1:variant_code>' +
                              '<glob1:cross_reference_no>' + POSSalesLine."Cross-Reference No." + '</glob1:cross_reference_no>' +
                              '<glob1:bom_item_no>' + POSSalesLine."BOM Item No." + '</glob1:bom_item_no>' +
                              '<glob1:location_code>' + POSSalesLine."Location Code" + '</glob1:location_code>' +
                              '<glob1:description><![CDATA[' + POSSalesLine.Description + ']]></glob1:description>' +
                              '<glob1:description_2><![CDATA[' + POSSalesLine."Description 2" + ']]></glob1:description_2>' +
                              '<glob1:quantity>' + Format(POSSalesLine.Quantity, 0, 9) + '</glob1:quantity>' +
                              '<glob1:unit_of_measure_code>' + POSSalesLine."Unit of Measure Code" + '</glob1:unit_of_measure_code>' +
                              '<glob1:qty_per_unit_of_measure>' + Format(POSSalesLine."Qty. per Unit of Measure", 0, 9) + '</glob1:qty_per_unit_of_measure>' +
                              '<glob1:quantity_base>' + Format(POSSalesLine."Quantity (Base)", 0, 9) + '</glob1:quantity_base>' +
                              '<glob1:unit_price>' + Format(POSSalesLine."Unit Price", 0, 9) + '</glob1:unit_price>' +
                              '<glob1:currency_code>' + POSSalesLine."Currency Code" + '</glob1:currency_code>' +
                              '<glob1:vat_pct>' + Format(POSSalesLine."VAT %", 0, 9) + '</glob1:vat_pct>' +
                              '<glob1:line_discount_pct>' + Format(POSSalesLine."Line Discount %", 0, 9) + '</glob1:line_discount_pct>' +
                              '<glob1:line_discount_amount_excl_vat>' + Format(POSSalesLine."Line Discount Amount Excl. VAT", 0, 9) + '</glob1:line_discount_amount_excl_vat>' +
                              '<glob1:line_discount_amount_incl_vat>' + Format(POSSalesLine."Line Discount Amount Incl. VAT", 0, 9) + '</glob1:line_discount_amount_incl_vat>' +
                              '<glob1:line_amount>' + Format(POSSalesLine."Line Amount", 0, 9) + '</glob1:line_amount>' +
                              '<glob1:amount_excl_vat>' + Format(POSSalesLine."Amount Excl. VAT", 0, 9) + '</glob1:amount_excl_vat>' +
                              '<glob1:amount_incl_vat>' + Format(POSSalesLine."Amount Incl. VAT", 0, 9) + '</glob1:amount_incl_vat>' +
                              '<glob1:line_discount_amount_excl_vat_lcy>' + Format(POSSalesLine."Line Dsc. Amt. Excl. VAT (LCY)", 0, 9) + '</glob1:line_discount_amount_excl_vat_lcy>' +
                              '<glob1:line_discount_amount_incl_vat_lcy>' + Format(POSSalesLine."Line Dsc. Amt. Incl. VAT (LCY)", 0, 9) + '</glob1:line_discount_amount_incl_vat_lcy>' +
                              '<glob1:amount_excl_vat_lcy>' + Format(POSSalesLine."Amount Excl. VAT (LCY)", 0, 9) + '</glob1:amount_excl_vat_lcy>' +
                              '<glob1:amount_incl_vat_lcy>' + Format(POSSalesLine."Amount Incl. VAT (LCY)", 0, 9) + '</glob1:amount_incl_vat_lcy>' +
                              '<glob1:global_reference>' + POSCrossReference."Reference No." + '</glob1:global_reference>' +
                              '<glob1:extension_fields/>' +
                            '</glob1:sales_line>';
            until POSSalesLine.Next() = 0;
        Xml +=
                     '</glob1:sales_lines>' +
                     '<glob1:pos_info_entries>';
        POSInfoPOSEntry.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSInfoPOSEntry.FindSet() then
            repeat
                Xml +=
                            '<glob1:pos_info_entry pos_info_code="' + POSInfoPOSEntry."POS Info Code" + '" entry_no="' + Format(POSInfoPOSEntry."Entry No.", 0, 9) + '">' +
                              '<glob1:sales_line_no>' + Format(POSInfoPOSEntry."Sales Line No.", 0, 9) + '</glob1:sales_line_no>' +
                              '<glob1:pos_info>' + POSInfoPOSEntry."POS Info" + '</glob1:pos_info>' +
                              '<glob1:no>' + POSInfoPOSEntry."No." + '</glob1:no>' +
                              '<glob1:quantity>' + Format(POSInfoPOSEntry.Quantity, 0, 9) + '</glob1:quantity>' +
                              '<glob1:price>' + Format(POSInfoPOSEntry.Price, 0, 9) + '</glob1:price>' +
                              '<glob1:net_amount>' + Format(POSInfoPOSEntry."Net Amount", 0, 9) + '</glob1:net_amount>' +
                              '<glob1:gross_amount>' + Format(POSInfoPOSEntry."Gross Amount", 0, 9) + '</glob1:gross_amount>' +
                              '<glob1:discount_amount>' + Format(POSInfoPOSEntry."Discount Amount", 0, 9) + '</glob1:discount_amount>' +
                          '</glob1:pos_info_entry>';
            until POSInfoPOSEntry.Next() = 0;
        Xml +=
                 '</glob1:pos_info_entries>' +
                 '<glob1:pos_payment_lines>';
        POSPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        if POSPaymentLine.FindSet() then
            repeat
                Xml +=
                    '<glob1:payment_line payline_no="' + Format(POSPaymentLine."Line No.", 0, 9) + '">' +
                      '<glob1:paydoc_no>' + Format(POSPaymentLine."Document No.") + '</glob1:paydoc_no>' +
                      '<glob1:payMethod>' + Format(POSPaymentLine."POS Payment Method Code") + '</glob1:payMethod>' +
                      '<glob1:payDesc>' + Format(POSPaymentLine.Description) + '</glob1:payDesc>' +
                      '<glob1:payAmount>' + Format(POSPaymentLine."Payment Amount", 0, 9) + '</glob1:payAmount>' +
                      '<glob1:currencyCode>' + Format(POSPaymentLine."Currency Code") + '</glob1:currencyCode>' +
                      '<glob1:amountLCY>' + Format(POSPaymentLine."Amount (LCY)", 0, 9) + '</glob1:amountLCY>' +
                    '</glob1:payment_line>';
            until POSPaymentLine.Next() = 0;
        Xml += '</glob1:pos_payment_lines>' +
                   '</glob1:sales_entry>' +
                 '</glob:sales_entries>' +
               '</glob:InsertPosSalesEntries>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        POSSalesWS.OnInitRequestBody(POSEntry, Xml);
    end;

    procedure InitGlobalPosSalesService()
    var
        WebService: Record "Web Service Aggregate";
        WebServiceManagement: Codeunit "Web Service Management";
    begin
        if not WebService.ReadPermission then
            exit;

        if not WebService.WritePermission then
            exit;

        WebServiceManagement.CreateTenantWebService(WebService."Object Type"::Codeunit, GlobalPosSalesCodeunitId(), 'global_pos_sales_service', true);
    end;

    procedure GetServiceName(Url: Text) ServiceName: Text
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
        exit(Codeunit::"NPR NpGp POS Sales WS");
    end;

    [Obsolete('Use codeunit 6150978 "NPR NpGp Try Get Glob Pos Serv"', '2023-06-28')]
    [TryFunction]
    procedure TryGetGlobalPosSalesService(NpGpPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    var
        RequestMessage: HttpRequestMessage;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ResponseMessage: HttpResponseMessage;
        Client: HttpClient;
    begin
        NpGpPOSSalesSetup.TestField("Service Url");

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Remove('Connection');

        NpGpPOSSalesSetup.SetRequestHeadersAuthorization(RequestHeaders);

        RequestMessage.Method := 'GET';
        RequestMessage.SetRequestUri(NpGpPOSSalesSetup."Service Url");

        Client.Send(RequestMessage, ResponseMessage);
        if not ResponseMessage.IsSuccessStatusCode then
            Error(ResponseMessage.ReasonPhrase);
    end;

    local procedure XmlEscape(Input: Text) Output: Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        Output := TypeHelper.HtmlEncode(Input);
        exit(Output);
    end;

    [Obsolete('Pending removal use OnInitRequestBody instead', '2023-06-28')]
    [IntegrationEvent(false, false)]
    local procedure OnInitReqBody(POSEntry: Record "NPR POS Entry"; var XmlDoc: XmlDocument)
    begin
    end;
}
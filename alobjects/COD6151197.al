codeunit 6151197 "NpCs Send Order"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190717  CASE 344264 Added <store_stock> to InitReqBody()
    // NPR5.51/MHA /20190719  CASE 342443 Added <opening_hour_set>
    // NPR5.51/MHA /20190719  CASE 362197 Added <to_store>
    // NPR5.51/MHA /20190821  CASE 364557 Added <post_on>


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Create Collect Sales Order in Store';
        Text001: Label 'Order %1 sent to Store %2';

    [EventSubscriber(ObjectType::Codeunit, 6151196, 'SendOrder', '', true, true)]
    local procedure SendOrder(var NpCsDocument: Record "NpCs Document";var LogMessage: Text)
    var
        NpCsStore: Record "NpCs Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Credential: DotNet npNetNetworkCredential;
        HttpWebRequest: DotNet npNetHttpWebRequest;
        HttpWebResponse: DotNet npNetHttpWebResponse;
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
        WebException: DotNet npNetWebException;
        ExceptionMessage: Text;
    begin
        if not (NpCsDocument."Send Order Module" in ['',WorkflowCode()]) then
          exit;

        LogMessage := StrSubstNo(Text001,NpCsDocument."Document No.",NpCsDocument."To Store Code");

        InitReqBody(NpCsDocument,XmlDoc);
        NpCsStore.Get(NpCsDocument."To Store Code");
        HttpWebRequest := HttpWebRequest.CreateHttp(NpCsStore."Service Url");
        HttpWebRequest.ContentType := 'text/xml;charset=UTF-8';
        HttpWebRequest.Headers.Add('SOAPAction','ImportSalesDocuments');
        HttpWebRequest.Method := 'POST';
        HttpWebRequest.UseDefaultCredentials(false);
        Credential := Credential.NetworkCredential(NpCsStore."Service Username",NpCsStore."Service Password");
        HttpWebRequest.Credentials(Credential);
        if not NpXmlDomMgt.SendWebRequest(XmlDoc,HttpWebRequest,HttpWebResponse,WebException) then begin
          ExceptionMessage := NpXmlDomMgt.GetWebExceptionMessage(WebException);
          if NpXmlDomMgt.TryLoadXml(ExceptionMessage,XmlDoc) then begin
            if NpXmlDomMgt.FindNode(XmlDoc.DocumentElement,'//faultstring',XmlElement) then
              ExceptionMessage := XmlElement.InnerText;
          end;

          Error(CopyStr(ExceptionMessage,1,1020));
        end;
    end;

    local procedure InitReqBody(NpCsDocument: Record "NpCs Document";var XmlDoc: DotNet npNetXmlDocument)
    var
        Customer: Record Customer;
        NpCsStore: Record "NpCs Store";
        NpCsStoreLocal: Record "NpCs Store";
        NpCsWorkflow: Record "NpCs Workflow";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ServiceName: Text;
        Content: Text;
        CustNo: Text;
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order,NpCsDocument."Document No.");
        Customer.Get(SalesHeader."Sell-to Customer No.");
        NpCsStore.Get(NpCsDocument."To Store Code");
        ServiceName := NpCsStore.GetServiceName();
        NpCsWorkflow.Get(NpCsDocument."Workflow Code");

        CustNo := SalesHeader."Sell-to Customer No.";
        if NpCsWorkflow."Customer Mapping" = NpCsWorkflow."Customer Mapping"::"Fixed Customer No." then begin
          NpCsWorkflow.TestField("Fixed Customer No.");
          CustNo := NpCsWorkflow."Fixed Customer No.";
        end;

        NpCsStoreLocal.Get(NpCsDocument."From Store Code");
        Content :=
          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
            '<soapenv:Header/>' +
            '<soapenv:Body>' +
              '<ImportSalesDocuments xmlns="urn:microsoft-dynamics-schemas/codeunit/' + ServiceName + '">' +
                '<sales_documents>' +
                  '<sales_document xmlns="urn:microsoft-dynamics-nav/xmlports/collect_in_store_sales_document"' +
                  ' document_type="' + Format(NpCsDocument."Document Type",0,2) + '" document_no="' + NpCsDocument."Document No." + '">' +
                    '<reference_no>' + NpCsDocument."Reference No." + '</reference_no>' +
                    '<to_document_type>' + Format(NpCsDocument."To Document Type",0,2) + '</to_document_type>' +
                    '<from_store store_code="' + NpCsStoreLocal.Code + '">' +
                      '<company_name>' + NpCsStoreLocal."Company Name" + '</company_name>' +
                      '<name>' + NpCsStoreLocal.Name + '</name>' +
                      '<service_url>' + NpCsStoreLocal."Service Url" + '</service_url>' +
                      '<service_username>' + NpCsStoreLocal."Service Username" + '</service_username>' +
                      '<service_password>' + NpCsStoreLocal."Service Password" + '</service_password>' +
                      '<email>' + NpCsStoreLocal."E-mail" + '</email>' +
                      '<mobile_phone_no>' + NpCsStoreLocal."Mobile Phone No." + '</mobile_phone_no>' +
                      '<callback encoding="base64">' + InitCallback(NpCsDocument) + '</callback>' +
                    '</from_store>' +
                    //-NPR5.51 [362197]
                    '<to_store store_code="' + NpCsDocument."To Store Code" + '">' +
                    '</to_store>' +
                    //+NPR5.51 [362197]
                    '<order_date>' + Format(SalesHeader."Order Date",0,9) + '</order_date>' +
                    '<posting_date>' + Format(SalesHeader."Posting Date",0,9) + '</posting_date>' +
                    '<due_date>' + Format(SalesHeader."Due Date",0,9)  + '</due_date>' +
                    '<sell_to_customer customer_no="' + CustNo + '" customer_mapping="' + Format(NpCsWorkflow."Customer Mapping",0,2) + '">' +
                      '<name>' + SalesHeader."Sell-to Customer Name" + '</name>' +
                      '<name_2>' + SalesHeader."Sell-to Customer Name 2" + '</name_2>' +
                      '<address>' + SalesHeader."Sell-to Address" + '</address>' +
                      '<address_2>' + SalesHeader."Sell-to Address 2" + '</address_2>' +
                      '<post_code>' + SalesHeader."Sell-to Post Code" + '</post_code>' +
                      '<city>' + SalesHeader."Sell-to City" + '</city>' +
                      '<country_code>' + SalesHeader."Sell-to Country/Region Code" + '</country_code>' +
                      '<contact>' + SalesHeader."Sell-to Contact" + '</contact>' +
                      '<phone_no>' + NpCsDocument."Customer Phone No." + '</phone_no>' +
                      '<email>' + NpCsDocument."Customer E-mail" + '</email>' +
                    '</sell_to_customer>' +
                    '<notification>' +
                      '<send_notification_from_store>' + Format(NpCsDocument."Send Notification from Store",0,9) + '</send_notification_from_store>' +
                      '<notify_customer_via_email>' + Format(NpCsDocument."Notify Customer via E-mail",0,9) + '</notify_customer_via_email>' +
                      '<email_template_pending>' + NpCsDocument."E-mail Template (Pending)" + '</email_template_pending>' +
                      '<email_template_confirmed>' + NpCsDocument."E-mail Template (Confirmed)" + '</email_template_confirmed>' +
                      '<email_template_rejected>' + NpCsDocument."E-mail Template (Rejected)" + '</email_template_rejected>' +
                      '<email_template_expired>' + NpCsDocument."E-mail Template (Expired)" + '</email_template_expired>' +
                      '<notify_customer_via_sms>' + Format(NpCsDocument."Notify Customer via Sms",0,9) + '</notify_customer_via_sms>' +
                      '<sms_template_pending>' + NpCsDocument."Sms Template (Pending)" + '</sms_template_pending>' +
                      '<sms_template_confirmed>' + NpCsDocument."Sms Template (Confirmed)" + '</sms_template_confirmed>' +
                      '<sms_template_rejected>' + NpCsDocument."Sms Template (Rejected)" + '</sms_template_rejected>' +
                      '<sms_template_expired>' + NpCsDocument."Sms Template (Expired)" + '</sms_template_expired>' +
                      //-NPR5.51 [362443]
                      '<opening_hour_set>' + NpCsDocument."Opening Hour Set" + '</opening_hour_set>' +
                      //+NPR5.51 [362443]
                      '<processing_expiry_duration>' + Format(NpCsDocument."Processing Expiry Duration",0,9) + '</processing_expiry_duration>' +
                      '<delivery_expiry_days_qty>' + Format(NpCsDocument."Delivery Expiry Days (Qty.)",0,9) + '</delivery_expiry_days_qty>' +
                    '</notification>' +
                    '<bill_to_customer_no>' + NpCsStore."Bill-to Customer No." + '</bill_to_customer_no>' +
                    '<archive_on_delivery>' + Format(NpCsDocument."Archive on Delivery",0,9) + '</archive_on_delivery>' +
                    //-NPR5.51 [344264]
                    '<store_stock>' + Format(NpCsDocument."Store Stock",0,9) + '</store_stock>' +
                    //+NPR5.51 [344264]
                    //-NPR5.51 [364557]
                    '<post_on>' + Format(NpCsDocument."Post on",0,2) + '</post_on>' +
                    //+NPR5.51 [364557]
                    '<bill_via>' + Format(NpCsDocument."Bill via",0,2) + '</bill_via>' +
                    //-NPR5.51 [364557]
                    '<processing_print_template>' + NpCsDocument."Processing Print Template" + '</processing_print_template>' +
                    //+NPR5.51 [364557]
                    '<delivery_print_template_pos>' + NpCsDocument."Delivery Print Template (POS)" + '</delivery_print_template_pos>' +
                    '<delivery_print_template_sales_doc>' + NpCsDocument."Delivery Print Template (S.)" + '</delivery_print_template_sales_doc>' +
                    '<prepaid_amount>' + Format(NpCsDocument."Prepaid Amount",0,9) + '</prepaid_amount>' +
                    '<prepayment_account_no>' + NpCsDocument."Prepayment Account No." + '</prepayment_account_no>' +
                    '<location_code>' + NpCsStore."Location Code"  + ' </location_code>' +
                    '<salesperson_code>' + NpCsStore."Salesperson Code" + '</salesperson_code>' +
                    '<payment_method_code>' + NpCsWorkflow."Payment Method Code" + '</payment_method_code>' +
                    '<shipment_method_code>' + NpCsWorkflow."Shipment Method Code" + '</shipment_method_code>' +
                    '<prices_including_vat>' + Format(SalesHeader."Prices Including VAT",0,9) + '</prices_including_vat>' +
                    '<sales_lines>';

        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        if SalesLine.FindSet then
          repeat
            Content +=
                      '<sales_line line_no="' + Format(SalesLine."Line No.",0,9) + '">' +
                        '<type>' + Format(SalesLine.Type,0,2) + '</type>' +
                        '<no>' + SalesLine."No." + '</no>' +
                        '<variant_code>' + SalesLine."Variant Code" + '</variant_code>' +
                        '<cross_reference_no>' + GetCrossRefNo(SalesLine) + '</cross_reference_no>' +
                        '<unit_of_measure_code>' + SalesLine."Unit of Measure Code" + '</unit_of_measure_code>' +
                        '<description>' + SalesLine.Description + '</description>' +
                        '<description_2>' + SalesLine."Description 2" + '</description_2>' +
                        '<unit_price>' + Format(SalesLine."Unit Price",0,9) + '</unit_price>' +
                        '<quantity>' + Format(SalesLine.Quantity,0,9) + '</quantity>' +
                        '<line_discount_pct>' + Format(SalesLine."Line Discount %",0,9) + '</line_discount_pct>' +
                        '<line_discount_amount>' + Format(SalesLine."Line Discount Amount",0,9) + '</line_discount_amount>' +
                        '<vat_pct>' + Format(SalesLine."VAT %",0,9) + '</vat_pct>' +
                        '<line_amount>' + Format(SalesLine."Line Amount",0,9) + '</line_amount>' +
                      '</sales_line>';
          until SalesLine.Next = 0;

        Content +=
                    '</sales_lines>' +
                  '</sales_document>' +
                '</sales_documents>' +
              '</ImportSalesDocuments>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.LoadXml(Content);
    end;

    local procedure InitCallback(NpCsDocument: Record "NpCs Document") Callback: Text
    var
        NpCsStore: Record "NpCs Store";
        Encoding: DotNet npNetEncoding;
        Convert: DotNet npNetConvert;
    begin
        NpCsStore.Get(NpCsDocument."From Store Code");
        if NpCsStore."Service Url" = '' then
          exit;

        Callback :=
          '<callback>' +
            '<content_type>text/xml;charset=UTF-8</content_type>' +
            '<headers>' +
              '<header name="SOAPAction">RunNextWorkflowStep</header>' +
            '</headers>' +
            '<method>POST</method>' +
            '<request_body><![CDATA[' +
              '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<soapenv:Body>' +
                  '<RunNextWorkflowStep xmlns="urn:microsoft-dynamics-schemas/codeunit/collect_in_store_service">' +
                    '<collect_documents>' +
                      '<collect_document' +
                      ' type="' + Format(NpCsDocument.Type,0,2) + '"' +
                      ' from_document_type="' + Format(NpCsDocument."Document Type",0,2) + '"' +
                      ' from_document_no="' + NpCsDocument."Document No." + '"' +
                      ' from_store_code="' + NpCsDocument."From Store Code" + '"' +
                      ' xmlns="urn:microsoft-dynamics-nav/xmlports/collect_document">' +
                        '<reference_no>' + NpCsDocument."Reference No." + '</reference_no>' +
                      '</collect_document>' +
                    '</collect_documents>' +
                  '</RunNextWorkflowStep>' +
                '</soapenv:Body>' +
              '</soapenv:Envelope>' +
            ']]></request_body>' +
          '</callback>';

        Callback := Convert.ToBase64String(Encoding.UTF8.GetBytes(Callback));
        exit(Callback);
    end;

    local procedure "--- Init"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151196, 'OnInitWorkflowModules', '', true, true)]
    local procedure OnInitWorkflowModules(var NpCsWorkflowModule: Record "NpCs Workflow Module")
    begin
        if not NpCsWorkflowModule.WritePermission then
          exit;

        if NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Send Order",WorkflowCode()) then
          exit;

        NpCsWorkflowModule.Init;
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Send Order";
        NpCsWorkflowModule.Code := WorkflowCode();
        NpCsWorkflowModule.Description := CopyStr(Text000,1,MaxStrLen(NpCsWorkflowModule.Description));
        NpCsWorkflowModule."Event Codeunit ID" := CurrCodeunitId();
        NpCsWorkflowModule.Insert(true);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NpCs Send Order");
    end;

    local procedure GetCrossRefNo(SalesLine: Record "Sales Line") CrossRefNo: Code[20]
    var
        ItemCrossRef: Record "Item Cross Reference";
    begin
        if SalesLine."Cross-Reference No." <> '' then
          exit(SalesLine."Cross-Reference No.");
        if SalesLine.Type <> SalesLine.Type::Item then
          exit('');

        ItemCrossRef.SetRange("Item No.",SalesLine."No.");
        ItemCrossRef.SetRange("Variant Code",SalesLine."Variant Code");
        ItemCrossRef.SetRange("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::"Bar Code");
        ItemCrossRef.SetFilter("Cross-Reference No.",'<>%1','');
        ItemCrossRef.SetRange("Discontinue Bar Code",false);
        if not ItemCrossRef.FindFirst then
          ItemCrossRef.SetRange("Discontinue Bar Code");
        if ItemCrossRef.FindFirst then
          exit(ItemCrossRef."Cross-Reference No.");

        exit('');
    end;

    procedure WorkflowCode(): Code[20]
    begin
        exit('SALES_ORDER');
    end;
}


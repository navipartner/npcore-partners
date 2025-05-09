﻿codeunit 6151197 "NPR NpCs Send Order"
{
    Access = Internal;

    var
        CreateCollectOrderLbl: Label 'Create Collect Sales Order in Store';
        OrderSentToStoreLbl: Label 'Order %1 sent to Store %2', Comment = '%1=NpCsDocument."Document No.";%2=NpCsDocument."To Store Code"';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpCs Workflow Mgt.", 'SendOrder', '', true, true)]
    local procedure SendOrder(var NpCsDocument: Record "NPR NpCs Document"; var LogMessage: Text)
    var
        NpCsStore: Record "NPR NpCs Store";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        [NonDebuggable]
        RequestHeaders: HttpHeaders;
        ContentText: Text;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        Document: XmlDocument;
        Node: XmlNode;
        ExceptionMessage: Text;
    begin
        if not (NpCsDocument."Send Order Module" in ['', WorkflowCode()]) then
            exit;

        LogMessage := StrSubstNo(OrderSentToStoreLbl, NpCsDocument."Document No.", NpCsDocument."To Store Code");

        InitReqBody(NpCsDocument, ContentText);
        NpCsStore.Get(NpCsDocument."To Store Code");

        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        Content.WriteFrom(ContentText);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'text/xml;charset=UTF-8');
        RequestMessage.Content(Content);

        RequestMessage.SetRequestUri(NpCsStore."Service Url");
        RequestMessage.Method('POST');

        RequestMessage.GetHeaders(RequestHeaders);
        RequestHeaders.Add('SOAPAction', 'ImportSalesDocuments');

        NpCsStore.SetRequestHeadersAuthorization(RequestHeaders);

        Client.Send(RequestMessage, ResponseMessage);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            ResponseMessage.Content().ReadAs(ExceptionMessage);
            if XmlDocument.ReadFrom(ExceptionMessage, Document) then begin
                if NpXmlDomMgt.FindNode(Document.AsXmlNode(), '//faultstring', Node) then
                    ExceptionMessage := Node.AsXmlElement().InnerText();
            end;

            Error(CopyStr(ExceptionMessage, 1, 1020));
        end;
    end;

    local procedure InitReqBody(NpCsDocument: Record "NPR NpCs Document"; var Content: Text)
    var
        Customer: Record Customer;
        NpCsStore: Record "NPR NpCs Store";
        NpCsStoreLocal: Record "NPR NpCs Store";
        NpCsWorkflow: Record "NPR NpCs Workflow";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ClickCollect: Codeunit "NPR Click & Collect";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        ServiceName: Text;
        CustNo: Text;
    begin
        SalesHeader.Get(SalesHeader."Document Type"::Order, NpCsDocument."Document No.");
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
                  ' document_type="' + Format(NpCsDocument."Document Type", 0, 2) + '" document_no="' + Escape(NpCsDocument."Document No.") + '">' +
                    '<reference_no>' + Escape(NpCsDocument."Reference No.") + '</reference_no>' +
                    '<to_document_type>' + Format(NpCsDocument."To Document Type", 0, 2) + '</to_document_type>' +
                    '<from_store store_code="' + Escape(NpCsStoreLocal.Code) + '">' +
                      '<company_name>' + Escape(NpCsStoreLocal."Company Name") + '</company_name>' +
                      '<name>' + Escape(NpCsStoreLocal.Name) + '</name>' +
                      '<service_url>' + Escape(NpCsStoreLocal."Service Url") + '</service_url>' +
                      '<service_username>' + Escape(NpCsStoreLocal."Service Username") + '</service_username>' +
                      '<service_password>' + Escape(WebServiceAuthHelper.GetApiPassword(NpCsStoreLocal."API Password Key")) + '</service_password>' +
                      '<email>' + Escape(NpCsStoreLocal."E-mail") + '</email>' +
                      '<mobile_phone_no>' + Escape(NpCsStoreLocal."Mobile Phone No.") + '</mobile_phone_no>' +
                      '<callback encoding="base64">' + InitCallback(NpCsDocument) + '</callback>' +
                    '</from_store>' +
                    '<to_store store_code="' + Escape(NpCsDocument."To Store Code") + '" />' +
                    '<processing_status>' + Format(NpCsDocument."Processing Status"::Pending, 0, 2) + '</processing_status>' +
                    '<order_date>' + Format(SalesHeader."Order Date", 0, 9) + '</order_date>' +
                    '<posting_date>' + Format(SalesHeader."Posting Date", 0, 9) + '</posting_date>' +
                    '<due_date>' + Format(SalesHeader."Due Date", 0, 9) + '</due_date>' +
                    '<sell_to_customer customer_no="' + Escape(CustNo) + '" customer_mapping="' + Format(NpCsWorkflow."Customer Mapping", 0, 2) + '">' +
                      '<name>' + Escape(SalesHeader."Sell-to Customer Name") + '</name>' +
                      '<name_2>' + Escape(SalesHeader."Sell-to Customer Name 2") + '</name_2>' +
                      '<address>' + Escape(SalesHeader."Sell-to Address") + '</address>' +
                      '<address_2>' + Escape(SalesHeader."Sell-to Address 2") + '</address_2>' +
                      '<post_code>' + Escape(SalesHeader."Sell-to Post Code") + '</post_code>' +
                      '<city>' + Escape(SalesHeader."Sell-to City") + '</city>' +
                      '<country_code>' + Escape(SalesHeader."Sell-to Country/Region Code") + '</country_code>' +
                      '<contact>' + Escape(SalesHeader."Sell-to Contact") + '</contact>' +
                      '<phone_no>' + Escape(NpCsDocument."Customer Phone No.") + '</phone_no>' +
                      '<email>' + Escape(NpCsDocument."Customer E-mail") + '</email>' +
                    '</sell_to_customer>' +
                    '<notification>' +
                      '<send_notification_from_store>' + Format(NpCsDocument."Send Notification from Store", 0, 9) + '</send_notification_from_store>' +
                      '<notify_customer_via_email>' + Format(NpCsDocument."Notify Customer via E-mail", 0, 9) + '</notify_customer_via_email>' +
                      '<email_template_pending>' + Escape(NpCsDocument."E-mail Template (Pending)") + '</email_template_pending>' +
                      '<email_template_confirmed>' + Escape(NpCsDocument."E-mail Template (Confirmed)") + '</email_template_confirmed>' +
                      '<email_template_rejected>' + Escape(NpCsDocument."E-mail Template (Rejected)") + '</email_template_rejected>' +
                      '<email_template_expired>' + Escape(NpCsDocument."E-mail Template (Expired)") + '</email_template_expired>' +
                      '<notify_customer_via_sms>' + Format(NpCsDocument."Notify Customer via Sms", 0, 9) + '</notify_customer_via_sms>' +
                      '<sms_template_pending>' + Escape(NpCsDocument."Sms Template (Pending)") + '</sms_template_pending>' +
                      '<sms_template_confirmed>' + Escape(NpCsDocument."Sms Template (Confirmed)") + '</sms_template_confirmed>' +
                      '<sms_template_rejected>' + Escape(NpCsDocument."Sms Template (Rejected)") + '</sms_template_rejected>' +
                      '<sms_template_expired>' + Escape(NpCsDocument."Sms Template (Expired)") + '</sms_template_expired>' +
                      '<opening_hour_set>' + Escape(NpCsDocument."Opening Hour Set") + '</opening_hour_set>' +
                      '<processing_expiry_duration>' + Format(NpCsDocument."Processing Expiry Duration", 0, 9) + '</processing_expiry_duration>' +
                      '<delivery_expiry_days_qty>' + Format(NpCsDocument."Delivery Expiry Days (Qty.)", 0, 9) + '</delivery_expiry_days_qty>' +
                    '</notification>' +
                    '<bill_to_customer_no>' + Escape(NpCsStore."Bill-to Customer No.") + '</bill_to_customer_no>' +
                    '<ship_to_contact>' + Escape(NpCsDocument."Ship-to Contact") + '</ship_to_contact>' +
                    '<archive_on_delivery>' + Format(NpCsDocument."Archive on Delivery", 0, 9) + '</archive_on_delivery>' +
                    '<store_stock>' + Format(NpCsDocument."Store Stock", 0, 9) + '</store_stock>' +
                    '<post_on>' + Format(NpCsDocument."Post on", 0, 2) + '</post_on>' +
                    '<bill_via>' + Format(NpCsDocument."Bill via", 0, 2) + '</bill_via>' +
                    '<processing_print_template>' + Escape(NpCsDocument."Processing Print Template") + '</processing_print_template>' +
                    '<delivery_print_template_pos>' + Escape(NpCsDocument."Delivery Print Template (POS)") + '</delivery_print_template_pos>' +
                    '<delivery_print_template_sales_doc>' + Escape(NpCsDocument."Delivery Print Template (S.)") + '</delivery_print_template_sales_doc>' +
                    '<prepaid_amount>' + Format(NpCsDocument."Prepaid Amount", 0, 9) + '</prepaid_amount>' +
                    '<prepayment_account_no>' + Escape(NpCsDocument."Prepayment Account No.") + '</prepayment_account_no>' +
                    '<location_code>' + Escape(NpCsStore."Location Code") + ' </location_code>' +
                    '<salesperson_code>' + Escape(NpCsStore."Salesperson Code") + '</salesperson_code>' +
                    '<payment_method_code>' + Escape(NpCsWorkflow."Payment Method Code") + '</payment_method_code>' +
                    '<shipment_method_code>' + Escape(NpCsWorkflow."Shipment Method Code") + '</shipment_method_code>' +
                    '<prices_including_vat>' + Format(SalesHeader."Prices Including VAT", 0, 9) + '</prices_including_vat>' +
                    '<sales_lines>';

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindSet() then
            repeat
                Content +=
                          '<sales_line line_no="' + Format(SalesLine."Line No.", 0, 9) + '">' +
                            '<type>' + Format(SalesLine.Type, 0, 2) + '</type>' +
                            '<no>' + Escape(SalesLine."No.") + '</no>' +
                            '<variant_code>' + Escape(SalesLine."Variant Code") + '</variant_code>' +
                            '<cross_reference_no>' + Escape(GetItemRefNo(SalesLine)) + '</cross_reference_no>' +
                            '<unit_of_measure_code>' + Escape(SalesLine."Unit of Measure Code") + '</unit_of_measure_code>' +
                            '<description>' + Escape(SalesLine.Description) + '</description>' +
                            '<description_2>' + Escape(SalesLine."Description 2") + '</description_2>' +
                            '<unit_price>' + Format(SalesLine."Unit Price", 0, 9) + '</unit_price>' +
                            '<quantity>' + Format(SalesLine.Quantity, 0, 9) + '</quantity>' +
                            '<line_discount_pct>' + Format(SalesLine."Line Discount %", 0, 9) + '</line_discount_pct>' +
                            '<line_discount_amount>' + Format(SalesLine."Line Discount Amount", 0, 9) + '</line_discount_amount>' +
                            '<vat_pct>' + Format(SalesLine."VAT %", 0, 9) + '</vat_pct>' +
                            '<line_amount>' + Format(SalesLine."Line Amount", 0, 9) + '</line_amount>' +
                          '</sales_line>';
            until SalesLine.Next() = 0;

        Content +=
                    '</sales_lines>' +
                  '</sales_document>' +
                '</sales_documents>' +
              '</ImportSalesDocuments>' +
            '</soapenv:Body>' +
          '</soapenv:Envelope>';

        ClickCollect.OnAfterInitReqBody(NpCsDocument, Content);
    end;

    local procedure InitCallback(NpCsDocument: Record "NPR NpCs Document") Callback: Text
    var
        NpCsStore: Record "NPR NpCs Store";
        Base64Convert: Codeunit "Base64 Convert";
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
                      ' type="' + Format(NpCsDocument.Type, 0, 2) + '"' +
                      ' from_document_type="' + Format(NpCsDocument."Document Type", 0, 2) + '"' +
                      ' from_document_no="' + Escape(NpCsDocument."Document No.") + '"' +
                      ' from_store_code="' + Escape(NpCsDocument."From Store Code") + '"' +
                      ' xmlns="urn:microsoft-dynamics-nav/xmlports/collect_document">' +
                        '<reference_no>' + Escape(NpCsDocument."Reference No.") + '</reference_no>' +
                      '</collect_document>' +
                    '</collect_documents>' +
                  '</RunNextWorkflowStep>' +
                '</soapenv:Body>' +
              '</soapenv:Envelope>' +
            ']]></request_body>' +
          '</callback>';

        Callback := Base64Convert.ToBase64(Callback, TextEncoding::UTF8);

        exit(Callback);
    end;

    local procedure Escape(StringValue: Text): Text
    begin
        StringValue := StringValue.Replace('&', '&amp;');
        StringValue := StringValue.Replace('<', '&lt;');
        StringValue := StringValue.Replace('>', '&gt;');
        StringValue := StringValue.Replace('"', '&quot;');
        StringValue := StringValue.Replace('''', '&apos;');
        exit(StringValue);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR NpCs Workflow Mgt.", 'OnInitWorkflowModules', '', true, true)]
    local procedure OnInitWorkflowModules(var NpCsWorkflowModule: Record "NPR NpCs Workflow Module")
    begin
        if not NpCsWorkflowModule.WritePermission then
            exit;

        if NpCsWorkflowModule.Get(NpCsWorkflowModule.Type::"Send Order", WorkflowCode()) then
            exit;

        NpCsWorkflowModule.Init();
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Send Order";
        NpCsWorkflowModule.Code := WorkflowCode();
        NpCsWorkflowModule.Description := CopyStr(CreateCollectOrderLbl, 1, MaxStrLen(NpCsWorkflowModule.Description));
        NpCsWorkflowModule."Event Codeunit ID" := CurrCodeunitId();
        NpCsWorkflowModule.Insert(true);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR NpCs Send Order");
    end;

    local procedure GetItemRefNo(SalesLine: Record "Sales Line"): Code[50]
    var
        ItemRef: Record "Item Reference";
    begin
        if SalesLine."Item Reference No." <> '' then
            exit(SalesLine."Item Reference No.");
        if SalesLine.Type <> SalesLine.Type::Item then
            exit('');

        ItemRef.SetRange("Item No.", SalesLine."No.");
        ItemRef.SetRange("Variant Code", SalesLine."Variant Code");
        ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
        ItemRef.SetFilter("Reference No.", '<>%1', '');
        if ItemRef.FindFirst() then
            exit(ItemRef."Reference No.");

        exit('');
    end;

    procedure WorkflowCode(): Code[20]
    begin
        exit('SALES_ORDER');
    end;
}


codeunit 6151200 "NpCs Import Sales Document"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // #344264/MHA /20190717  CASE 344264 Added import of <config_template> in UpsertCustomer() and changed <delivery_only> to <pick_from_warehouse>
    // #362443/MHA /20190719  CASE 342443 Added <opening_hour_set>
    // #362197/MHA /20190719  CASE 362197 Added functions InsertToStore(), GetToStoreCode()

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlDoc: DotNet npNetXmlDocument;
        XmlElement: DotNet npNetXmlElement;
    begin
        if not Rec.LoadXmlDoc(XmlDoc) then
          Error(Text000);

        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        if IsNull(XmlDoc.DocumentElement) then
          Error(Text000);

        NpXmlDomMgt.FindElement(XmlDoc.DocumentElement,'sales_document',true,XmlElement);

        ImportSalesDoc(XmlElement);
    end;

    var
        Text000: Label 'Invalid Xml data';
        Text002: Label '%1 is blank in %2';
        Text004: Label 'Item %1 could not be mapped in line no. %2';
        Text005: Label 'Order received from Store %1';

    local procedure ImportSalesDoc(XmlElement: DotNet npNetXmlElement)
    var
        Customer: Record Customer;
        NpCsDocument: Record "NpCs Document";
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        SalesHeader: Record "Sales Header";
        NpCsExpirationMgt: Codeunit "NpCs Expiration Mgt.";
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        XmlElement2: DotNet npNetXmlElement;
        LogMessage: Text;
    begin
        if FindNpCsDocument(XmlElement,NpCsDocument) then
          exit;

        InitPOSSalesWorkflow();

        UpsertFromStore(XmlElement);
        //-#362197 [362197]
        InsertToStore(XmlElement);
        //+#362197 [362197]
        InsertDocumentMappings(XmlElement);
        Commit;

        UpsertCustomer(XmlElement,Customer);
        //-#344264 [#344264]
        InsertSalesHeader(XmlElement,Customer,SalesHeader);
        InsertCollectDocument(XmlElement,SalesHeader,NpCsDocument);
        //+#344264 [#344264]

        foreach XmlElement2 in XmlElement.SelectNodes('sales_lines/sales_line') do
          InsertSalesLine(XmlElement2,SalesHeader);

        LogMessage := StrSubstNo(Text005,NpCsDocument."From Store Code");
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Send Order";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument,NpCsWorkflowModule,LogMessage,false,'');
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
        Commit;
        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
        if NpCsDocument."Processing expires at" > 0DT then
          NpCsExpirationMgt.ScheduleUpdateExpirationStatus(NpCsDocument,NpCsDocument."Processing expires at");
    end;

    local procedure UpsertFromStore(XmlElement: DotNet npNetXmlElement)
    var
        NpCsStore: Record "NpCs Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        StoreCode: Code[20];
        PrevRec: Text;
    begin
        StoreCode := GetFromStoreCode(XmlElement);

        if not NpCsStore.Get(StoreCode) then begin
          NpCsStore.Init;
          NpCsStore.Code := StoreCode;
          NpCsStore.Insert(true);
        end;

        PrevRec := Format(NpCsStore);

        NpCsStore."Company Name" := NpXmlDomMgt.GetElementText(XmlElement,'from_store/company_name',MaxStrLen(NpCsStore."Company Name"),true);
        NpCsStore.Name := NpXmlDomMgt.GetElementText(XmlElement,'from_store/name',MaxStrLen(NpCsStore.Name),true);
        NpCsStore."Service Url" := NpXmlDomMgt.GetElementText(XmlElement,'from_store/service_url',MaxStrLen(NpCsStore."Service Url"),true);
        NpCsStore."Service Username" := NpXmlDomMgt.GetElementText(XmlElement,'from_store/service_username',MaxStrLen(NpCsStore."Service Username"),true);
        NpCsStore."Service Password" := NpXmlDomMgt.GetElementText(XmlElement,'from_store/service_password',MaxStrLen(NpCsStore."Service Password"),true);
        NpCsStore."E-mail" := NpXmlDomMgt.GetElementText(XmlElement,'from_store/email',MaxStrLen(NpCsStore."E-mail"),true);
        NpCsStore."Mobile Phone No." := NpXmlDomMgt.GetElementText(XmlElement,'from_store/mobile_phone_no',MaxStrLen(NpCsStore."Mobile Phone No."),true);

        if PrevRec <> Format(NpCsStore) then
          NpCsStore.Modify(true);
    end;

    local procedure InsertToStore(XmlElement: DotNet npNetXmlElement)
    var
        NpCsStore: Record "NpCs Store";
        StoreCode: Code[20];
    begin
        //-#362197 [362197]
        StoreCode := GetToStoreCode(XmlElement);
        if StoreCode = '' then
          exit;

        if not NpCsStore.Get(StoreCode) then begin
          NpCsStore.Init;
          NpCsStore.Code := StoreCode;
          NpCsStore."Local Store" := true;
          NpCsStore.Validate("Company Name",CompanyName);
          NpCsStore.Insert(true);
        end;
        //+#362197 [362197]
    end;

    local procedure InsertDocumentMappings(XmlElement: DotNet npNetXmlElement)
    var
        Customer: Record Customer;
        ItemVariant: Record "Item Variant";
        NpCsDocumentMapping: Record "NpCs Document Mapping";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement2: DotNet npNetXmlElement;
        FromStore: Code[20];
        FromNo: Code[20];
        Description: Text;
        Description2: Text;
    begin
        FromStore := GetFromStoreCode(XmlElement);

        FromNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'sell_to_customer','customer_no',MaxStrLen(NpCsDocumentMapping."From No."),true);
        Description := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/name',0,true);
        Description2 := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/name_2',0,false);
        InsertDocumentMapping(NpCsDocumentMapping.Type::"Customer No.",FromStore,FromNo,Description,Description2);
        if FindCustomer(XmlElement,Customer) then begin
          NpCsDocumentMapping.Get(NpCsDocumentMapping.Type::"Customer No.",FromStore,FromNo);
          NpCsDocumentMapping.Validate("To No.",Customer."No.");
          NpCsDocumentMapping.Modify(true);
        end;

        foreach XmlElement2 in XmlElement.SelectNodes('sales_lines/sales_line[type=2 and cross_reference_no!=""]') do begin
          FromNo := NpXmlDomMgt.GetElementCode(XmlElement2,'cross_reference_no',MaxStrLen(NpCsDocumentMapping."From No."),true);
          Description := NpXmlDomMgt.GetElementText(XmlElement2,'description',0,true);
          Description2 := NpXmlDomMgt.GetElementText(XmlElement2,'description_2',0,false);
          InsertDocumentMapping(NpCsDocumentMapping.Type::"Item Cross Reference No.",FromStore,FromNo,Description,Description2);
          FindItemVariant(XmlElement2,ItemVariant);
        end;
    end;

    local procedure InsertDocumentMapping(Type: Integer;FromStore: Code[20];FromNo: Code[20];Description: Text;Description2: Text)
    var
        NpCsDocumentMapping: Record "NpCs Document Mapping";
        PrevRec: Text;
    begin
        if FromStore = '' then
          exit;
        if FromNo = '' then
          exit;

        if not NpCsDocumentMapping.Get(Type,FromStore,FromNo) then begin
          NpCsDocumentMapping.Init;
          NpCsDocumentMapping.Type := Type;
          NpCsDocumentMapping."From Store Code" := FromStore;
          NpCsDocumentMapping."From No." := FromNo;
          NpCsDocumentMapping.Insert(true);
        end;

        PrevRec := Format(NpCsDocumentMapping);

        NpCsDocumentMapping."From Description" := CopyStr(Description,1,MaxStrLen(NpCsDocumentMapping."From Description"));
        NpCsDocumentMapping."From Description 2" := CopyStr(Description2,1,MaxStrLen(NpCsDocumentMapping."From Description 2"));

        if PrevRec <> Format(NpCsDocumentMapping) then
          NpCsDocumentMapping.Modify(true);
    end;

    local procedure UpsertCustomer(XmlElement: DotNet npNetXmlElement;var Customer: Record Customer)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        NpCsDocumentMapping: Record "NpCs Document Mapping";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        StoreCode: Code[20];
        CustNo: Code[20];
        ConfigTemplateCode: Code[10];
        PrevRec: Text;
    begin
        if not FindCustomer(XmlElement,Customer) then begin
          Customer.Init;
          Customer."No." := '';
          Customer.Insert(true);
        end;

        StoreCode := GetFromStoreCode(XmlElement);
        CustNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'sell_to_customer','customer_no',MaxStrLen(NpCsDocumentMapping."From No."),true);
        NpCsDocumentMapping.Get(NpCsDocumentMapping.Type::"Customer No.",StoreCode,CustNo);
        if NpCsDocumentMapping."To No." <> Customer."No." then begin
          NpCsDocumentMapping.Validate("To No.",Customer."No.");
          NpCsDocumentMapping.Modify(true);
        end;

        PrevRec := Format(Customer);

        //-#344264 [344264]
        ConfigTemplateCode := NpXmlDomMgt.GetElementCode(XmlElement,'sell_to_customer/config_template',MaxStrLen(ConfigTemplateHeader.Code),false);
        if (ConfigTemplateCode <> '') and ConfigTemplateHeader.Get(ConfigTemplateCode) then begin
          RecRef.GetTable(Customer);
          ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
          RecRef.SetTable(Customer);
        end;
        //+#344264 [344264]

        Customer.Validate(Name,NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/name',MaxStrLen(Customer.Name),true));
        Customer."Name 2" := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/name_2',MaxStrLen(Customer."Name 2"),true);
        Customer.Address := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/address',MaxStrLen(Customer.Address),true);
        Customer."Address 2" := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/address_2',MaxStrLen(Customer."Address 2"),true);
        Customer."Post Code" := NpXmlDomMgt.GetElementCode(XmlElement,'sell_to_customer/post_code',MaxStrLen(Customer."Post Code"),true);
        Customer.City := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/city',MaxStrLen(Customer.City),true);
        Customer.Validate("Country/Region Code",NpXmlDomMgt.GetElementCode(XmlElement,'sell_to_customer/country_code',MaxStrLen(Customer."Country/Region Code"),true));
        Customer.Contact := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/contact',MaxStrLen(Customer.Contact),true);
        Customer."Phone No." := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/phone_no',MaxStrLen(Customer."Phone No."),true);
        Customer."E-Mail" := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/email',MaxStrLen(Customer."E-Mail"),true);

        if PrevRec <> Format(Customer) then
          Customer.Modify(true);
    end;

    local procedure InsertSalesHeader(XmlElement: DotNet npNetXmlElement;Customer: Record Customer;var SalesHeader: Record "Sales Header")
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        DocNo: Text;
        BillToCustNo: Code[20];
    begin
        DocNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'','document_no',MaxStrLen(SalesHeader."No."),true);

        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Init;
        SalesHeader."Document Type" := NpXmlDomMgt.GetElementInt(XmlElement,'to_document_type',true);
        SalesHeader."No." := '';
        SalesHeader."External Order No." := CopyStr(DocNo,1,MaxStrLen(SalesHeader."External Order No."));
        SalesHeader."External Document No." := CopyStr(DocNo,1,MaxStrLen(SalesHeader."External Document No."));
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.",Customer."No.");
        SalesHeader.Validate("Posting Date",NpXmlDomMgt.GetElementDate(XmlElement,'posting_date',true));
        SalesHeader.Validate("Order Date",NpXmlDomMgt.GetElementDate(XmlElement,'posting_date',true));
        SalesHeader.Validate("Due Date",NpXmlDomMgt.GetElementDate(XmlElement,'due_date',true));
        BillToCustNo := NpXmlDomMgt.GetElementCode(XmlElement,'bill_to_customer_no',MaxStrLen(SalesHeader."Bill-to Customer No."),false);
        if BillToCustNo <> '' then
          SalesHeader.Validate("Bill-to Customer No.",BillToCustNo);
        SalesHeader.Validate("Location Code",NpXmlDomMgt.GetElementCode(XmlElement,'location_code',MaxStrLen(SalesHeader."Location Code"),true));
        SalesHeader.Validate("Salesperson Code",NpXmlDomMgt.GetElementCode(XmlElement,'salesperson_code',MaxStrLen(SalesHeader."Salesperson Code"),true));
        SalesHeader.Validate("Payment Method Code",NpXmlDomMgt.GetElementCode(XmlElement,'payment_method_code',MaxStrLen(SalesHeader."Payment Method Code"),true));
        SalesHeader.Validate("Shipment Method Code",NpXmlDomMgt.GetElementCode(XmlElement,'shipment_method_code',MaxStrLen(SalesHeader."Shipment Method Code"),true));
        SalesHeader.Modify(true);
    end;

    local procedure InsertCollectDocument(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var NpCsDocument: Record "NpCs Document")
    var
        NpCsExpirationMgt: Codeunit "NpCs Expiration Mgt.";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Callback: Text;
        DocType: Integer;
        DocNo: Text;
        StoreCode: Code[20];
        BillToCustNo: Code[20];
        OutStr: OutStream;
    begin
        //-#344264 [#344264]
        DocType := NpXmlDomMgt.GetAttributeInt(XmlElement,'','document_type',true);
        DocNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'','document_no',MaxStrLen(SalesHeader."No."),true);
        StoreCode := GetFromStoreCode(XmlElement);

        Callback := GetCallback(XmlElement);
        NpCsDocument.Init;
        NpCsDocument.Type := NpCsDocument.Type::"Collect in Store";
        NpCsDocument."Document Type" := SalesHeader."Document Type";
        NpCsDocument."Document No." := SalesHeader."No.";
        NpCsDocument."Reference No." := NpXmlDomMgt.GetElementCode(XmlElement,'reference_no',MaxStrLen(NpCsDocument."Reference No."),true);
        NpCsDocument."From Document Type" := DocType;
        NpCsDocument."From Document No." := CopyStr(DocNo,1,MaxStrLen(NpCsDocument."From Document No."));
        NpCsDocument."From Store Code" := StoreCode;
        //-#362197 [362197]
        NpCsDocument."To Store Code" := GetToStoreCode(XmlElement);
        //+#362197 [362197]
        NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Order Status";
        NpCsDocument."Processing Status" := NpCsDocument."Processing Status"::Pending;
        NpCsDocument."Processing updated at" := CurrentDateTime;
        NpCsDocument."Customer No." := NpXmlDomMgt.GetAttributeCode(XmlElement,'sell_to_customer','customer_no',MaxStrLen(NpCsDocument."Customer No."),false);
        NpCsDocument."Customer E-mail" := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/email',MaxStrLen(NpCsDocument."Customer E-mail"),false);
        NpCsDocument."Customer Phone No." := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/phone_no',MaxStrLen(NpCsDocument."Customer Phone No."),false);
        NpCsDocument."Send Notification from Store" := NpXmlDomMgt.GetElementBoolean(XmlElement,'notification/send_notification_from_store',false);
        NpCsDocument."Notify Customer via E-mail" := NpXmlDomMgt.GetElementBoolean(XmlElement,'notification/notify_customer_via_email',false);
        NpCsDocument."E-mail Template (Pending)" := NpXmlDomMgt.GetElementCode(XmlElement,'notification/email_template_pending',MaxStrLen(NpCsDocument."E-mail Template (Pending)"),false);
        NpCsDocument."E-mail Template (Confirmed)" := NpXmlDomMgt.GetElementCode(XmlElement,'notification/email_template_confirmed',MaxStrLen(NpCsDocument."E-mail Template (Confirmed)"),false);
        NpCsDocument."E-mail Template (Rejected)" := NpXmlDomMgt.GetElementCode(XmlElement,'notification/email_template_rejected',MaxStrLen(NpCsDocument."E-mail Template (Rejected)"),false);
        NpCsDocument."E-mail Template (Expired)" := NpXmlDomMgt.GetElementCode(XmlElement,'notification/email_template_expired',MaxStrLen(NpCsDocument."E-mail Template (Expired)"),false);
        NpCsDocument."Notify Customer via Sms" := NpXmlDomMgt.GetElementBoolean(XmlElement,'notification/notify_customer_via_sms',false);
        NpCsDocument."Sms Template (Pending)" := NpXmlDomMgt.GetElementCode(XmlElement,'notification/sms_template_pending',MaxStrLen(NpCsDocument."Sms Template (Pending)"),false);
        NpCsDocument."Sms Template (Confirmed)" := NpXmlDomMgt.GetElementCode(XmlElement,'notification/sms_template_confirmed',MaxStrLen(NpCsDocument."Sms Template (Confirmed)"),false);
        NpCsDocument."Sms Template (Rejected)" := NpXmlDomMgt.GetElementCode(XmlElement,'notification/sms_template_rejected',MaxStrLen(NpCsDocument."Sms Template (Rejected)"),false);
        NpCsDocument."Sms Template (Expired)" := NpXmlDomMgt.GetElementCode(XmlElement,'notification/sms_template_expired',MaxStrLen(NpCsDocument."Sms Template (Expired)"),false);
        //-#362443 [362443]
        NpCsDocument."Opening Hour Set" := NpXmlDomMgt.GetElementCode(XmlElement,'notification/opening_hour_set',MaxStrLen(NpCsDocument."Opening Hour Set"),false);
        //+#362443 [362443]
        NpCsDocument."Processing Expiry Duration" := NpXmlDomMgt.GetElementDuration(XmlElement,'notification/processing_expiry_duration',false);
        NpCsDocument."Delivery Expiry Days (Qty.)" := NpXmlDomMgt.GetElementInt(XmlElement,'notification/delivery_expiry_days_qty',false);
        NpCsDocument."Archive on Delivery" := NpXmlDomMgt.GetElementBoolean(XmlElement,'archive_on_delivery',false);
        NpCsDocument."Store Stock" := NpXmlDomMgt.GetElementBoolean(XmlElement,'store_stock',false);
        NpCsDocument."Bill via" := NpXmlDomMgt.GetElementInt(XmlElement,'bill_via',false);
        NpCsDocument."Delivery Print Template (POS)" := NpXmlDomMgt.GetElementCode(XmlElement,'delivery_print_template_pos',MaxStrLen(NpCsDocument."Delivery Print Template (POS)"),false);
        NpCsDocument."Delivery Print Template (S.)" := NpXmlDomMgt.GetElementCode(XmlElement,'delivery_print_template_sales_doc',MaxStrLen(NpCsDocument."Delivery Print Template (S.)"),false);
        NpCsDocument."Salesperson Code" := NpXmlDomMgt.GetElementCode(XmlElement,'salesperson_code',MaxStrLen(NpCsDocument."Salesperson Code"),false);
        NpCsDocument."Prepaid Amount" := NpXmlDomMgt.GetElementDec(XmlElement,'prepaid_amount',false);
        NpCsDocument."Prepayment Account No." := NpXmlDomMgt.GetElementCode(XmlElement,'prepayment_account_no',MaxStrLen(NpCsDocument."Prepayment Account No."),NpCsDocument."Prepaid Amount" <> 0);
        if Callback <> '' then begin
          NpCsDocument."Callback Data".CreateOutStream(OutStr,TEXTENCODING::UTF8);
          OutStr.WriteText(Callback);
        end;
        NpCsExpirationMgt.SetExpiresAt(NpCsDocument);
        NpCsDocument.Insert(true);
        //+#344264 [#344264]
    end;

    local procedure InsertSalesLine(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header")
    var
        ItemVariant: Record "Item Variant";
        SalesLine: Record "Sales Line";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        SalesLine.SetHideValidationDialog(true);
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := NpXmlDomMgt.GetAttributeInt(XmlElement,'','line_no',true);
        SalesLine.Insert(true);

        SalesLine.Validate(Type,NpXmlDomMgt.GetElementInt(XmlElement,'type',true));
        case SalesLine.Type of
          SalesLine.Type::Item:
            begin
              FindItemVariant(XmlElement,ItemVariant);
              if ItemVariant."Item No." = '' then
                Error(Text004,NpXmlDomMgt.GetElementText(XmlElement,'no',0,true),SalesLine."Line No.");

              SalesLine.Validate("No.",ItemVariant."Item No.");
              if ItemVariant.Code <> '' then
                SalesLine.Validate("Variant Code",ItemVariant.Code);
              SalesLine.Validate("Unit of Measure Code",NpXmlDomMgt.GetElementCode(XmlElement,'unit_of_measure_code',MaxStrLen(SalesLine."Unit of Measure Code"),true));
              SalesLine.Description := NpXmlDomMgt.GetElementText(XmlElement,'description',MaxStrLen(SalesLine.Description),true);
              SalesLine."Description 2" := NpXmlDomMgt.GetElementText(XmlElement,'description_2',MaxStrLen(SalesLine."Description 2"),false);
              SalesLine.Validate("Unit Price",NpXmlDomMgt.GetElementDec(XmlElement,'unit_price',true));
              SalesLine.Validate(Quantity,NpXmlDomMgt.GetElementDec(XmlElement,'quantity',true));
              SalesLine.Validate("VAT %",NpXmlDomMgt.GetElementDec(XmlElement,'vat_pct',true));
              SalesLine.Validate("Amount Including VAT",NpXmlDomMgt.GetElementDec(XmlElement,'line_amount',true));
              SalesLine.Modify(true);
            end;
        end;
        SalesLine.Modify(true);
    end;

    local procedure InitPOSSalesWorkflow()
    var
        POSSalesWorkflow: Record "POS Sales Workflow";
        POSSalesWorkflowStep: Record "POS Sales Workflow Step";
    begin
        if POSSalesWorkflowStep.Get('','FINISH_SALE',CODEUNIT::"NpCs POS Session Mgt.",'DeliverCollectDocument') then
          exit;

        if not POSSalesWorkflow.Get('FINISH_SALE') then
          POSSalesWorkflow.OnDiscoverPOSSalesWorkflows();

        POSSalesWorkflow.Get('FINISH_SALE');
        POSSalesWorkflow.InitPOSSalesWorkflowSteps();
    end;

    local procedure "--- Find"()
    begin
    end;

    local procedure FindCustomer(XmlElement: DotNet npNetXmlElement;var Customer: Record Customer): Boolean
    var
        NpCsWorkflow: Record "NpCs Workflow";
        NpCsDocumentMapping: Record "NpCs Document Mapping";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Email: Text;
        PhoneNo: Text;
        StoreCode: Code[20];
        CustNo: Code[20];
        CustomerMapping: Integer;
    begin
        StoreCode := GetFromStoreCode(XmlElement);
        if StoreCode = '' then
          exit(false);

        CustNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'sell_to_customer','customer_no',MaxStrLen(NpCsDocumentMapping."From No."),true);
        if CustNo = '' then
          exit(false);

        if not NpCsDocumentMapping.Get(NpCsDocumentMapping.Type::"Customer No.",StoreCode,CustNo) then
          exit(false);

        if Customer.Get(NpCsDocumentMapping."To No.") and (Customer."No." <> '') then
          exit(true);

        CustomerMapping := NpXmlDomMgt.GetAttributeInt(XmlElement,'sell_to_customer','customer_mapping',false);

        Clear(Customer);
        case CustomerMapping of
          NpCsWorkflow."Customer Mapping"::" ":
            begin
              exit(false);
            end;
          NpCsWorkflow."Customer Mapping"::"E-mail":
            begin
              Email := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/email',MaxStrLen(Customer."E-Mail"),false);
              Customer.SetFilter("E-Mail",'%1&<>%2',Email,'');
              exit(Customer.FindFirst);
            end;
          NpCsWorkflow."Customer Mapping"::"Phone No.":
            begin
              PhoneNo := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/phone_no',MaxStrLen(Customer."Phone No."),false);
              Customer.SetFilter("Phone No.",'%1&<>%2',PhoneNo,'');
              exit(Customer.FindFirst);
            end;
          NpCsWorkflow."Customer Mapping"::"E-mail AND Phone No.":
            begin
              Email := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/email',MaxStrLen(Customer."E-Mail"),false);
              PhoneNo := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/phone_no',MaxStrLen(Customer."Phone No."),false);
              Customer.SetFilter("E-Mail",'%1&<>%2',Email,'');
              Customer.SetFilter("Phone No.",'%1&<>%2',PhoneNo,'');
              exit(Customer.FindFirst);
            end;
          NpCsWorkflow."Customer Mapping"::"E-mail OR Phone No.":
            begin
              Email := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/email',MaxStrLen(Customer."E-Mail"),false);
              Customer.SetFilter("E-Mail",'%1&<>%2',Email,'');
              if Customer.FindFirst then
                exit(true);

              PhoneNo := NpXmlDomMgt.GetElementText(XmlElement,'sell_to_customer/phone_no',MaxStrLen(Customer."Phone No."),false);
              Clear(Customer);
              Customer.SetFilter("Phone No.",'%1&<>%2',PhoneNo,'');
              exit(Customer.FindFirst);
            end;
          NpCsWorkflow."Customer Mapping"::"Fixed Customer No.",NpCsWorkflow."Customer Mapping"::"Customer No. from Source":
            begin
              CustNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'sell_to_customer','customer_no',MaxStrLen(Customer."No."),true);
              Customer.Get(CustNo);
              exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure FindNpCsDocument(XmlElement: DotNet npNetXmlElement;var NpCsDocument: Record "NpCs Document"): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        DocType: Integer;
        DocNo: Text;
        StoreCode: Code[20];
    begin
        DocType := NpXmlDomMgt.GetAttributeInt(XmlElement,'','document_type',true);
        DocNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'','document_no',MaxStrLen(NpCsDocument."Document No."),true);
        StoreCode := GetFromStoreCode(XmlElement);

        Clear(NpCsDocument);
        NpCsDocument.SetRange(Type,NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("From Document Type",DocType);
        NpCsDocument.SetRange("From Document No.",DocNo);
        NpCsDocument.SetRange("From Store Code",StoreCode);
        exit(NpCsDocument.FindFirst);
    end;

    local procedure FindItemVariant(XmlElement: DotNet npNetXmlElement;var ItemVariant: Record "Item Variant")
    var
        Item: Record Item;
        ItemCrossRef: Record "Item Cross Reference";
        NpCsDocumentMapping: Record "NpCs Document Mapping";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        StoreCode: Code[20];
        FromCrossRefNo: Code[20];
        FromItemNo: Code[20];
        FromVariantCode: Code[10];
    begin
        Clear(ItemVariant);

        StoreCode := GetFromStoreCode(XmlElement);
        FromCrossRefNo := NpXmlDomMgt.GetElementCode(XmlElement,'cross_reference_no',MaxStrLen(ItemVariant."Item No."),false);
        if NpCsDocumentMapping.Get(NpCsDocumentMapping.Type::"Item Cross Reference No.",StoreCode,FromCrossRefNo) and (NpCsDocumentMapping."To No." <> '') then begin
          ItemCrossRef.SetRange("Cross-Reference No.",NpCsDocumentMapping."To No.");
          ItemCrossRef.SetRange("Discontinue Bar Code",false);
          if not ItemCrossRef.FindFirst then
            ItemCrossRef.SetRange("Discontinue Bar Code");

          if ItemCrossRef.FindFirst then begin
            ItemVariant."Item No." := ItemCrossRef."Item No.";
            ItemVariant.Code := ItemCrossRef."Variant Code";
            exit;
          end;
        end;

        FromItemNo := NpXmlDomMgt.GetElementCode(XmlElement,'no',MaxStrLen(ItemVariant."Item No."),true);
        if FromItemNo = '' then
          Error(Text002,'<no>',XmlElement.Name);

        FromVariantCode := NpXmlDomMgt.GetElementCode(XmlElement,'variant_code',MaxStrLen(ItemVariant.Code),false);
        if (FromVariantCode <> '') and ItemVariant.Get(FromItemNo,FromVariantCode) then begin
          if NpCsDocumentMapping."From No." <> '' then begin
            NpCsDocumentMapping.Validate("To No.",GetCrossRefNo(ItemVariant));
            NpCsDocumentMapping.Modify(true);
          end;

          exit;
        end;

        if ItemVariant.Get(FromItemNo,FromVariantCode) then
          exit;
        if Item.Get(FromItemNo) then begin
          ItemVariant."Item No." := Item."No.";
          ItemVariant.Code := '';

          if NpCsDocumentMapping."From No." <> '' then begin
            NpCsDocumentMapping.Validate("To No.",GetCrossRefNo(ItemVariant));
            NpCsDocumentMapping.Modify(true);
          end;
          exit;
        end;
    end;

    local procedure GetCrossRefNo(ItemVariant: Record "Item Variant") CrossRefNo: Code[20]
    var
        ItemCrossRef: Record "Item Cross Reference";
    begin
        ItemCrossRef.SetRange("Item No.",ItemVariant."Item No.");
        ItemCrossRef.SetRange("Variant Code",ItemVariant.Code);
        ItemCrossRef.SetRange("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::"Bar Code");
        ItemCrossRef.SetFilter("Cross-Reference No.",'<>%1','');
        ItemCrossRef.SetRange("Discontinue Bar Code",false);
        if not ItemCrossRef.FindFirst then
          ItemCrossRef.SetRange("Discontinue Bar Code");
        if ItemCrossRef.FindFirst then
          exit(ItemCrossRef."Cross-Reference No.");

        exit('');
    end;

    local procedure GetFromStoreCode(XmlElement: DotNet npNetXmlElement) StoreCode: Code[20]
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        if IsNull(XmlElement) then
          exit('');

        StoreCode := NpXmlDomMgt.GetAttributeCode(XmlElement,'/*/sales_document/from_store','store_code',MaxStrLen(StoreCode),true);
        exit(StoreCode);
    end;

    local procedure GetToStoreCode(XmlElement: DotNet npNetXmlElement) StoreCode: Code[20]
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        //-#362197 [362197]
        if IsNull(XmlElement) then
          exit('');

        StoreCode := NpXmlDomMgt.GetAttributeCode(XmlElement,'/*/sales_document/to_store','store_code',MaxStrLen(StoreCode),false);
        exit(StoreCode);
        //+#362197 [362197]
    end;

    local procedure GetCallback(XmlElement: DotNet npNetXmlElement) Callback: Text
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        Encoding: DotNet npNetEncoding;
        Convert: DotNet npNetConvert;
    begin
        Callback := NpXmlDomMgt.GetElementText(XmlElement,'/*/sales_document/from_store/callback',0,false);
        if Callback = '' then
          exit('');

        case LowerCase(NpXmlDomMgt.GetAttributeCode(XmlElement,'/*/sales_document/from_store/callback','encoding',0,false)) of
          'base64':
            begin
              Callback := Encoding.UTF8.GetString(Convert.FromBase64String(Callback));
            end;
        end;

        exit(Callback);
    end;
}


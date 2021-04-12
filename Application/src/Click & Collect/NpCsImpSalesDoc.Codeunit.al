codeunit 6151200 "NPR NpCs Imp. Sales Doc."
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Document: XmlDocument;
        Element: XmlElement;
        Element2: XmlElement;
    begin
        if not Rec.LoadXmlDoc(Document) then
            Error(Text000);

        Document.GetRoot(Element);
        if Element.IsEmpty() then
            Error(Text000);

        NpXmlDomMgt.FindElement(Element, '//sales_document', true, Element2);

        ImportSalesDoc(Element2);
    end;

    var
        Text000: Label 'Invalid Xml data';
        Text002: Label '%1 is blank in %2';
        Text004: Label 'Item %1 could not be mapped in line no. %2';
        Text005: Label 'Order received from Store %1';
        Text006: Label 'Order updated from Store %1 to Store %2';

    local procedure ImportSalesDoc(Element: XmlElement)
    var
        Customer: Record Customer;
        NpCsStoreFrom: Record "NPR NpCs Store";
        NpCsDocument: Record "NPR NpCs Document";
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        SalesHeader: Record "Sales Header";
        NpCsExpirationMgt: Codeunit "NPR NpCs Expiration Mgt.";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        NodeList: XmlNodeList;
        Node: XmlNode;
        LogMessage: Text;
    begin
        if FindNpCsDocument(Element, NpCsDocument) then
            exit;

        InitPOSSalesWorkflow();

        UpsertFromStore(Element, NpCsStoreFrom);
        InsertToStore(Element);

        if NpCsStoreFrom."Local Store" then begin
            FindSalesHeader(Element, SalesHeader);
            UpdateSalesHeader(Element, SalesHeader);
            InsertCollectDocument(Element, SalesHeader, NpCsDocument);

            LogMessage := StrSubstNo(Text006, NpCsDocument."From Store Code", NpCsDocument."To Store Code");
            NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Send Order";
            NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
            NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
            Commit();
            NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
            if NpCsDocument."Processing expires at" > 0DT then
                NpCsExpirationMgt.ScheduleUpdateExpirationStatus(NpCsDocument, NpCsDocument."Processing expires at");

            exit;
        end;
        InsertDocumentMappings(Element);
        Commit();

        UpsertCustomer(Element, Customer);
        InsertSalesHeader(Element, Customer, SalesHeader);
        InsertCollectDocument(Element, SalesHeader, NpCsDocument);

        Element.SelectNodes('//sales_lines/sales_line', NodeList);
        foreach Node in NodeList do
            InsertSalesLine(Node.AsXmlElement(), SalesHeader);

        LogMessage := StrSubstNo(Text005, NpCsDocument."From Store Code");
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Send Order";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, false, '');
        NpCsWorkflowMgt.SendNotificationToCustomer(NpCsDocument);
        Commit();
        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
        if NpCsDocument."Processing expires at" > 0DT then
            NpCsExpirationMgt.ScheduleUpdateExpirationStatus(NpCsDocument, NpCsDocument."Processing expires at");
    end;

    local procedure UpsertFromStore(Element: XmlElement; var NpCsStore: Record "NPR NpCs Store")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        StoreCode: Code[20];
        PrevRec: Text;
    begin
        StoreCode := GetFromStoreCode(Element);

        if not NpCsStore.Get(StoreCode) then begin
            NpCsStore.Init();
            NpCsStore.Code := StoreCode;
            NpCsStore.Insert(true);
        end;

        PrevRec := Format(NpCsStore);

        NpCsStore.Validate("Company Name", NpXmlDomMgt.GetElementText(Element, 'from_store/company_name', MaxStrLen(NpCsStore."Company Name"), true));
        NpCsStore.Name := NpXmlDomMgt.GetElementText(Element, 'from_store/name', MaxStrLen(NpCsStore.Name), true);
        NpCsStore."Service Url" := NpXmlDomMgt.GetElementText(Element, 'from_store/service_url', MaxStrLen(NpCsStore."Service Url"), true);
        NpCsStore."Service Username" := NpXmlDomMgt.GetElementText(Element, 'from_store/service_username', MaxStrLen(NpCsStore."Service Username"), true);
        NpCsStore."Service Password" := NpXmlDomMgt.GetElementText(Element, 'from_store/service_password', MaxStrLen(NpCsStore."Service Password"), true);
        NpCsStore."E-mail" := NpXmlDomMgt.GetElementText(Element, 'from_store/email', MaxStrLen(NpCsStore."E-mail"), true);
        NpCsStore."Mobile Phone No." := NpXmlDomMgt.GetElementText(Element, 'from_store/mobile_phone_no', MaxStrLen(NpCsStore."Mobile Phone No."), true);

        if PrevRec <> Format(NpCsStore) then
            NpCsStore.Modify(true);
    end;

    local procedure InsertToStore(Element: XmlElement)
    var
        NpCsStore: Record "NPR NpCs Store";
        StoreCode: Code[20];
    begin
        StoreCode := GetToStoreCode(Element);
        if StoreCode = '' then
            exit;

        if not NpCsStore.Get(StoreCode) then begin
            NpCsStore.Init();
            NpCsStore.Code := StoreCode;
            NpCsStore."Local Store" := true;
            NpCsStore.Validate("Company Name", CompanyName);
            NpCsStore.Insert(true);
        end;
    end;

    local procedure InsertDocumentMappings(Element: XmlElement)
    var
        Customer: Record Customer;
        ItemVariant: Record "Item Variant";
        NpCsDocumentMapping: Record "NPR NpCs Document Mapping";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        NodeList: XmlNodeList;
        Node: XmlNode;
        FromStore: Code[20];
        FromNo: Code[20];
        Description: Text;
        Description2: Text;
    begin
        FromStore := GetFromStoreCode(Element);

        FromNo := NpXmlDomMgt.GetAttributeCode(Element, 'sell_to_customer', 'customer_no', MaxStrLen(NpCsDocumentMapping."From No."), true);
        Description := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/name', 0, true);
        Description2 := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/name_2', 0, false);
        InsertDocumentMapping(NpCsDocumentMapping.Type::"Customer No.", FromStore, FromNo, Description, Description2);
        if FindCustomer(Element, Customer) then begin
            NpCsDocumentMapping.Get(NpCsDocumentMapping.Type::"Customer No.", FromStore, FromNo);
            NpCsDocumentMapping.Validate("To No.", Customer."No.");
            NpCsDocumentMapping.Modify(true);
        end;

        Element.SelectNodes('//sales_lines/sales_line[type=2 and cross_reference_no!=""]', NodeList);
        foreach Node in NodeList do begin
            FromNo := NpXmlDomMgt.GetElementCode(Node.AsXmlElement(), 'cross_reference_no', MaxStrLen(NpCsDocumentMapping."From No."), true);
            Description := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'description', 0, true);
            Description2 := NpXmlDomMgt.GetElementText(Node.AsXmlElement(), 'description_2', 0, false);
            InsertDocumentMapping(NpCsDocumentMapping.Type::"Item Cross Reference No.", FromStore, FromNo, Description, Description2);
            FindItemVariant(Node.AsXmlElement(), ItemVariant);
        end;
    end;

    local procedure InsertDocumentMapping(Type: Integer; FromStore: Code[20]; FromNo: Code[20]; Description: Text; Description2: Text)
    var
        NpCsDocumentMapping: Record "NPR NpCs Document Mapping";
        PrevRec: Text;
    begin
        if FromStore = '' then
            exit;
        if FromNo = '' then
            exit;

        if not NpCsDocumentMapping.Get(Type, FromStore, FromNo) then begin
            NpCsDocumentMapping.Init();
            NpCsDocumentMapping.Type := Type;
            NpCsDocumentMapping."From Store Code" := FromStore;
            NpCsDocumentMapping."From No." := FromNo;
            NpCsDocumentMapping.Insert(true);
        end;

        PrevRec := Format(NpCsDocumentMapping);

        NpCsDocumentMapping."From Description" := CopyStr(Description, 1, MaxStrLen(NpCsDocumentMapping."From Description"));
        NpCsDocumentMapping."From Description 2" := CopyStr(Description2, 1, MaxStrLen(NpCsDocumentMapping."From Description 2"));

        if PrevRec <> Format(NpCsDocumentMapping) then
            NpCsDocumentMapping.Modify(true);
    end;

    local procedure UpsertCustomer(Element: XmlElement; var Customer: Record Customer)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        NpCsDocumentMapping: Record "NPR NpCs Document Mapping";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        StoreCode: Code[20];
        CustNo: Code[20];
        ConfigTemplateCode: Code[10];
        PrevRec: Text;
    begin
        if not FindCustomer(Element, Customer) then begin
            Customer.Init();
            Customer."No." := '';
            Customer.Insert(true);
        end;

        StoreCode := GetFromStoreCode(Element);
        CustNo := NpXmlDomMgt.GetAttributeCode(Element, 'sell_to_customer', 'customer_no', MaxStrLen(NpCsDocumentMapping."From No."), true);
        NpCsDocumentMapping.Get(NpCsDocumentMapping.Type::"Customer No.", StoreCode, CustNo);
        if NpCsDocumentMapping."To No." <> Customer."No." then begin
            NpCsDocumentMapping.Validate("To No.", Customer."No.");
            NpCsDocumentMapping.Modify(true);
        end;

        PrevRec := Format(Customer);

        ConfigTemplateCode := NpXmlDomMgt.GetElementCode(Element, 'sell_to_customer/config_template', MaxStrLen(ConfigTemplateHeader.Code), false);
        if (ConfigTemplateCode <> '') and ConfigTemplateHeader.Get(ConfigTemplateCode) then begin
            RecRef.GetTable(Customer);
            ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
            RecRef.SetTable(Customer);
        end;

        Customer.Validate(Name, NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/name', MaxStrLen(Customer.Name), true));
        Customer."Name 2" := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/name_2', MaxStrLen(Customer."Name 2"), true);
        Customer.Address := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/address', MaxStrLen(Customer.Address), true);
        Customer."Address 2" := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/address_2', MaxStrLen(Customer."Address 2"), true);
        Customer."Post Code" := NpXmlDomMgt.GetElementCode(Element, 'sell_to_customer/post_code', MaxStrLen(Customer."Post Code"), true);
        Customer.City := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/city', MaxStrLen(Customer.City), true);
        Customer.Validate("Country/Region Code", NpXmlDomMgt.GetElementCode(Element, 'sell_to_customer/country_code', MaxStrLen(Customer."Country/Region Code"), true));
        Customer.Contact := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/contact', MaxStrLen(Customer.Contact), true);
        Customer."Phone No." := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/phone_no', MaxStrLen(Customer."Phone No."), true);
        Customer."E-Mail" := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/email', MaxStrLen(Customer."E-Mail"), true);

        if PrevRec <> Format(Customer) then
            Customer.Modify(true);
    end;

    local procedure UpdateSalesHeader(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        xSalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        NpCsStore: Record "NPR NpCs Store";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        ToStoreCode: Code[20];
        PrevRec: Text;
    begin
        xSalesHeader := SalesHeader;

        SalesHeader.SetHideValidationDialog(true);
        ToStoreCode := GetToStoreCode(Element);
        NpCsStore.Get(ToStoreCode);

        if SalesHeader.Status = SalesHeader.Status::Released then
            ReleaseSalesDoc.Reopen(SalesHeader);

        PrevRec := Format(SalesHeader);

        if SalesHeader."Location Code" <> NpCsStore."Location Code" then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange("Location Code", SalesHeader."Location Code");
            if SalesLine.FindSet() then
                repeat
                    SalesLine.Validate("Location Code", NpCsStore."Location Code");
                    SalesLine.Modify(true);
                until SalesLine.Next() = 0;

            SalesHeader.Validate("Location Code", NpCsStore."Location Code");
        end;

        if PrevRec <> Format(SalesHeader) then
            SalesHeader.Modify(true);

        if xSalesHeader.Status = xSalesHeader.Status::Released then
            ReleaseSalesDoc.PerformManualRelease(SalesHeader);
    end;

    local procedure InsertSalesHeader(Element: XmlElement; Customer: Record Customer; var SalesHeader: Record "Sales Header")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        DocNo: Text;
        BillToCustNo: Code[20];
    begin
        DocNo := NpXmlDomMgt.GetAttributeCode(Element, '', 'document_no', MaxStrLen(SalesHeader."No."), true);

        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Init();
        SalesHeader."Document Type" := Enum::"Sales Document Type".FromInteger(NpXmlDomMgt.GetElementInt(Element, 'to_document_type', true));
        SalesHeader."No." := '';
        SalesHeader."External Document No." := CopyStr(DocNo, 1, MaxStrLen(SalesHeader."External Document No."));
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Validate("Posting Date", NpXmlDomMgt.GetElementDate(Element, 'posting_date', true));
        SalesHeader.Validate("Order Date", NpXmlDomMgt.GetElementDate(Element, 'posting_date', true));
        SalesHeader.Validate("Due Date", NpXmlDomMgt.GetElementDate(Element, 'due_date', true));
        BillToCustNo := NpXmlDomMgt.GetElementCode(Element, 'bill_to_customer_no', MaxStrLen(SalesHeader."Bill-to Customer No."), false);
        if BillToCustNo <> '' then
            SalesHeader.Validate("Bill-to Customer No.", BillToCustNo);
        SalesHeader.Validate("Location Code", NpXmlDomMgt.GetElementCode(Element, 'location_code', MaxStrLen(SalesHeader."Location Code"), true));
        SalesHeader.Validate("Salesperson Code", NpXmlDomMgt.GetElementCode(Element, 'salesperson_code', MaxStrLen(SalesHeader."Salesperson Code"), true));
        SalesHeader.Validate("Payment Method Code", NpXmlDomMgt.GetElementCode(Element, 'payment_method_code', MaxStrLen(SalesHeader."Payment Method Code"), true));
        SalesHeader.Validate("Shipment Method Code", NpXmlDomMgt.GetElementCode(Element, 'shipment_method_code', MaxStrLen(SalesHeader."Shipment Method Code"), true));
        SalesHeader.Modify(true);
    end;

    local procedure InsertCollectDocument(Element: XmlElement; SalesHeader: Record "Sales Header"; var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsExpirationMgt: Codeunit "NPR NpCs Expiration Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Callback: Text;
        DocType: Integer;
        DocNo: Text;
        StoreCode: Code[20];
        OutStr: OutStream;
        ProcessingStatus: Integer;
    begin
        DocType := NpXmlDomMgt.GetAttributeInt(Element, '', 'document_type', true);
        DocNo := NpXmlDomMgt.GetAttributeCode(Element, '', 'document_no', MaxStrLen(SalesHeader."No."), true);
        StoreCode := GetFromStoreCode(Element);

        Callback := GetCallback(Element);
        NpCsDocument.Init();
        NpCsDocument.Type := NpCsDocument.Type::"Collect in Store";
        NpCsDocument."Document Type" := SalesHeader."Document Type";
        NpCsDocument."Document No." := SalesHeader."No.";
        NpCsDocument.Validate("Document No.");
        NpCsDocument."Reference No." := NpXmlDomMgt.GetElementCode(Element, 'reference_no', MaxStrLen(NpCsDocument."Reference No."), true);
        NpCsDocument."From Document Type" := DocType;
        NpCsDocument."From Document No." := CopyStr(DocNo, 1, MaxStrLen(NpCsDocument."From Document No."));
        NpCsDocument."From Store Code" := StoreCode;
        NpCsDocument."To Store Code" := GetToStoreCode(Element);
        NpCsDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step"::"Order Status";
        NpCsDocument."Processing Status" := NpCsDocument."Processing Status"::Pending;
        if Evaluate(ProcessingStatus, NpXmlDomMgt.GetElementText(Element, 'processing_status', 0, false), 9) then begin
            if ProcessingStatus in [NpCsDocument."Processing Status"::" ", NpCsDocument."Processing Status"::Pending] then
                NpCsDocument."Processing Status" := ProcessingStatus;
        end;
        NpCsDocument."Processing updated at" := CurrentDateTime;
        NpCsDocument."Customer No." := NpXmlDomMgt.GetAttributeCode(Element, 'sell_to_customer', 'customer_no', MaxStrLen(NpCsDocument."Customer No."), false);
        NpCsDocument."Customer E-mail" := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/email', MaxStrLen(NpCsDocument."Customer E-mail"), false);
        NpCsDocument."Customer Phone No." := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/phone_no', MaxStrLen(NpCsDocument."Customer Phone No."), false);
        NpCsDocument."Send Notification from Store" := NpXmlDomMgt.GetElementBoolean(Element, 'notification/send_notification_from_store', false);
        NpCsDocument."Notify Customer via E-mail" := NpXmlDomMgt.GetElementBoolean(Element, 'notification/notify_customer_via_email', false);
        NpCsDocument."E-mail Template (Pending)" := NpXmlDomMgt.GetElementCode(Element, 'notification/email_template_pending', MaxStrLen(NpCsDocument."E-mail Template (Pending)"), false);
        NpCsDocument."E-mail Template (Confirmed)" := NpXmlDomMgt.GetElementCode(Element, 'notification/email_template_confirmed', MaxStrLen(NpCsDocument."E-mail Template (Confirmed)"), false);
        NpCsDocument."E-mail Template (Rejected)" := NpXmlDomMgt.GetElementCode(Element, 'notification/email_template_rejected', MaxStrLen(NpCsDocument."E-mail Template (Rejected)"), false);
        NpCsDocument."E-mail Template (Expired)" := NpXmlDomMgt.GetElementCode(Element, 'notification/email_template_expired', MaxStrLen(NpCsDocument."E-mail Template (Expired)"), false);
        NpCsDocument."Notify Customer via Sms" := NpXmlDomMgt.GetElementBoolean(Element, 'notification/notify_customer_via_sms', false);
        NpCsDocument."Sms Template (Pending)" := NpXmlDomMgt.GetElementCode(Element, 'notification/sms_template_pending', MaxStrLen(NpCsDocument."Sms Template (Pending)"), false);
        NpCsDocument."Sms Template (Confirmed)" := NpXmlDomMgt.GetElementCode(Element, 'notification/sms_template_confirmed', MaxStrLen(NpCsDocument."Sms Template (Confirmed)"), false);
        NpCsDocument."Sms Template (Rejected)" := NpXmlDomMgt.GetElementCode(Element, 'notification/sms_template_rejected', MaxStrLen(NpCsDocument."Sms Template (Rejected)"), false);
        NpCsDocument."Sms Template (Expired)" := NpXmlDomMgt.GetElementCode(Element, 'notification/sms_template_expired', MaxStrLen(NpCsDocument."Sms Template (Expired)"), false);
        NpCsDocument."Opening Hour Set" := NpXmlDomMgt.GetElementCode(Element, 'notification/opening_hour_set', MaxStrLen(NpCsDocument."Opening Hour Set"), false);
        NpCsDocument."Processing Expiry Duration" := NpXmlDomMgt.GetElementDuration(Element, 'notification/processing_expiry_duration', false);
        NpCsDocument."Delivery Expiry Days (Qty.)" := NpXmlDomMgt.GetElementInt(Element, 'notification/delivery_expiry_days_qty', false);
        NpCsDocument."Archive on Delivery" := NpXmlDomMgt.GetElementBoolean(Element, 'archive_on_delivery', false);
        NpCsDocument."Store Stock" := NpXmlDomMgt.GetElementBoolean(Element, 'store_stock', false);
        NpCsDocument."Post on" := NpXmlDomMgt.GetElementInt(Element, 'post_on', false);
        NpCsDocument."Bill via" := NpXmlDomMgt.GetElementInt(Element, 'bill_via', false);
        NpCsDocument."Processing Print Template" := NpXmlDomMgt.GetElementCode(Element, 'processing_print_template', MaxStrLen(NpCsDocument."Processing Print Template"), false);
        NpCsDocument."Delivery Print Template (POS)" := NpXmlDomMgt.GetElementCode(Element, 'delivery_print_template_pos', MaxStrLen(NpCsDocument."Delivery Print Template (POS)"), false);
        NpCsDocument."Delivery Print Template (S.)" := NpXmlDomMgt.GetElementCode(Element, 'delivery_print_template_sales_doc', MaxStrLen(NpCsDocument."Delivery Print Template (S.)"), false);
        NpCsDocument."Salesperson Code" := NpXmlDomMgt.GetElementCode(Element, 'salesperson_code', MaxStrLen(NpCsDocument."Salesperson Code"), false);
        NpCsDocument."Prepaid Amount" := NpXmlDomMgt.GetElementDec(Element, 'prepaid_amount', false);
        NpCsDocument."Prepayment Account No." := NpXmlDomMgt.GetElementCode(Element, 'prepayment_account_no', MaxStrLen(NpCsDocument."Prepayment Account No."), NpCsDocument."Prepaid Amount" <> 0);
        if Callback <> '' then begin
            NpCsDocument."Callback Data".CreateOutStream(OutStr, TEXTENCODING::UTF8);
            OutStr.WriteText(Callback);
        end;
        NpCsExpirationMgt.SetExpiresAt(NpCsDocument);
        NpCsDocument.Insert(true);
    end;

    local procedure InsertSalesLine(Element: XmlElement; SalesHeader: Record "Sales Header")
    var
        ItemVariant: Record "Item Variant";
        SalesLine: Record "Sales Line";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
    begin
        SalesLine.SetHideValidationDialog(true);
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := NpXmlDomMgt.GetAttributeInt(Element, '', 'line_no', true);
        SalesLine.Insert(true);

        SalesLine.Validate(Type, NpXmlDomMgt.GetElementInt(Element, 'type', true));
        case SalesLine.Type of
            SalesLine.Type::Item:
                begin
                    FindItemVariant(Element, ItemVariant);
                    if ItemVariant."Item No." = '' then
                        Error(Text004, NpXmlDomMgt.GetElementText(Element, 'no', 0, true), SalesLine."Line No.");

                    SalesLine.Validate("No.", ItemVariant."Item No.");
                    if ItemVariant.Code <> '' then
                        SalesLine.Validate("Variant Code", ItemVariant.Code);
                    SalesLine.Validate("Unit of Measure Code", NpXmlDomMgt.GetElementCode(Element, 'unit_of_measure_code', MaxStrLen(SalesLine."Unit of Measure Code"), true));
                    SalesLine.Description := NpXmlDomMgt.GetElementText(Element, 'description', MaxStrLen(SalesLine.Description), true);
                    SalesLine."Description 2" := NpXmlDomMgt.GetElementText(Element, 'description_2', MaxStrLen(SalesLine."Description 2"), false);
                    SalesLine.Validate(Quantity, NpXmlDomMgt.GetElementDec(Element, 'quantity', true));
                    SalesLine.Validate("Unit Price", NpXmlDomMgt.GetElementDec(Element, 'unit_price', true));
                    SalesLine.Validate("VAT %", NpXmlDomMgt.GetElementDec(Element, 'vat_pct', true));
                    SalesLine.Validate("Amount Including VAT", NpXmlDomMgt.GetElementDec(Element, 'line_amount', true));
                    SalesLine.Modify(true);
                end;
            SalesLine.Type::" ":
                begin
                    SalesLine.Description := NpXmlDomMgt.GetElementText(Element, 'description', MaxStrLen(SalesLine.Description), true);
                    SalesLine."Description 2" := NpXmlDomMgt.GetElementText(Element, 'description_2', MaxStrLen(SalesLine."Description 2"), false);
                    SalesLine.Modify(true);
                end;
        end;
        SalesLine.Modify(true);
    end;

    local procedure InitPOSSalesWorkflow()
    var
        POSSalesWorkflow: Record "NPR POS Sales Workflow";
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        if POSSalesWorkflowStep.Get('', 'FINISH_SALE', CODEUNIT::"NPR NpCs POSSession Mgt.", 'DeliverCollectDocument') then
            exit;

        if not POSSalesWorkflow.Get('FINISH_SALE') then
            POSSalesWorkflow.OnDiscoverPOSSalesWorkflows();

        POSSalesWorkflow.Get('FINISH_SALE');
        POSSalesWorkflow.InitPOSSalesWorkflowSteps();
    end;

    local procedure "--- Find"()
    begin
    end;

    local procedure FindCustomer(Element: XmlElement; var Customer: Record Customer): Boolean
    var
        NpCsWorkflow: Record "NPR NpCs Workflow";
        NpCsDocumentMapping: Record "NPR NpCs Document Mapping";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Email: Text;
        PhoneNo: Text;
        StoreCode: Code[20];
        CustNo: Code[20];
        CustomerMapping: Integer;
    begin
        StoreCode := GetFromStoreCode(Element);
        if StoreCode = '' then
            exit(false);

        CustNo := NpXmlDomMgt.GetAttributeCode(Element, 'sell_to_customer', 'customer_no', MaxStrLen(NpCsDocumentMapping."From No."), true);
        if CustNo = '' then
            exit(false);

        if not NpCsDocumentMapping.Get(NpCsDocumentMapping.Type::"Customer No.", StoreCode, CustNo) then
            exit(false);

        if Customer.Get(NpCsDocumentMapping."To No.") and (Customer."No." <> '') then
            exit(true);

        CustomerMapping := NpXmlDomMgt.GetAttributeInt(Element, 'sell_to_customer', 'customer_mapping', false);

        Clear(Customer);
        case CustomerMapping of
            NpCsWorkflow."Customer Mapping"::" ":
                begin
                    exit(false);
                end;
            NpCsWorkflow."Customer Mapping"::"E-mail":
                begin
                    Email := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/email', MaxStrLen(Customer."E-Mail"), false);
                    Customer.SetFilter("E-Mail", '%1&<>%2', Email, '');
                    exit(Customer.FindFirst());
                end;
            NpCsWorkflow."Customer Mapping"::"Phone No.":
                begin
                    PhoneNo := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/phone_no', MaxStrLen(Customer."Phone No."), false);
                    Customer.SetFilter("Phone No.", '%1&<>%2', PhoneNo, '');
                    exit(Customer.FindFirst());
                end;
            NpCsWorkflow."Customer Mapping"::"E-mail AND Phone No.":
                begin
                    Email := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/email', MaxStrLen(Customer."E-Mail"), false);
                    PhoneNo := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/phone_no', MaxStrLen(Customer."Phone No."), false);
                    Customer.SetFilter("E-Mail", '%1&<>%2', Email, '');
                    Customer.SetFilter("Phone No.", '%1&<>%2', PhoneNo, '');
                    exit(Customer.FindFirst());
                end;
            NpCsWorkflow."Customer Mapping"::"E-mail OR Phone No.":
                begin
                    Email := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/email', MaxStrLen(Customer."E-Mail"), false);
                    Customer.SetFilter("E-Mail", '%1&<>%2', Email, '');
                    if Customer.FindFirst() then
                        exit(true);

                    PhoneNo := NpXmlDomMgt.GetElementText(Element, 'sell_to_customer/phone_no', MaxStrLen(Customer."Phone No."), false);
                    Clear(Customer);
                    Customer.SetFilter("Phone No.", '%1&<>%2', PhoneNo, '');
                    exit(Customer.FindFirst());
                end;
            NpCsWorkflow."Customer Mapping"::"Fixed Customer No.", NpCsWorkflow."Customer Mapping"::"Customer No. from Source":
                begin
                    CustNo := NpXmlDomMgt.GetAttributeCode(Element, 'sell_to_customer', 'customer_no', MaxStrLen(Customer."No."), true);
                    Customer.Get(CustNo);
                    exit(true);
                end;
        end;

        exit(false);
    end;

    local procedure FindNpCsDocument(Element: XmlElement; var NpCsDocument: Record "NPR NpCs Document"): Boolean
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        DocType: Integer;
        DocNo: Text;
        StoreCode: Code[20];
    begin
        DocType := NpXmlDomMgt.GetAttributeInt(Element, '', 'document_type', true);
        DocNo := NpXmlDomMgt.GetAttributeCode(Element, '', 'document_no', MaxStrLen(NpCsDocument."Document No."), true);
        StoreCode := GetFromStoreCode(Element);

        Clear(NpCsDocument);
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("From Document Type", DocType);
        NpCsDocument.SetRange("From Document No.", DocNo);
        NpCsDocument.SetRange("From Store Code", StoreCode);
        exit(NpCsDocument.FindFirst());
    end;

    local procedure FindSalesHeader(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        DocType: Integer;
        DocNo: Text;
    begin
        Clear(SalesHeader);
        DocType := NpXmlDomMgt.GetAttributeInt(Element, '', 'document_type', true);
        DocNo := NpXmlDomMgt.GetAttributeCode(Element, '', 'document_no', MaxStrLen(SalesHeader."No."), true);
        SalesHeader.Get(DocType, DocNo);
    end;

    local procedure FindItemVariant(Element: XmlElement; var ItemVariant: Record "Item Variant")
    var
        Item: Record Item;
        ItemRef: Record "Item Reference";
        NpCsDocumentMapping: Record "NPR NpCs Document Mapping";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        StoreCode: Code[20];
        FromItemRefNo: Code[50];
        FromItemNo: Code[20];
        FromVariantCode: Code[10];
        Found: Boolean;
    begin
        Clear(ItemVariant);
        OnFindItemVariant(Element, ItemVariant, Found);
        if Found then
            exit;

        Clear(ItemVariant);

        StoreCode := GetFromStoreCode(Element);
        FromItemRefNo := NpXmlDomMgt.GetElementCode(Element, 'cross_reference_no', MaxStrLen(ItemVariant."Item No."), false);
        if NpCsDocumentMapping.Get(NpCsDocumentMapping.Type::"Item Cross Reference No.", StoreCode, FromItemRefNo) and (NpCsDocumentMapping."To No." <> '') then begin
            ItemRef.SetRange("Reference No.", NpCsDocumentMapping."To No.");
            ItemRef.SetRange("Discontinue Bar Code", false);
            if not ItemRef.FindFirst() then
                ItemRef.SetRange("Discontinue Bar Code");

            if ItemRef.FindFirst() then begin
                ItemVariant."Item No." := ItemRef."Item No.";
                ItemVariant.Code := ItemRef."Variant Code";
                exit;
            end;
        end;

        FromItemNo := NpXmlDomMgt.GetElementCode(Element, 'no', MaxStrLen(ItemVariant."Item No."), true);
        if FromItemNo = '' then
            Error(Text002, '<no>', Element.Name);

        FromVariantCode := NpXmlDomMgt.GetElementCode(Element, 'variant_code', MaxStrLen(ItemVariant.Code), false);
        if (FromVariantCode <> '') and ItemVariant.Get(FromItemNo, FromVariantCode) then begin
            if NpCsDocumentMapping."From No." <> '' then begin
                NpCsDocumentMapping.Validate("To No.", GetItemRefNo(ItemVariant));
                NpCsDocumentMapping.Modify(true);
            end;

            exit;
        end;

        if ItemVariant.Get(FromItemNo, FromVariantCode) then
            exit;
        if Item.Get(FromItemNo) then begin
            ItemVariant."Item No." := Item."No.";
            ItemVariant.Code := '';

            if NpCsDocumentMapping."From No." <> '' then begin
                NpCsDocumentMapping.Validate("To No.", GetItemRefNo(ItemVariant));
                NpCsDocumentMapping.Modify(true);
            end;
            exit;
        end;

        ItemRef.SetRange("Reference No.", FromItemNo);
        ItemRef.SetRange("Discontinue Bar Code", false);
        if not ItemRef.FindFirst() then
            ItemRef.SetRange("Discontinue Bar Code");

        if ItemRef.FindFirst() then begin
            ItemVariant."Item No." := ItemRef."Item No.";
            ItemVariant.Code := ItemRef."Variant Code";

            if NpCsDocumentMapping."From No." <> '' then begin
                NpCsDocumentMapping.Validate("To No.", ItemRef."Reference No.");
                NpCsDocumentMapping.Modify(true);
            end;

            exit;
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindItemVariant(Element: XmlElement; var ItemVariant: Record "Item Variant"; var Found: Boolean)
    begin
    end;

    local procedure GetItemRefNo(ItemVariant: Record "Item Variant"): Code[50]
    var
        ItemRef: Record "Item Reference";
    begin
        ItemRef.SetRange("Item No.", ItemVariant."Item No.");
        ItemRef.SetRange("Variant Code", ItemVariant.Code);
        ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
        ItemRef.SetFilter("Reference No.", '<>%1', '');
        ItemRef.SetRange("Discontinue Bar Code", false);
        if not ItemRef.FindFirst() then
            ItemRef.SetRange("Discontinue Bar Code");
        if ItemRef.FindFirst() then
            exit(ItemRef."Reference No.");

        exit('');
    end;

    local procedure GetFromStoreCode(Element: XmlElement) StoreCode: Code[20]
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
    begin
        if Element.IsEmpty() then
            exit('');

        StoreCode := NpXmlDomMgt.GetAttributeCode(Element, '/*/sales_document/from_store', 'store_code', MaxStrLen(StoreCode), true);
        exit(StoreCode);
    end;

    local procedure GetToStoreCode(Element: XmlElement) StoreCode: Code[20]
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
    begin
        if Element.IsEmpty() then
            exit('');

        StoreCode := NpXmlDomMgt.GetAttributeCode(Element, '/*/sales_document/to_store', 'store_code', MaxStrLen(StoreCode), false);
        exit(StoreCode);
    end;

    local procedure GetCallback(Element: XmlElement) Callback: Text
    var
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        Callback := NpXmlDomMgt.GetElementText(Element, '/*/sales_document/from_store/callback', 0, false);
        if Callback = '' then
            exit('');

        case LowerCase(NpXmlDomMgt.GetAttributeCode(Element, '/*/sales_document/from_store/callback', 'encoding', 0, false)) of
            'base64':
                Callback := Base64Convert.FromBase64(Callback, TextEncoding::UTF8);
        end;

        exit(Callback);
    end;
}


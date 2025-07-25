﻿codeunit 6151413 "NPR Magento Sales Order Mgt." implements "NPR Nc Import List IProcess"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
    begin
    end;

    var
        MagentoSetup: Record "NPR Magento Setup";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        CurrImportEntry: Record "NPR Nc Import Entry";
        CurrImportType: Record "NPR Nc Import Type";
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        SalesPost: Codeunit "Sales-Post";
        Initialized: Boolean;
        OrderHasComments: Boolean;
        Error001: Label 'Xml Element sell_to_customer is missing';
        Error002: Label 'Item %1 does not exist in %2';
        Error003: Label 'Error during E-mail Confirmation: %1';
        Error004: Label 'When "Auto Transfer Order" is Enabled on Magento Setup, you must configure Magento website and location code in it. Website "%1" is missing!', Comment = '%1 = WebSite Code';
        Error005: Label 'When "Auto Create Req. Lines" is not Enabled on Magento Setup, you must insert at least one Replenishment Transfer Mapping for Location "%1".', Comment = '%1 = Location Code';
        Text000: Label 'Invalid Voucher Reference No. %1';
        Text001: Label 'Voucher %1 is already in use';
        Text002: Label 'Customer Create is not allowed when Customer Update Mode is %1';
        Text003: Label 'Voucher Payment Amount %1 exceeds available Voucher Amount %2';

    internal procedure RunProcessImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    var
        XmlDoc: XmlDocument;
    begin
        CurrImportEntry := ImportEntry;
        Clear(CurrImportType);
        if CurrImportType.Get(CurrImportEntry."Import Type") then;

        if ImportEntry.LoadXmlDoc(XmlDoc) then
            ImportSalesOrders(XmlDoc);
    end;

    local procedure ImportSalesOrders(XmlDoc: XmlDocument)
    var
        XmlElement: XmlElement;
        XNodeList: XmlNodeList;
        XNode: XmlNode;
    begin
        Initialize();
        if not XmlDoc.GetRoot(XmlElement) then
            exit;

        if not XmlElement.SelectNodes('//sales_order', XNodeList) then
            exit;
        foreach XNode in XNodeList do begin
            ImportSalesOrder(XNode.AsXmlElement());
        end;
    end;

    local procedure ImportSalesOrder(XmlElement: XmlElement): Boolean
    var
        SalesHeader: Record "Sales Header";
        MailErrorMessage: Text;
    begin
        if XmlElement.IsEmpty then
            exit(false);
        if OrderExists(XmlElement) then
            exit(false);

        InsertSalesOrder(XmlElement, SalesHeader);

        Commit();

        if MagentoSetup."Send Order Confirmation" then
            MailErrorMessage := SendOrderConfirmation(XmlElement, SalesHeader);
        Commit();

        PostOnImport(SalesHeader);
        Commit();

        if MailErrorMessage <> '' then
            Error(Error003, CopyStr(MailErrorMessage, 1, 900));

        exit(true);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    local procedure InsertSalesOrder(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        InsertSalesHeader(Element, SalesHeader);
        InsertSalesLines(Element, SalesHeader);
        InsertPaymentLines(Element, SalesHeader);
        InsertComments(Element, SalesHeader);
        UpdateExtCouponReservations(SalesHeader);
        OnBeforeRelease(CurrImportType, CurrImportEntry, Element, SalesHeader);

        if MagentoSetup."Release Order on Import" then
            ReleaseSalesDoc.PerformManualRelease(SalesHeader);

        InsertCollectDocument(Element, SalesHeader);

        UpdateRetailVoucherCustomerInfo(SalesHeader);

        OnBeforeCommit(CurrImportType, CurrImportEntry, Element, SalesHeader);
    end;

    local procedure InsertCollectDocument(XmlElement: XmlElement; var SalesHeader: Record "Sales Header")
    var
        NpCsWorkflow: Record "NPR NpCs Workflow";
        NpCsDocument: Record "NPR NpCs Document";
        NpCsStoreFrom: Record "NPR NpCs Store";
        NpCsStoreTo: Record "NPR NpCs Store";
        NpCsCollectMgt: Codeunit "NPR NpCs Collect Mgt.";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        XmlElementCollect: XmlElement;
        StoreCode: Code[20];
    begin
        if not NpXmlDomMgt.FindElement(XmlElement, 'shipment/collect_in_store', false, XmlElementCollect) then
            exit;

        MagentoSetup.TestField("Collect in Store Enabled");
        MagentoSetup.TestField("NpCs From Store Code");
        MagentoSetup.TestField("NpCs Workflow Code");

        StoreCode := CopyStr(NpXmlDomMgt.GetAttributeCode(XmlElementCollect, '', 'store_code', MaxStrLen(NpCsStoreTo.Code), true), 1, MaxStrLen(StoreCode));
        if StoreCode = '' then
            exit;

        NpCsStoreTo.Get(StoreCode);

        NpCsWorkflow.Get(MagentoSetup."NpCs Workflow Code");
        NpCsCollectMgt.InitSendToStoreDocument(SalesHeader, NpCsStoreTo, NpCsWorkflow, NpCsDocument);
        OnAfterInitSendToStoreDocument(SalesHeader, NpCsStoreTo, NpCsWorkflow, NpCsDocument);

        SalesHeader.CalcFields("NPR Magento Payment Amount");
        if SalesHeader."NPR Magento Payment Amount" <> 0 then
            NpCsDocument."Bill via" := NpCsDocument."Bill via"::"Sales Document"
        else
            NpCsDocument."Bill via" := NpCsDocument."Bill via"::POS;

        NpCsStoreFrom.Get(MagentoSetup."NpCs From Store Code");
        NpCsDocument."From Store Code" := NpCsStoreFrom.Code;
        NpCsDocument."To Document Type" := NpCsDocument."To Document Type"::Order;

        NpCsDocument."Allow Partial Delivery" := NpXmlDomMgt.GetElementBoolean(XmlElementCollect, 'allow_partial_delivery', false);

        NpCsDocument."Notify Customer via E-mail" := NpXmlDomMgt.GetElementBoolean(XmlElementCollect, 'notify_customer_via_email', false);
        NpCsDocument."Customer E-mail" :=
          CopyStr(NpXmlDomMgt.GetElementText(XmlElementCollect, 'customer_email', MaxStrLen(NpCsDocument."Customer E-mail"), false), 1, MaxStrLen(NpCsDocument."Customer E-mail"));
        if NpCsDocument."Customer E-mail" = '' then
            NpCsDocument."Customer E-mail" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'sell_to_customer/email', MaxStrLen(NpCsDocument."Customer E-mail"), true), 1, MaxStrLen(NpCsDocument."Customer E-mail"));

        NpCsDocument."Notify Customer via Sms" := NpXmlDomMgt.GetElementBoolean(XmlElementCollect, 'notify_customer_via_sms', false);
        NpCsDocument."Customer Phone No." :=
          CopyStr(NpXmlDomMgt.GetElementText(XmlElementCollect, 'customer_phone', MaxStrLen(NpCsDocument."Customer Phone No."), false), 1, MaxStrLen(NpCsDocument."Customer Phone No."));
        if NpCsDocument."Customer Phone No." = '' then
            NpCsDocument."Customer Phone No." := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'sell_to_customer/phone', MaxStrLen(NpCsDocument."Customer Phone No."), false), 1, MaxStrLen(NpCsDocument."Customer Phone No."));

        if not NpCsDocument."Notify Customer via Sms" then
            NpCsDocument."Notify Customer via E-mail" := true;

        SalesHeader.CalcFields("NPR Magento Payment Amount");
        NpCsDocument."Prepaid Amount" := SalesHeader."NPR Magento Payment Amount";
        NpCsDocument.Modify(true);

        NpCsWorkflowMgt.ScheduleRunWorkflow(NpCsDocument);
    end;

    local procedure InsertCommentLine(XmlElement: XmlElement; var SalesHeader: Record "Sales Header")
    var
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
        CommentLine: Text;
        CommentType: Text;
        Note: Text;
        LinkID: Integer;
    begin
        CommentType := NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'type', false);
        CommentLine := NpXmlDomMgt.GetXmlText(XmlElement, 'comment', 0, true);
        if CommentLine <> '' then begin
            if CommentType <> '' then
                LinkID := SalesHeader.AddLink('', SalesHeader."No." + '-' + CommentType)
            else
                LinkID := SalesHeader.AddLink('', SalesHeader."No.");
            RecordLink.Get(LinkID);
            RecordLink.Type := RecordLink.Type::Note;
            RecordLink."User ID" := '';
            if CommentType <> '' then
                Note := CommentType + ': ' + CommentLine
            else
                Note := CommentLine;

            RecordLinkManagement.WriteNote(RecordLink, Note);
            RecordLink.Modify(true);
            OrderHasComments := true;
            OnAfterInsertCommentLine(CurrImportType, CurrImportEntry, XmlElement, SalesHeader, RecordLink);
        end;
    end;

    local procedure InsertComments(XmlElement: XmlElement; var SalesHeader: Record "Sales Header")
    var
        XNode: XmlNode;
        XNodeList: XmlNodeList;
    begin
        OrderHasComments := false;
        XmlElement.SelectNodes('comments/comment_line', XNodeList);
        foreach XNode in XNodeList do begin
            InsertCommentLine(XNode.AsXmlElement(), SalesHeader);
        end;
    end;

    local procedure InsertCustomer(XmlElement: XmlElement; IsContactCustomer: Boolean; var Customer: Record Customer; MagentoWebsite: Record "NPR Magento Website"): Boolean
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        CustTemplate: Record "Customer Templ.";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        UpdateContFromCust: Codeunit "CustCont-Update";
        RecRef: RecordRef;
        ExternalCustomerNo: Text;
        TaxClass: Text;
        ConfigTemplateCode: Code[10];
        VATBusPostingGroup: Code[20];
        NewCust: Boolean;
        PrevCust: Text;
        CustTemplateCode: Code[20];
        CustNo: Code[20];
    begin
        Initialize();
        ExternalCustomerNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'customer_no', false);
        if IsContactCustomer then begin
            if GetContactCustomer(CopyStr(ExternalCustomerNo, 1, 20), Customer) then
                exit;
        end;

        TaxClass := NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'tax_class', true);
        NewCust := not GetCustomer(CopyStr(ExternalCustomerNo, 1, 20), XmlElement, Customer);

        if NewCust and (MagentoSetup."Customer Update Mode" = MagentoSetup."Customer Update Mode"::Fixed) then begin
            Customer."Post Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement, 'post_code', MaxStrLen(Customer."Post Code"), true)), 1, MaxStrLen(Customer."Post Code"));
            Customer."Country/Region Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement, 'country_code', MaxStrLen(Customer."Country/Region Code"), false)), 1, MaxStrLen(Customer."Country/Region Code"));
            CustNo := MagentoMgt.GetFixedCustomerNo(Customer);
            Customer.Get(CustNo);
            NewCust := false;
        end;

        if NewCust then begin
            if not (MagentoSetup."Customer Update Mode" in [MagentoSetup."Customer Update Mode"::"Create and Update", MagentoSetup."Customer Update Mode"::Create]) then
                Error(Text002, MagentoSetup."Customer Update Mode");
            VATBusPostingGroup := MagentoMgt.GetVATBusPostingGroup(TaxClass);

            InitCustomer(XmlElement, Customer, MagentoWebsite);
            Customer."NPR External Customer No." := CopyStr(ExternalCustomerNo, 1, MaxStrLen(Customer."NPR External Customer No."));
            Customer.Insert(true);
            Customer."Post Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement, 'post_code', MaxStrLen(Customer."Post Code"), true)), 1, MaxStrLen(Customer."Post Code"));
            Customer."Country/Region Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement, 'country_code', MaxStrLen(Customer."Country/Region Code"), false)), 1, MaxStrLen(Customer."Country/Region Code"));

            CustTemplateCode := MagentoMgt.GetCustTemplate(Customer);
            if CustTemplateCode <> '' then begin
                CustTemplate.Get(CustTemplateCode);
                Customer."Gen. Bus. Posting Group" := CustTemplate."Gen. Bus. Posting Group";
                Customer."VAT Bus. Posting Group" := CustTemplate."VAT Bus. Posting Group";
                Customer."Customer Posting Group" := CustTemplate."Customer Posting Group";
                Customer."Currency Code" := GetCurrencyCode(CustTemplate."Currency Code");
                Customer."Customer Price Group" := CustTemplate."Customer Price Group";
                Customer."Invoice Disc. Code" := CustTemplate."Invoice Disc. Code";
                Customer."Customer Disc. Group" := CustTemplate."Customer Disc. Group";
                Customer."Allow Line Disc." := CustTemplate."Allow Line Disc.";
                Customer."Payment Terms Code" := CustTemplate."Payment Terms Code";
                Customer."Payment Method Code" := CustTemplate."Payment Method Code";
                Customer."Shipment Method Code" := CustTemplate."Shipment Method Code";
            end else
                if ConfigTemplateCode = '' then begin
                    Customer.Validate("Gen. Bus. Posting Group", VATBusPostingGroup);
                    Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
                end;
        end;
        case MagentoSetup."Customer Update Mode" of
            MagentoSetup."Customer Update Mode"::Create:
                begin
                    if not NewCust then
                        exit;
                end;
            MagentoSetup."Customer Update Mode"::None:
                begin
                    exit;
                end;
            MagentoSetup."Customer Update Mode"::Fixed:
                begin
                    exit;
                end;
        end;

        PrevCust := Format(Customer);
        Customer."Post Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement, 'post_code', MaxStrLen(Customer."Post Code"), true)), 1, MaxStrLen(Customer."Post Code"));
        Customer."Country/Region Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement, 'country_code', MaxStrLen(Customer."Country/Region Code"), false)), 1, MaxStrLen(Customer."Country/Region Code"));
        ConfigTemplateCode := MagentoMgt.GetCustConfigTemplate(TaxClass, Customer);
        if (ConfigTemplateCode <> '') and ConfigTemplateHeader.Get(ConfigTemplateCode) then begin
            RecRef.GetTable(Customer);
            ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
            RecRef.SetTable(Customer);
        end;

        Customer.Name := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'name', MaxStrLen(Customer.Name), true), 1, MaxStrLen(Customer.Name));
        Customer."Name 2" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'name_2', MaxStrLen(Customer."Name 2"), false), 1, MaxStrLen(Customer."Name 2"));
        Customer.Address := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'address', MaxStrLen(Customer.Address), true), 1, MaxStrLen(Customer.Address));
        Customer."Address 2" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'address_2', MaxStrLen(Customer.Address), false), 1, MaxStrLen(Customer."Address 2"));
        Customer."Post Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement, 'post_code', MaxStrLen(Customer."Post Code"), true)), 1, MaxStrLen(Customer."Post Code"));
        Customer.County := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement, 'county', MaxStrLen(Customer.County), false)), 1, MaxStrLen(Customer.County));
        Customer.City := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'city', MaxStrLen(Customer.City), true), 1, MaxStrLen(Customer.City));
        Customer."Country/Region Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement, 'country_code', MaxStrLen(Customer."Country/Region Code"), false)), 1, MaxStrLen(Customer."Country/Region Code"));
        Customer.Contact := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'contact', MaxStrLen(Customer.Contact), false), 1, MaxStrLen(Customer.Contact));
        Customer."E-Mail" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'email', MaxStrLen(Customer."E-Mail"), true), 1, MaxStrLen(Customer."E-Mail"));
        Customer."Phone No." := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'phone', MaxStrLen(Customer."Phone No."), false), 1, MaxStrLen(Customer."Phone No."));
        Customer.GLN := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'ean', MaxStrLen(Customer.GLN), false), 1, MaxStrLen(Customer.GLN));
        if Customer.GLN <> '' then begin
            RecRef.GetTable(Customer);
            SetFieldText(RecRef, 13600, Customer.GLN);
            RecRef.SetTable(Customer);

            if Customer.Contact = '' then
                Customer.Contact := 'X';
        end;
        Customer."VAT Registration No." := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'vat_registration_no', MaxStrLen(Customer."VAT Registration No."), false), 1, MaxStrLen(Customer."VAT Registration No."));
        Customer."Prices Including VAT" := true;
        if NpXmlDomMgt.GetElementBoolean(XmlElement, '../prices_excluding_vat', false) then
            Customer."Prices Including VAT" := false;
        OnBeforeModifyCustomer(CurrImportType, CurrImportEntry, XmlElement, Customer);
        if PrevCust = Format(Customer) then
            exit;
        Customer.Modify(true);

        UpdateContFromCust.OnModify(Customer);
    end;

    local procedure InsertPaymentLinePaymentMethod(XmlElement: XmlElement; var SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
        TransactionId: Text;
        PaymentAmount: Decimal;
        ShopperReference: Text;
        PaymentToken: Text;
        Brand: Text;
        CardSummary: Text;
        PaymentInstrumentType: Text;
        ExpiryDateText: Text;
        CardPaymentInstrumentTypeLbl: Label 'Card';
    begin
        TransactionId := NpXmlDomMgt.GetXmlText(XmlElement, 'transaction_id', MaxStrLen(PaymentLine."Transaction ID"), false);
        Evaluate(PaymentAmount, NpXmlDomMgt.GetXmlText(XmlElement, 'payment_amount', 0, true), 9);
        if PaymentAmount = 0 then
            exit;
        ShopperReference := NpXmlDomMgt.GetXmlText(XmlElement, 'shopper_reference', MaxStrLen(PaymentLine."No."), false);
        PaymentToken := NpXmlDomMgt.GetXmlText(XmlElement, 'token', MaxStrLen(PaymentLine."Payment Token"), false);
        ExpiryDateText := NpXmlDomMgt.GetXmlText(XmlElement, 'expiry_date', MaxStrLen(PaymentLine."Payment Token"), false);
        Brand := NpXmlDomMgt.GetXmlText(XmlElement, 'brand', MaxStrLen(PaymentLine.Brand), false);
        CardSummary := NpXmlDomMgt.GetXmlText(XmlElement, 'card_summary', MaxStrLen(PaymentLine."Card Summary"), false);
        if PaymentToken <> '' then
            PaymentInstrumentType := CardPaymentInstrumentTypeLbl;

        PaymentMapping.SetRange("External Payment Method Code", CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'code', true), 1, MaxStrLen(PaymentMapping."External Payment Method Code")));

        PaymentMapping.SetRange("External Payment Type", NpXmlDomMgt.GetXmlText(XmlElement, 'payment_type', MaxStrLen(PaymentMapping."External Payment Type"), false));
        if not PaymentMapping.FindFirst() then begin
            PaymentMapping.SetRange("External Payment Type");
            PaymentMapping.FindFirst();
        end;
        PaymentMapping.TestField("Payment Method Code");
        PaymentMethod.Get(PaymentMapping."Payment Method Code");

        LineNo += 10000;
        PaymentLine."Document Table No." := DATABASE::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := LineNo;
        PaymentLine.Description := CopyStr(PaymentMethod.Description + ' ' + SalesHeader."NPR External Order No.", 1, MaxStrLen(PaymentLine.Description));
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine."Account Type" := PaymentMethod."Bal. Account Type";
        PaymentLine."Account No." := PaymentMethod."Bal. Account No.";
        PaymentLine."No." := CopyStr(TransactionId, 1, MaxStrLen(PaymentLine."No."));
        PaymentLine."Transaction ID" := CopyStr(TransactionId, 1, MaxStrLen(PaymentLine."Transaction ID"));
        PaymentLine."Posting Date" := SalesHeader."Posting Date";
        PaymentLine."Source Table No." := DATABASE::"Payment Method";
        PaymentLine."Source No." := PaymentMethod.Code;
        PaymentLine.Amount := PaymentAmount;
        PaymentLine."Allow Adjust Amount" := PaymentMapping."Allow Adjust Payment Amount";
        PaymentLine."Payment Gateway Code" := PaymentMapping."Payment Gateway Code";
        PaymentLine."Payment Gateway Shopper Ref." := CopyStr(ShopperReference, 1, MaxStrLen(PaymentLine."Payment Gateway Shopper Ref."));
        PaymentLine."Payment Token" := CopyStr(PaymentToken, 1, MaxStrLen(PaymentLine."Payment Token"));
        PaymentLine."Expiry Date Text" := Copystr(ExpiryDateText, 1, MaxStrLen(PaymentLine."Expiry Date Text"));
        PaymentLine.Brand := CopyStr(Brand, 1, MaxStrLen(PaymentLine."Payment Instrument Type"));
        PaymentLine."Payment Instrument Type" := CopyStr(CardPaymentInstrumentTypeLbl, 1, MaxStrLen(PaymentLine."Payment Instrument Type"));
        PaymentLine."Card Summary" := CopyStr(CardSummary, 1, MaxStrLen(PaymentLine."Card Summary"));

        if PaymentMapping."Captured Externally" then
            PaymentLine."Date Captured" := GetDate(SalesHeader."Order Date", SalesHeader."Posting Date");

        InsertPaymentLine(PaymentLine, SalesHeader, LineNo);
    end;

    local procedure InsertRetailVoucherPayment(XmlElement: XmlElement; var SalesHeader: Record "Sales Header"; var LineNo: Integer): Boolean
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        PaymentLine: Record "NPR Magento Payment Line";
        NpRvGlobalVoucherWebservice: Codeunit "NPR NpRv Global Voucher WS";
        NpRvVoucherMngt: Codeunit "NPR NpRv Voucher Mgt.";
        NpRvSalesDocMgt: Codeunit "NPR NpRv Sales Doc. Mgt.";
        ExternalReferenceNo: Text;
        Amount: Decimal;
        AvailableAmount: Decimal;
    begin
        ExternalReferenceNo := NpXmlDomMgt.GetXmlText(XmlElement, 'transaction_id', MaxStrLen(NpRvVoucher."Reference No."), true);
        Evaluate(Amount, NpXmlDomMgt.GetXmlText(XmlElement, 'payment_amount', 0, true), 9);

        if not NpRvGlobalVoucherWebservice.FindVoucher('', CopyStr(ExternalReferenceNo, 1, 50), NpRvVoucher) then
            Error(Text000, ExternalReferenceNo);

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("External Document No.", SalesHeader."NPR External Order No.");
        NpRvSalesLine.SetRange("Voucher Type", NpRvVoucher."Voucher Type");
        NpRvSalesLine.SetRange("Voucher No.", NpRvVoucher."No.");
        NpRvSalesLine.SetRange(Type, NpRvSalesLine.Type::Payment);
        if not NpRvSalesLine.FindFirst() then begin
            if not NpRvVoucherMngt.VoucherReservationByAmountFeatureEnabled() then begin
                if NpRvVoucher.CalcInUseQty() > 0 then
                    Error(Text001, NpRvVoucher."Reference No.");
            end;

            NpRvSalesLine.Init();
            NpRvSalesLine.Id := CreateGuid();
            NpRvSalesLine."External Document No." := SalesHeader."NPR External Order No.";
            NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
            NpRvSalesLine."Document Type" := SalesHeader."Document Type";
            NpRvSalesLine."Document No." := SalesHeader."No.";
            NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
            NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
            NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
            NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
            NpRvSalesLine.Description := NpRvVoucher.Description;
            NpRvSalesLine.Insert(true);
        end;

        LineNo += 10000;
        PaymentLine.Init();
        PaymentLine."Document Table No." := DATABASE::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := LineNo;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::Voucher;
        PaymentLine.Description := NpRvVoucher.Description;
        PaymentLine."Account No." := NpRvVoucher."Account No.";
        PaymentLine."No." := NpRvVoucher."Reference No.";
        PaymentLine."Posting Date" := SalesHeader."Posting Date";
        PaymentLine."Source Table No." := DATABASE::"NPR NpRv Voucher";
        PaymentLine."Source No." := NpRvVoucher."No.";
        PaymentLine."External Reference No." := SalesHeader."NPR External Order No.";
        PaymentLine.Amount := Amount;
        InsertPaymentLine(PaymentLine, SalesHeader, LineNo);

        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Payment Line";
        NpRvSalesLine."Document Type" := SalesHeader."Document Type"::Order;
        NpRvSalesLine."Document No." := SalesHeader."No.";
        NpRvSalesLine."Document Line No." := PaymentLine."Line No.";
        NpRvSalesLine.Amount := PaymentLine.Amount;
        NpRvSalesLine."Reservation Line Id" := PaymentLine.SystemId;
        NpRvSalesLine.Modify(true);

        if not NpRvVoucherMngt.ValidateAmount(NpRvVoucher, PaymentLine.SystemId, Amount, AvailableAmount) then
            Error(Text003, Amount, AvailableAmount);

        NpRvSalesDocMgt.ApplyPayment(SalesHeader, NpRvSalesLine);

    end;

    local procedure InsertPaymentLines(XmlElement: XmlElement; var SalesHeader: Record "Sales Header")
    var
        XNode: XmlNode;
        XNodeList: XmlNodeList;
        LineNo: Integer;
    begin
        if XmlElement.SelectSingleNode('payments', XNode) then begin
            XNode.SelectNodes('payment_method', XNodeList);
            LineNo := 0;
            foreach XNode in XNodeList do begin
                case LowerCase(NpXmlDomMgt.GetXmlAttributeText(XNode, 'type', true)) of
                    'payment_gateway', '':
                        InsertPaymentLinePaymentMethod(XNode.AsXmlElement(), SalesHeader, LineNo);
                    'retail_voucher':
                        InsertRetailVoucherPayment(XNode.AsXmlElement(), SalesHeader, LineNo);
                end;
            end;
        end;
    end;

    local procedure InsertSalesHeader(XmlElement: XmlElement; var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        TempCustomer: Record Customer temporary;
        MagentoWebsite: Record "NPR Magento Website";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        NPRMagentoMgt: Codeunit "NPR Magento Mgt.";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
        ManulBoundEventSubMgt: Codeunit "NPR Manul Bound Event Sub. Mgt";
        RecRef: RecordRef;
        XmlElement2: XmlElement;
        XNode: XmlNode;
        XNodeList: XmlNodeList;
        OrderNo: Code[20];
        CurrencyFactor: Decimal;
        InvoiceEmail: Text[80];
    begin
        Initialize();
        Clear(SalesHeader);
        OrderNo := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'order_no', true), 1, MaxStrLen(OrderNo));
        if MagentoWebsite.Get(NpXmlDomMgt.GetAttributeCode(XmlElement, '', 'website_code', MaxStrLen(MagentoWebsite.Code), true)) then;

        if MagentoSetup."Auto Transfer Order Enabled" then begin
            if MagentoWebsite.IsEmpty() then
                Error(Error004, NpXmlDomMgt.GetAttributeCode(XmlElement, '', 'website_code', MaxStrLen(MagentoWebsite.Code), true));

            MagentoWebsite.TestField("Location Code");
        end;

        if not XmlElement.SelectSingleNode('sell_to_customer', XNode) then
            Error(Error001);
        XmlElement2 := XNode.AsXmlElement();
        InsertCustomer(XmlElement2, MagentoSetup."Customers Enabled", Customer, MagentoWebsite);
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := '';
        if MagentoWebsite."Sales Order No. Series" <> '' then begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            SalesHeader."No. Series" := MagentoWebsite."Sales Order No. Series";
            SalesHeader."No." := NoSeriesMgt.GetNextNo(SalesHeader."No. Series");
#ELSE
            NoSeriesMgt.InitSeries(MagentoWebsite."Sales Order No. Series", SalesHeader."No. Series", Today, SalesHeader."No.", SalesHeader."No. Series");
#ENDIF
        end;

        SalesHeader."NPR External Order No." := CopyStr(OrderNo, 1, MaxStrLen(SalesHeader."NPR External Order No."));
        SalesHeader."External Document No." := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'external_document_no', MaxStrLen(SalesHeader."External Document No."), false), 1, MaxStrLen(SalesHeader."External Document No."));
        if SalesHeader."External Document No." = '' then
            SalesHeader."External Document No." := SalesHeader."NPR External Order No.";
        SalesHeader."Your Reference" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'your_reference', MaxStrLen(SalesHeader."Your Reference"), false), 1, MaxStrLen(SalesHeader."Your Reference"));
        OnBeforeInsertSalesHeader(CurrImportType, CurrImportEntry, XmlElement, SalesHeader);
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");

        if MagentoWebsite."Responsibility Center" <> '' then begin
            BindSubscription(ManulBoundEventSubMgt);
            SalesHeader.Validate("Responsibility Center", MagentoWebsite."Responsibility Center");
            UnbindSubscription(ManulBoundEventSubMgt);
        end;

        SalesHeader."Sell-to Customer Name" := CopyStr(NpXmlDomMgt.GetElementText(XmlElement2, 'name', MaxStrLen(SalesHeader."Sell-to Customer Name"), true), 1, MaxStrLen(SalesHeader."Sell-to Customer Name"));
        SalesHeader."Sell-to Customer Name 2" := CopyStr(NpXmlDomMgt.GetElementText(XmlElement2, 'name_2', MaxStrLen(SalesHeader."Sell-to Customer Name 2"), false), 1, MaxStrLen(SalesHeader."Sell-to Customer Name 2"));
        SalesHeader."Sell-to Address" := CopyStr(NpXmlDomMgt.GetElementText(XmlElement2, 'address', MaxStrLen(SalesHeader."Sell-to Address"), true), 1, MaxStrLen(SalesHeader."Sell-to Address"));
        SalesHeader."Sell-to Address 2" := CopyStr(NpXmlDomMgt.GetElementText(XmlElement2, 'address_2', MaxStrLen(SalesHeader."Sell-to Address 2"), false), 1, MaxStrLen(SalesHeader."Sell-to Address 2"));
        SalesHeader."Sell-to Post Code" := CopyStr(UpperCase(NpXmlDomMgt.GetElementCode(XmlElement2, 'post_code', MaxStrLen(SalesHeader."Sell-to Post Code"), true)), 1, MaxStrLen(SalesHeader."Sell-to Post Code"));
        SalesHeader."Sell-to County" := CopyStr(UpperCase(NpXmlDomMgt.GetElementCode(XmlElement2, 'county', MaxStrLen(SalesHeader."Sell-to County"), false)), 1, MaxStrLen(SalesHeader."Sell-to County"));
        SalesHeader."Sell-to City" := CopyStr(NpXmlDomMgt.GetElementText(XmlElement2, 'city', MaxStrLen(SalesHeader."Sell-to City"), true), 1, MaxStrLen(SalesHeader."Sell-to City"));
        SalesHeader."Sell-to Country/Region Code" := CopyStr(NpXmlDomMgt.GetElementCode(XmlElement2, 'country_code', MaxStrLen(SalesHeader."Sell-to Country/Region Code"), false), 1, MaxStrLen(SalesHeader."Sell-to Country/Region Code"));
        SalesHeader."Sell-to Contact" := CopyStr(NpXmlDomMgt.GetElementText(XmlElement2, 'contact', MaxStrLen(SalesHeader."Sell-to Contact"), false), 1, MaxStrLen(SalesHeader."Sell-to Contact"));

        SalesHeader."NPR Magento Coupon" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'magento_coupon', MaxStrLen(SalesHeader."NPR Magento Coupon"), false), 1, MaxStrLen(SalesHeader."NPR Magento Coupon"));
        SalesHeader."NPR Sales Channel" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'sales_channel', MaxStrLen(SalesHeader."NPR Sales Channel"), false), 1, MaxStrLen(SalesHeader."NPR Sales Channel"));

        RecRef.GetTable(SalesHeader);
        SetFieldText(RecRef, 171, NpXmlDomMgt.GetXmlText(XmlElement2, 'phone', MaxStrLen(Customer."Phone No."), false));
        SetFieldText(RecRef, 13605, NpXmlDomMgt.GetXmlText(XmlElement2, 'phone', MaxStrLen(Customer."Phone No."), false));
        SetFieldText(RecRef, 13635, NpXmlDomMgt.GetXmlText(XmlElement2, 'phone', MaxStrLen(Customer."Phone No."), false));
        SetFieldText(RecRef, 172, NpXmlDomMgt.GetXmlText(XmlElement2, 'email', MaxStrLen(Customer."E-Mail"), false));
        SetFieldText(RecRef, 13607, NpXmlDomMgt.GetXmlText(XmlElement2, 'email', MaxStrLen(Customer."E-Mail"), false));
        SetFieldText(RecRef, 13637, NpXmlDomMgt.GetXmlText(XmlElement2, 'email', MaxStrLen(Customer."E-Mail"), false));
        SetFieldText(RecRef, 13630, NpXmlDomMgt.GetXmlText(XmlElement2, 'ean', MaxStrLen(Customer.GLN), false));
        RecRef.SetTable(SalesHeader);

        InvoiceEmail := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'invoice_email', 0, false), 1, MaxStrLen(InvoiceEmail));
        if InvoiceEmail <> '' then
            SalesHeader."NPR Bill-to E-mail" := InvoiceEmail;

        case MagentoSetup."Customer Update Mode" of
            MagentoSetup."Customer Update Mode"::Fixed:
                begin
                    TempCustomer."Post Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement2, 'post_code', MaxStrLen(Customer."Post Code"), true)), 1, MaxStrLen(TempCustomer."Post Code"));
                    TempCustomer."Country/Region Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement2, 'country_code', MaxStrLen(Customer."Country/Region Code"), false)), 1, MaxStrLen(TempCustomer."Country/Region Code"));
                    if SalesHeader."Sell-to Customer No." = NPRMagentoMgt.GetFixedCustomerNo(TempCustomer) then begin
                        SalesHeader."Bill-to Name" := SalesHeader."Sell-to Customer Name";
                        SalesHeader."Bill-to Name 2" := SalesHeader."Sell-to Customer Name 2";
                        SalesHeader."Bill-to Address" := SalesHeader."Sell-to Address";
                        SalesHeader."Bill-to Address 2" := SalesHeader."Sell-to Address 2";
                        SalesHeader."Bill-to Post Code" := SalesHeader."Sell-to Post Code";
                        SalesHeader."Bill-to City" := SalesHeader."Sell-to City";
                        SalesHeader."Bill-to Contact" := SalesHeader."Sell-to Contact";
                        SalesHeader."Bill-to Contact No." := SalesHeader."Sell-to Contact No.";
                        SalesHeader."Bill-to Country/Region Code" := SalesHeader."Sell-to Country/Region Code";
                        SalesHeader."Bill-to County" := SalesHeader."Sell-to County";
                        SalesHeader."NPR Bill-to E-mail" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'email', MaxStrLen(SalesHeader."NPR Bill-to E-mail"), false), 1, MaxStrLen(SalesHeader."NPR Bill-to E-mail"));
                        SalesHeader."Ship-to Name" := SalesHeader."Sell-to Customer Name";
                        SalesHeader."Ship-to Name 2" := SalesHeader."Sell-to Customer Name 2";
                        SalesHeader."Ship-to Address" := SalesHeader."Sell-to Address";
                        SalesHeader."Ship-to Address 2" := SalesHeader."Sell-to Address 2";
                        SalesHeader."Ship-to Post Code" := SalesHeader."Sell-to Post Code";
                        SalesHeader."Ship-to City" := SalesHeader."Sell-to City";
                        SalesHeader."Ship-to Country/Region Code" := SalesHeader."Sell-to Country/Region Code";
                        SalesHeader."Ship-to Contact" := SalesHeader."Sell-to Contact";
                        SalesHeader."Ship-to County" := SalesHeader."Sell-to County";
                    end;
                end;
        end;
        SalesHeader."Prices Including VAT" := true;
        if NpXmlDomMgt.GetElementBoolean(XmlElement, 'prices_excluding_vat', false) then
            SalesHeader."Prices Including VAT" := false;

        if XmlElement.SelectSingleNode('ship_to_customer', XNode) then begin
            XmlElement2 := XNode.AsXmlElement();
            SalesHeader."Ship-to Name" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'name', MaxStrLen(SalesHeader."Ship-to Name"), true), 1, MaxStrLen(SalesHeader."Ship-to Name"));
            SalesHeader."Ship-to Name 2" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'name_2', MaxStrLen(SalesHeader."Ship-to Name 2"), false), 1, MaxStrLen(SalesHeader."Ship-to Name 2"));
            SalesHeader."Ship-to Address" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'address', MaxStrLen(SalesHeader."Ship-to Address"), true), 1, MaxStrLen(SalesHeader."Ship-to Address"));
            SalesHeader."Ship-to Address 2" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'address_2', MaxStrLen(SalesHeader."Ship-to Address 2"), false), 1, MaxStrLen(SalesHeader."Ship-to Address 2"));
            SalesHeader."Ship-to Post Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement2, 'post_code', MaxStrLen(SalesHeader."Ship-to Post Code"), true)), 1, MaxStrLen(SalesHeader."Ship-to Post Code"));
            SalesHeader."Ship-to County" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement2, 'county', MaxStrLen(SalesHeader."Ship-to County"), false)), 1, MaxStrLen(SalesHeader."Ship-to County"));
            SalesHeader."Ship-to City" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'city', MaxStrLen(SalesHeader."Ship-to City"), true), 1, MaxStrLen(SalesHeader."Ship-to City"));
            SalesHeader."Ship-to Country/Region Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement2, 'country_code', MaxStrLen(SalesHeader."Ship-to Country/Region Code"), false)), 1, MaxStrLen(SalesHeader."Ship-to Country/Region Code"));
            SalesHeader."Ship-to Contact" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'contact', MaxStrLen(SalesHeader."Ship-to Contact"), false), 1, MaxStrLen(SalesHeader."Ship-to Contact"));
        end else begin
            // Ship-to node does not exist. Proceed with updating the ship-to address with sell-to fields from the xml! 
            XmlElement.SelectSingleNode('sell_to_customer', XNode);
            XmlElement2 := XNode.AsXmlElement();
            SalesHeader."Ship-to Name" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'name', MaxStrLen(SalesHeader."Ship-to Name"), true), 1, MaxStrLen(SalesHeader."Ship-to Name"));
            SalesHeader."Ship-to Name 2" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'name_2', MaxStrLen(SalesHeader."Ship-to Name 2"), false), 1, MaxStrLen(SalesHeader."Ship-to Name 2"));
            SalesHeader."Ship-to Address" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'address', MaxStrLen(SalesHeader."Ship-to Address"), true), 1, MaxStrLen(SalesHeader."Ship-to Address"));
            SalesHeader."Ship-to Address 2" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'address_2', MaxStrLen(SalesHeader."Ship-to Address 2"), false), 1, MaxStrLen(SalesHeader."Ship-to Address 2"));
            SalesHeader."Ship-to Post Code" := CopyStr(UpperCase(NpXmlDomMgt.GetElementCode(XmlElement2, 'post_code', MaxStrLen(SalesHeader."Ship-to Post Code"), true)), 1, MaxStrLen(SalesHeader."Ship-to Post Code"));
            SalesHeader."Ship-to County" := CopyStr(UpperCase(NpXmlDomMgt.GetElementCode(XmlElement2, 'county', MaxStrLen(SalesHeader."Ship-to County"), false)), 1, MaxStrLen(SalesHeader."Ship-to County"));
            SalesHeader."Ship-to City" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement2, 'city', MaxStrLen(SalesHeader."Ship-to City"), true), 1, MaxStrLen(SalesHeader."Ship-to City"));
            SalesHeader."Ship-to Country/Region Code" := CopyStr(NpXmlDomMgt.GetElementCode(XmlElement2, 'country_code', MaxStrLen(SalesHeader."Ship-to Country/Region Code"), false), 1, MaxStrLen(SalesHeader."Ship-to Country/Region Code"));
            SalesHeader."Ship-to Contact" := CopyStr(NpXmlDomMgt.GetElementText(XmlElement2, 'contact', MaxStrLen(SalesHeader."Ship-to Contact"), false), 1, MaxStrLen(SalesHeader."Ship-to Contact"));
        end;

        SalesHeader.Validate("Salesperson Code", MagentoSetup."Salesperson Code");

        if NpXmlDomMgt.GetElementBoolean(XmlElement, 'use_customer_salesperson', false) and (Customer."Salesperson Code" <> '') then
            SalesHeader.Validate("Salesperson Code", Customer."Salesperson Code");

        if XmlElement.SelectSingleNode('shipment', XNode) then begin
            XmlElement2 := XNode.AsXmlElement();
            ShipmentMapping.SetRange("External Shipment Method Code", NpXmlDomMgt.GetXmlText(XmlElement2, 'shipment_method', MaxStrLen(ShipmentMapping."External Shipment Method Code"), true));
            ShipmentMapping.FindFirst();
            SalesHeader.Validate("Shipment Method Code", ShipmentMapping."Shipment Method Code");
            SalesHeader.Validate("Shipping Agent Code", ShipmentMapping."Shipping Agent Code");
            SalesHeader.Validate("Shipping Agent Service Code", ShipmentMapping."Shipping Agent Service Code");
            RecRef.GetTable(SalesHeader);
            SetFieldText(RecRef, 6014420, NpXmlDomMgt.GetXmlText(XmlElement2, 'shipment_service', 50, false));
            RecRef.SetTable(SalesHeader);
        end;

        if XmlElement.SelectNodes('payments/payment_method', XNodeList) then begin
            foreach XNode in XNodeList do begin
                XmlElement2 := XNode.AsXmlElement();
                if (LowerCase(NpXmlDomMgt.GetXmlAttributeText(XmlElement2, 'type', true)) = 'payment_gateway')
                and (SalesHeader."Payment Method Code" = '') then begin
                    PaymentMapping.SetRange("External Payment Method Code",
                      CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement2, 'code', true), 1, MaxStrLen(PaymentMapping."External Payment Method Code")));
                    PaymentMapping.SetRange("External Payment Type",
                      NpXmlDomMgt.GetXmlText(XmlElement2, 'payment_type', MaxStrLen(PaymentMapping."External Payment Type"), false));
                    if not PaymentMapping.FindFirst() then begin
                        PaymentMapping.SetRange("External Payment Type");
                        PaymentMapping.FindFirst();
                    end;
                    if (SalesHeader."Payment Method Code" = '') and (PaymentMapping."Payment Method Code" <> '') then
                        SalesHeader.Validate("Payment Method Code", PaymentMapping."Payment Method Code");
                end;
            end;
        end;

        SalesHeader.Validate("Location Code", MagentoWebsite."Location Code");
        if MagentoWebsite.Code <> '' then begin
            SalesHeader.SetHideValidationDialog(true);
            if MagentoWebsite."Global Dimension 1 Code" <> '' then
                SalesHeader.Validate("Shortcut Dimension 1 Code", MagentoWebsite."Global Dimension 1 Code");
            if MagentoWebsite."Global Dimension 2 Code" <> '' then
                SalesHeader.Validate("Shortcut Dimension 2 Code", MagentoWebsite."Global Dimension 2 Code");
            SalesHeader.SetHideValidationDialog(false);
        end;
        SalesHeader.Validate("Currency Code", GetCurrencyCode(CopyStr(NpXmlDomMgt.GetElementCode(XmlElement, 'currency_code', MaxStrLen(SalesHeader."Currency Code"), false), 1, 10)));
        if SalesHeader."Currency Code" <> '' then begin
            CurrencyFactor := NpXmlDomMgt.GetElementDec(XmlElement, 'currency_factor', false);
            if CurrencyFactor > 0 then
                SalesHeader.Validate("Currency Factor", CurrencyFactor);
        end;

        SalesHeader.Modify(true);

        OnAfterInsertSalesHeader(CurrImportType, CurrImportEntry, XmlElement, SalesHeader);

    end;

    local procedure InsertSalesLines(XmlElement: XmlElement; SalesHeader: Record "Sales Header")
    var
        TempSalesLine: Record "Sales Line" temporary;
        XNodeList: XmlNodeList;
        XNode: XmlNode;
        LineNo: Integer;
    begin
        LineNo := 0;

        if XmlElement.SelectSingleNode('sales_order_lines', XNode) then begin
            XNode.SelectNodes('sales_order_line', XNodeList);
            foreach XNode in XNodeList do begin
                InsertSalesLine(XNode.AsXmlElement(), SalesHeader, LineNo);
            end;
        end;

        if XmlElement.SelectSingleNode('payments', XNode) then begin
            XNode.SelectNodes('payment_method', XNodeList);
            foreach XNode in XNodeList do begin
                InsertSalesLinePaymentFee(XNode.AsXmlElement(), SalesHeader, LineNo);
            end;
        end;

        if XmlElement.SelectSingleNode('shipment', XNode) then
            InsertSalesLineShipmentFee(XNode.AsXmlElement(), SalesHeader, LineNo);

        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 0);
        TempSalesLine.CalcVATAmountLines(0, SalesHeader, TempSalesLine, TempVATAmountLine);
        TempSalesLine.UpdateVATOnLines(0, SalesHeader, TempSalesLine, TempVATAmountLine);
    end;

    local procedure InsertSalesLine(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
    begin
        Initialize();
        case LowerCase(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'type', true)) of
            'comment':
                begin
                    InsertSalesLineComment(XmlElement, SalesHeader, LineNo);
                end;
            'item':
                begin
                    InsertSalesLineItem(XmlElement, SalesHeader, LineNo);
                end;
            'fee':
                begin
                    InsertSalesLineFee(XmlElement, SalesHeader, LineNo);
                end;
            'retail_voucher':
                begin
                    InsertSalesLineRetailVoucher(XmlElement, SalesHeader, LineNo);
                end;
            'custom_option':
                begin
                    InsertSalesLineCustomOption(XmlElement, SalesHeader, LineNo);
                end;
        end;

        if SalesLine.Get(SalesHeader."Document Type", SalesHeader."No.", LineNo) then
            OnAfterInsertSalesLine(CurrImportType, CurrImportEntry, XmlElement, SalesHeader, SalesLine);
    end;

    local procedure InsertSalesLineComment(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
    begin

        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        InsertSalesLine(SalesLine, SalesHeader, LineNo);
        SalesLine.Validate(Type, SalesLine.Type::" ");
        SalesLine.Description := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'description', MaxStrLen(SalesLine.Description), true), 1, MaxStrLen(SalesLine.Description));
        SalesLine.Modify(true);

    end;

    local procedure InsertSalesLineItem(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SalesLine: Record "Sales Line";
        Position: Integer;
        TableId: Integer;
        LineAmount: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        VatPct: Decimal;
        ExternalItemNo: Text;
        ItemNo: Code[20];
        UnitofMeasure: Code[10];
        VariantCode: Code[10];
        RequestedDeliveryDate: Date;
        ItemDescription: Text;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInsertSalesLineItem(XmlElement, SalesHeader, LineNo, IsHandled);
        if IsHandled then
            exit;
        ExternalItemNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'external_no', true);
        Position := StrPos(ExternalItemNo, '_');
        if Position = 0 then begin
            ItemNo := CopyStr(ExternalItemNo, 1, MaxStrLen(ItemNo));
            VariantCode := '';
        end else begin
            ItemNo := CopyStr(CopyStr(ExternalItemNo, 1, Position - 1), 1, MaxStrLen(ItemNo));
            VariantCode := CopyStr(CopyStr(ExternalItemNo, Position + 1), 1, MaxStrLen(VariantCode));
        end;
        if not Item.Get(ItemNo) then
            if not (TranslateBarcodeToItemVariant(CopyStr(ExternalItemNo, 1, 50), ItemNo, VariantCode, TableId)) then
                Error(Error002, ExternalItemNo, XmlElement.Name);

        if VariantCode <> '' then
            ItemVariant.Get(ItemNo, VariantCode);
        UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement, 'unit_price_incl_vat', true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement, 'line_amount_incl_vat', true);
        if not SalesHeader."Prices Including VAT" then begin
            UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement, 'unit_price_excl_vat', true);
            LineAmount := NpXmlDomMgt.GetElementDec(XmlElement, 'line_amount_excl_vat', true);
        end;
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement, 'quantity', true);
        VatPct := NpXmlDomMgt.GetElementDec(XmlElement, 'vat_percent', true);
        UnitofMeasure := CopyStr(NpXmlDomMgt.GetElementCode(XmlElement, 'unit_of_measure', MaxStrLen(SalesLine."Unit of Measure Code"), false), 1, MaxStrLen(UnitofMeasure));
        RequestedDeliveryDate := NpXmlDomMgt.GetElementDate(XmlElement, 'requested_delivery_date', false);

        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        InsertSalesLine(SalesLine, SalesHeader, LineNo);

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemNo);
        ItemDescription := NpXmlDomMgt.GetXmlText(XmlElement, 'description', MaxStrLen(SalesLine.Description), false);
        if ItemDescription <> '' then
            SalesLine.Description := CopyStr(ItemDescription, 1, MaxStrLen(SalesLine.Description));
        SalesLine."Variant Code" := VariantCode;
        if VariantCode <> '' then
            SalesLine."Description 2" := CopyStr(ItemVariant.Description, 1, MaxStrLen(SalesLine."Description 2"));
        SalesLine.Validate(Quantity, Quantity);

        if RequestedDeliveryDate <> 0D then
            SalesLine.Validate("Requested Delivery Date", RequestedDeliveryDate);

        if not (UnitofMeasure in ['', '_BLANK_']) then
            SalesLine.Validate("Unit of Measure Code", UnitofMeasure);
        if UnitPrice > 0 then
            SalesLine.Validate("Unit Price", UnitPrice)
        else
            SalesLine."Unit Price" := UnitPrice;
        SalesLine.Validate("VAT Prod. Posting Group");
        SalesLine.Validate("VAT %", VatPct);

        if SalesLine."Unit Price" <> 0 then
            SalesLine.Validate("Line Amount", LineAmount)
        else
            SalesLine."Line Amount" := LineAmount;
        SalesLine.Modify(true);

        CheckForAutomaticTransferOrder(SalesLine);
    end;

    procedure CheckForAutomaticTransferOrder(SalesLine: Record "Sales Line")
    var
        StockQty: Decimal;
        NeededQty: Decimal;
    begin
        MagentoSetup.Get();
        if not MagentoSetup."Auto Transfer Order Enabled" then
            exit;

        StockQty := CalcStockQtyNEW(SalesLine."No.", SalesLine."Variant Code", SalesLine."Location Code");

        if MagentoSetup."Include Projected Quantities" then
            StockQty += SalesLine.Quantity;

        if StockQty < 0 then
            StockQty := 0;

        NeededQty := StockQty - SalesLine.Quantity;
        if NeededQty < 0 then
            CreateTransferOrders(SalesLine, Abs(NeededQty));
    end;

    local procedure CalcStockQtyNEW(ItemNo: Code[20]; VariantFilter: Text; LocationFilter: Text): Decimal
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        VariantStockQty: Decimal;
        StockQty: Decimal;
    begin
        Item.Get(ItemNo);
        VariantFilter := UpperCase(VariantFilter);
        LocationFilter := UpperCase(LocationFilter);

        if VariantFilter <> '' then begin
            Item.SetFilter("Variant Filter", VariantFilter);
            Item.SetFilter("Location Filter", LocationFilter);
            exit(CalcInventory(Item));
        end;

        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet() then begin
            StockQty := 0;
            VariantStockQty := 0;
            repeat
                Item.SetFilter("Variant Filter", ItemVariant.Code);
                Item.SetFilter("Location Filter", LocationFilter);
                VariantStockQty := CalcInventory(Item);
                StockQty += VariantStockQty;
            until ItemVariant.Next() = 0;

            exit(StockQty);
        end;

        Item.SetFilter("Location Filter", LocationFilter);
        exit(CalcInventory(Item));
    end;

    local procedure CalcInventory(var Item: Record Item): Decimal
    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
        GrossRequirement: Decimal;
        PlannedOrderRcpt: Decimal;
        ScheduledRcpt: Decimal;
        PlannedOrderReleases: Decimal;
        ProjAvailableBalance: Decimal;
        ExpectedInventory: Decimal;
        QtyAvailable: Decimal;
    begin
        if MagentoSetup."Include Projected Quantities" then begin
            MagentoSetup.TestField("Projected. Qty. Within Period");
            Item.Setrange("Date Filter", 0D, CalcDate(MagentoSetup."Projected. Qty. Within Period", WorkDate()));
            ItemAvailFormsMgt.CalcAvailQuantities(Item, true, GrossRequirement, PlannedOrderRcpt, ScheduledRcpt, PlannedOrderReleases, ProjAvailableBalance, ExpectedInventory, QtyAvailable);
            exit(ProjAvailableBalance);
        end;

        Item.CalcFields(Inventory);
        exit(Item.Inventory);
    end;

    local procedure CreateTransferOrders(SalesLine: Record "Sales Line"; NeededQty: Decimal)
    var
        Item: Record Item;
        ReplenishmentTransferMapping: Record "NPR Ret. Repl. Transfer Mapp.";
        ReqWkshTemplate: Record "Req. Wksh. Template";
        RequisitionLine: Record "Requisition Line";
        AvailableQty: Decimal;
        LineNo: Integer;
        ReplTransferMappingCount: Integer;
    begin
        ReplenishmentTransferMapping.SetCurrentKey("To Location", Priority);
        ReplenishmentTransferMapping.SetRange("To Location", SalesLine."Location Code");
        ReplTransferMappingCount := ReplenishmentTransferMapping.Count();
        if (ReplTransferMappingCount = 0) and (not MagentoSetup."Auto Create Req. Lines") then
            Error(Error005, SalesLine."Location Code");

        if ReplTransferMappingCount > 0 then begin
            ReplenishmentTransferMapping.FindSet();
            repeat
                AvailableQty := CalcStockQtyNEW(SalesLine."No.", SalesLine."Variant Code", ReplenishmentTransferMapping."From Location");
                if AvailableQty > 0 then
                    if AvailableQty > NeededQty then begin
                        CreateTransferOrder(ReplenishmentTransferMapping."To Location", ReplenishmentTransferMapping."From Location", SalesLine."Document No.", SalesLine."No.", SalesLine."Variant Code", NeededQty);
                        NeededQty := 0;
                    end else begin
                        CreateTransferOrder(ReplenishmentTransferMapping."To Location", ReplenishmentTransferMapping."From Location", SalesLine."Document No.", SalesLine."No.", SalesLine."Variant Code", AvailableQty);
                        NeededQty -= AvailableQty;
                    end;
            until (ReplenishmentTransferMapping.Next() = 0) or (NeededQty = 0);
        end;

        if (NeededQty > 0) and MagentoSetup."Auto Create Req. Lines" then begin
            Item.Get(SalesLine."No.");
            If Item."Replenishment System" = Item."Replenishment System"::"Prod. Order" then
                exit;

            MagentoSetup.TestField("Req. Worsheet Template Code");
            MagentoSetup.TestField("Req. Worsheet Jnl. Batch Name");
            ReqWkshTemplate.Get(MagentoSetup."Req. Worsheet Template Code");

            RequisitionLine.SetRange("Worksheet Template Name", ReqWkshTemplate.Name);
            RequisitionLine.SetRange("Journal Batch Name", MagentoSetup."Req. Worsheet Jnl. Batch Name");
            if RequisitionLine.FindLast() then;
            LineNo := RequisitionLine."Line No." + 10000;

            RequisitionLine.SetRange(Type, RequisitionLine.Type::Item);
            RequisitionLine.SetRange("No.", SalesLine."No.");
            RequisitionLine.SetRange("Location Code", SalesLine."Location Code");
            RequisitionLine.SetRange("Variant Code", SalesLine."Variant Code");
            if RequisitionLine.FindFirst() then begin
                RequisitionLine.Validate(RequisitionLine.Quantity, RequisitionLine.Quantity + NeededQty);
                RequisitionLine.Modify();
            end else begin
                RequisitionLine.Init();
                RequisitionLine."Worksheet Template Name" := ReqWkshTemplate.Name;
                RequisitionLine."Journal Batch Name" := MagentoSetup."Req. Worsheet Jnl. Batch Name";
                RequisitionLine."Line No." := LineNo;
                RequisitionLine.Validate(Type, RequisitionLine.Type::Item);
                RequisitionLine.Validate("No.", SalesLine."No.");
                RequisitionLine.Validate("Location Code", SalesLine."Location Code");
                RequisitionLine.Validate("Variant Code", SalesLine."Variant Code");
                RequisitionLine.Validate(Quantity, NeededQty);
                RequisitionLine.Validate("Vendor No.", Item."Vendor No.");
                RequisitionLine."Vendor Item No." := Item."Vendor Item No.";
                RequisitionLine.Validate("Replenishment System", Item."Replenishment System");
                RequisitionLine.Insert();
            end;
        end;
    end;

    local procedure CreateTransferOrder(ToCode: Code[10]; FromCode: Code[10]; OrderNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[20]; NeededQty: Decimal)
    var
        TransferHeader: Record "Transfer Header";
        TransferLine: Record "Transfer Line";
        InvtSetup: Record "Inventory Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
        LineNo: Integer;
    begin
        TransferHeader.SetRange("Transfer-from Code", FromCode);
        TransferHeader.SetRange("Transfer-to Code", ToCode);
        TransferHeader.SetRange("External Document No.", OrderNo);
        if not TransferHeader.FindFirst() then begin
            InvtSetup.Get();
            InvtSetup.TestField("Transfer Order Nos.");
            TransferHeader.Init();
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            TransferHeader."No." := NoSeriesMgt.GetNextNo(InvtSetup."Transfer Order Nos.", WorkDate(), false);
#ELSE
            TransferHeader."No." := NoSeriesMgt.GetNextNo(InvtSetup."Transfer Order Nos.", WorkDate(), true);
#ENDIF
            TransferHeader.Validate("External Document No.", OrderNo);
            TransferHeader.Validate("Transfer-from Code", FromCode);
            TransferHeader.Validate("Transfer-to Code", ToCode);
            TransferHeader.Validate("Shipment Date", WorkDate());
            TransferHeader."Posting Date" := WorkDate();
            TransferHeader.Insert();
        end;

        TransferLine.SetRange("Document No.", TransferHeader."No.");
        if TransferLine.FindLast() then;
        LineNo := TransferLine."Line No." + 10000;

        TransferLine.SetRange("Item No.", ItemNo);
        TransferLine.SetRange("Variant Code", VariantCode);
        if not TransferLine.FindFirst() then begin
            TransferLine.Init();
            TransferLine."Document No." := TransferHeader."No.";
            TransferLine."Line No." := LineNo;
            TransferLine.Validate("Item No.", ItemNo);
            TransferLine.Validate(Quantity, NeededQty);
            TransferLine.Validate("Variant Code", VariantCode);
            TransferLine.Insert(true);
        end else begin
            TransferLine.Quantity += NeededQty;
            TransferLine.Modify(true);
        end;
        OnAfterInsertTransferOrder(TransferHeader, TransferLine);
    end;

    local procedure InsertSalesLineFee(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        SalesCommentLine: Record "Sales Comment Line";
        SalesLine: Record "Sales Line";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        LineAmount: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        VatPct: Decimal;
    begin
        Evaluate(Quantity, NpXmlDomMgt.GetXmlText(XmlElement, 'quantity', 0, true), 9);
        Evaluate(LineAmount, NpXmlDomMgt.GetXmlText(XmlElement, 'line_amount_incl_vat', 0, true), 9);
        if (Quantity = 0) and (LineAmount = 0) then begin
            LineNo += 10000;
            SalesCommentLine.Init();
            SalesCommentLine."Document Type" := SalesHeader."Document Type";
            SalesCommentLine."No." := SalesHeader."No.";
            SalesCommentLine."Document Line No." := 0;
            SalesCommentLine."Line No." := LineNo;
            SalesCommentLine.Date := Today();
            SalesCommentLine.Comment := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'description', MaxStrLen(SalesLine.Description), true), 1, MaxStrLen(SalesCommentLine.Comment));

            if SalesCommentLineExists(SalesHeader, LineNo) then begin
                LineNo := GetNextSalesCommentLineLineNo(SalesHeader);
                SalesCommentLine."Line No." := LineNo;
            end;
            SalesCommentLine.Insert(true);

        end else begin
            UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement, 'unit_price_incl_vat', true);
            VatPct := NpXmlDomMgt.GetElementDec(XmlElement, 'vat_percent', true);
            if not SalesHeader."Prices Including VAT" then
                UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement, 'unit_price_excl_vat', true);

            LineNo += 10000;
            SalesLine.Init();
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." := LineNo;
            InsertSalesLine(SalesLine, SalesHeader, LineNo);
            ShipmentMapping.SetRange("External Shipment Method Code", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'external_no', false));
            ShipmentMapping.FindFirst();

            case ShipmentMapping."Shipment Fee Type" of
                ShipmentMapping."Shipment Fee Type"::"G/L Account":
                    begin
                        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                    end;
                ShipmentMapping."Shipment Fee Type"::Item:
                    begin
                        SalesLine.Validate(Type, SalesLine.Type::Item);
                    end;
                ShipmentMapping."Shipment Fee Type"::Resource:
                    begin
                        SalesLine.Validate(Type, SalesLine.Type::Resource);
                    end;
                ShipmentMapping."Shipment Fee Type"::"Fixed Asset":
                    begin
                        SalesLine.Validate(Type, SalesLine.Type::"Fixed Asset");
                    end;
                ShipmentMapping."Shipment Fee Type"::"Charge (Item)":
                    begin
                        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
                    end;
            end;

            SalesLine.Validate("No.", ShipmentMapping."Shipment Fee No.");
            if Quantity <> 0 then
                SalesLine.Validate(Quantity, Quantity);

            SalesLine.Validate("VAT %", VatPct);

            SalesLine.Validate("Unit Price", UnitPrice);
            SalesLine.Description := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'description', MaxStrLen(SalesLine.Description), true), 1, MaxStrLen(SalesLine.Description));
            if ShipmentMapping.Description <> '' then
                Salesline.Description := ShipmentMapping.Description;

            SalesLine.Modify(true);
        end;
    end;

    local procedure SalesCommentLineExists(SalesHeader: Record "Sales Header"; LineNo: Integer): Boolean
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        SalesCommentLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesCommentLine.SetRange("No.", SalesHeader."No.");
        SalesCommentLine.SetRange("Line No.", LineNo);
        Exit(not SalesCommentLine.IsEmpty());
    end;

    local procedure GetNextSalesCommentLineLineNo(SalesHeader: Record "Sales Header"): Integer
    var
        SalesCommentLine: Record "Sales Comment Line";
    begin
        SalesCommentLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesCommentLine.SetRange("No.", SalesHeader."No.");
        if SalesCommentLine.FindLast() then
            Exit(SalesCommentLine."Line No." + 10000);
    end;

    local procedure InsertSalesLineRetailVoucher(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        SalesLine: Record "Sales Line";
        NpRvGlobalVoucherWebservice: Codeunit "NPR NpRv Global Voucher WS";
        ReferenceNo: Text;
        LineAmount: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        VatPct: Decimal;
        PrevRec: Text;
    begin
        ReferenceNo := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'external_no', true), 1, MaxStrLen(NpRvVoucher."Reference No."));

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("External Document No.", SalesHeader."NPR External Order No.");
        NpRvSalesLine.SetRange("Reference No.", ReferenceNo);
        NpRvSalesLine.SetFilter(Type, '%1|%2', NpRvSalesLine.Type::"New Voucher", NpRvSalesLine.Type::"Top-up");
        if not NpRvSalesLine.FindFirst() then begin
            if NpRvGlobalVoucherWebservice.FindVoucher('', CopyStr(ReferenceNo, 1, 50), NpRvVoucher) then begin
                NpRvSalesLine.Init();
                NpRvSalesLine.Id := CreateGuid();
                NpRvSalesLine."External Document No." := SalesHeader."NPR External Order No.";
                NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
                NpRvSalesLine."Document Type" := SalesHeader."Document Type";
                NpRvSalesLine."Document No." := SalesHeader."No.";
                NpRvSalesLine.Type := NpRvSalesLine.Type::"Top-up";
                NpRvSalesLine."Voucher Type" := NpRvVoucher."Voucher Type";
                NpRvSalesLine."Voucher No." := NpRvVoucher."No.";
                NpRvSalesLine."Reference No." := NpRvVoucher."Reference No.";
                NpRvSalesLine.Description := NpRvVoucher.Description;
                NpRvSalesLine.Insert(true);
            end;
        end;
        NpRvSalesLine.FindFirst();
        NpRvVoucherType.Get(NpRvSalesLine."Voucher Type");
        NpRvVoucherType.TestField("Account No.");
        if (NpRvSalesLine."Voucher No." <> '') and NpRvVoucher.Get(NpRvSalesLine."Voucher No.") then begin
            NpRvVoucher.CalcFields("Issue Date");
            if (NpRvVoucher."Issue Date" <> 0D) then
                NpRvVoucher.TestField("Allow Top-up");

            if NpRvVoucher."Account No." <> '' then
                NpRvVoucherType."Account No." := NpRvVoucher."Account No.";
        end;

        Quantity := NpXmlDomMgt.GetElementDec(XmlElement, 'quantity', true);
        UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement, 'unit_price_incl_vat', true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement, 'line_amount_incl_vat', true);
        if not SalesHeader."Prices Including VAT" then begin
            UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement, 'unit_price_excl_vat', true);
            LineAmount := NpXmlDomMgt.GetElementDec(XmlElement, 'line_amount_excl_vat', true);
        end;
        VatPct := NpXmlDomMgt.GetElementDec(XmlElement, 'vat_percent', true);

        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        InsertSalesLine(SalesLine, SalesHeader, LineNo);

        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", NpRvVoucherType."Account No.");
        SalesLine.Description := NpRvSalesLine.Description;
        SalesLine.Validate(Quantity, Quantity);
        SalesLine.Validate("VAT %", VatPct);
        SalesLine.Validate("Unit Price", UnitPrice);
        if SalesLine."Unit Price" <> 0 then
            SalesLine.Validate("Line Amount", LineAmount);
        SalesLine.Modify(true);

        PrevRec := Format(NpRvSalesLine);

        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."Document Type" := SalesLine."Document Type";
        NpRvSalesLine."Document No." := SalesLine."Document No.";
        NpRvSalesLine."Document Line No." := SalesLine."Line No.";

        if PrevRec <> Format(NpRvSalesLine) then
            NpRvSalesLine.Modify(true);
    end;

    local procedure InsertSalesLinePaymentFee(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        PaymentFee: Decimal;
    begin
        if not Evaluate(PaymentFee, NpXmlDomMgt.GetXmlText(XmlElement, 'payment_fee', 0, false), 9) then
            exit;
        if PaymentFee = 0 then
            exit;

        Initialize();
        MagentoSetup.TestField("Payment Fee Account No.");

        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        InsertSalesLine(SalesLine, SalesHeader, LineNo);

        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", MagentoSetup."Payment Fee Account No.");
        SalesLine.Validate("Unit Price", PaymentFee);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineShipmentFee(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        ShipmentFee: Decimal;
    begin
        if not Evaluate(ShipmentFee, NpXmlDomMgt.GetXmlText(XmlElement, 'shipment_fee', 0, false), 9) then
            exit;
        if ShipmentFee = 0 then
            exit;

        ShipmentMapping.SetRange("External Shipment Method Code", NpXmlDomMgt.GetXmlText(XmlElement, 'shipment_method', MaxStrLen(ShipmentMapping."External Shipment Method Code"), true));
        ShipmentMapping.FindFirst();
        ShipmentMapping.TestField("Shipment Fee No.");

        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        InsertSalesLine(SalesLine, SalesHeader, LineNo);

        case ShipmentMapping."Shipment Fee Type" of
            ShipmentMapping."Shipment Fee Type"::"G/L Account":
                begin
                    SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                end;
            ShipmentMapping."Shipment Fee Type"::Item:
                begin
                    SalesLine.Validate(Type, SalesLine.Type::Item);
                end;
            ShipmentMapping."Shipment Fee Type"::Resource:
                begin
                    SalesLine.Validate(Type, SalesLine.Type::Resource);
                end;
            ShipmentMapping."Shipment Fee Type"::"Fixed Asset":
                begin
                    SalesLine.Validate(Type, SalesLine.Type::"Fixed Asset");
                end;
            ShipmentMapping."Shipment Fee Type"::"Charge (Item)":
                begin
                    SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
                end;
        end;
        SalesLine.Validate("No.", ShipmentMapping."Shipment Fee No.");
        SalesLine.Validate("Unit Price", ShipmentFee);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineCustomOption(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        MagentoCustomOption: Record "NPR Magento Custom Option";
        MagentoCustomOptionValue: Record "NPR Magento Custom Optn. Value";
        SalesLine: Record "Sales Line";
        Position: Integer;
        Position2: Integer;
        LineAmount: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        VatPct: Decimal;
        SalesType: Enum "Sales Line Type";
        CustomOptionTxt: Text;
        CustomOptionNo: Code[20];
        CustomOptionLineNo: Integer;
        SalesNo: Code[20];
        UnitofMeasure: Code[10];
        ExternalItemNo: Text;
    begin
        ExternalItemNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'external_no', true);
        Position := StrPos(ExternalItemNo, '#');
        CustomOptionLineNo := 0;
        if Position = 0 then
            CustomOptionTxt := ExternalItemNo
        else
            CustomOptionTxt := CopyStr(ExternalItemNo, Position + 1);

        Position2 := StrPos(CustomOptionTxt, '_');

        if Position2 <> 0 then begin
            CustomOptionNo := CopyStr(CopyStr(CustomOptionTxt, 1, Position2 - 1), 1, MaxStrLen(CustomOptionNo));
            Evaluate(CustomOptionLineNo, CopyStr(CustomOptionTxt, Position2 + 1), 9);
        end else
            CustomOptionNo := CopyStr(CustomOptionTxt, 1, MaxStrLen(MagentoCustomOption."No."));

        MagentoCustomOption.Get(CustomOptionNo);

        case MagentoCustomOption.Type of
            MagentoCustomOption.Type::SelectCheckbox, MagentoCustomOption.Type::SelectDropDown,
            MagentoCustomOption.Type::SelectMultiple, MagentoCustomOption.Type::SelectRadioButtons:
                begin
                    MagentoCustomOptionValue.Get(CustomOptionNo, CustomOptionLineNo);
                    MagentoCustomOptionValue.TestField("Sales No.");
                    SalesType := MagentoCustomOptionValue."Sales Type";
                    SalesNo := MagentoCustomOptionValue."Sales No.";
                end;
            else begin
                MagentoCustomOption.TestField("Sales No.");
                SalesType := MagentoCustomOption."Sales Type";
                SalesNo := MagentoCustomOption."Sales No.";
            end;
        end;

        UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement, 'unit_price_incl_vat', true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement, 'line_amount_incl_vat', true);
        if not SalesHeader."Prices Including VAT" then begin
            UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement, 'unit_price_excl_vat', true);
            LineAmount := NpXmlDomMgt.GetElementDec(XmlElement, 'line_amount_excl_vat', true);
        end;
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement, 'quantity', true);
        VatPct := NpXmlDomMgt.GetElementDec(XmlElement, 'vat_percent', true);
        UnitofMeasure := CopyStr(NpXmlDomMgt.GetElementCode(XmlElement, 'unit_of_measure', MaxStrLen(SalesLine."Unit of Measure Code"), false), 1, MaxStrLen(UnitofMeasure));

        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        InsertSalesLine(SalesLine, SalesHeader, LineNo);

        SalesLine.Validate(Type, SalesType);
        SalesLine.Validate("No.", SalesNo);
        SalesLine.Description := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'description', MaxStrLen(SalesLine.Description), true), 1, MaxStrLen(SalesLine.Description));
        SalesLine."Description 2" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'description_2', MaxStrLen(SalesLine.Description), false), 1, MaxStrLen(SalesLine."Description 2"));
        SalesLine.Validate(Quantity, Quantity);
        if not (UnitofMeasure in ['', '_BLANK_']) then
            SalesLine.Validate("Unit of Measure Code", UnitofMeasure);
        if UnitPrice > 0 then
            SalesLine.Validate("Unit Price", UnitPrice)
        else
            SalesLine."Unit Price" := UnitPrice;
        SalesLine.Validate("VAT Prod. Posting Group");
        SalesLine.Validate("VAT %", VatPct);

        if SalesLine."Unit Price" <> 0 then
            SalesLine.Validate("Line Amount", LineAmount)
        else
            SalesLine."Line Amount" := LineAmount;
        SalesLine.Modify(true);
    end;

    local procedure InsertPaymentLine(var PaymentLine: Record "NPR Magento Payment Line"; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    begin
        if PaymentLineExists(SalesHeader, LineNo) then begin
            LineNo := GetNextPaymentLineLineNo(SalesHeader);
            PaymentLine."Line No." := LineNo;
        end;

        PaymentLine.Insert(true);
    end;

    local procedure PaymentLineExists(SalesHeader: Record "Sales Header"; LineNo: Integer): Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Line No.", LineNo);
        Exit(not PaymentLine.IsEmpty());
    end;

    local procedure GetNextPaymentLineLineNo(SalesHeader: Record "Sales Header"): Integer
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        if PaymentLine.FindLast() then
            Exit(PaymentLine."Line No." + 10000);
    end;

    local procedure InsertSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    begin
        if SalesLineExists(SalesHeader, LineNo) then begin
            LineNo := GetNextSalesLineLineNo(SalesHeader);
            SalesLine."Line No." := LineNo;
        end;

        SalesLine.Insert(true);
    end;

    local procedure SalesLineExists(SalesHeader: Record "Sales Header"; LineNo: Integer): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Line No.", LineNo);
        Exit(not SalesLine.IsEmpty());
    end;

    local procedure GetNextSalesLineLineNo(SalesHeader: Record "Sales Header"): Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.FindLast() then
            Exit(SalesLine."Line No." + 10000);
    end;

    local procedure UpdateExtCouponReservations(SalesHeader: Record "Sales Header")
    var
        NpDcExtCouponReservation: Record "NPR NpDc Ext. Coupon Reserv.";
    begin
        NpDcExtCouponReservation.SetRange("External Document No.", SalesHeader."NPR External Order No.");
        NpDcExtCouponReservation.SetFilter("Document No.", '=%1', '');
        if NpDcExtCouponReservation.FindFirst() then begin
            NpDcExtCouponReservation.ModifyAll("Document Type", SalesHeader."Document Type");
            NpDcExtCouponReservation.ModifyAll("Document No.", SalesHeader."No.");
        end;
    end;

    local procedure UpdateRetailVoucherCustomerInfo(SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLinePrev: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.SetRange("External Document No.", SalesHeader."NPR External Order No.");
        NpRvSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesHeader."No.");
        if not NpRvSalesLine.FindSet() then
            exit;

        repeat
            NpRvSalesLinePrev := NpRvSalesLine;

            NpRvSalesLine."Customer No." := SalesHeader."Sell-to Customer No.";
            case MagentoSetup."E-mail Retail Vouchers to" of
                MagentoSetup."E-mail Retail Vouchers to"::" ":
                    begin
                        NpRvSalesLine."E-mail" := NpRvSalesLinePrev."E-mail";
                        NpRvSalesLine."Phone No." := NpRvSalesLinePrev."Phone No.";
                    end;
                MagentoSetup."E-mail Retail Vouchers to"::"Bill-to Customer":
                    begin
                        Customer.Get(SalesHeader."Bill-to Customer No.");
                        NpRvSalesLine."E-mail" := Customer."E-Mail";
                        NpRvSalesLine."Phone No." := Customer."Phone No.";
                        ;
                    end;
            end;

            if Format(NpRvSalesLinePrev) <> Format(NpRvSalesLine) then
                NpRvSalesLine.Modify(true);
        until NpRvSalesLine.Next() = 0;

    end;

    local procedure SendOrderConfirmation(XmlElement: XmlElement; var SalesHeader: Record "Sales Header") MailErrorMessage: Text
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        ReportSelections: Record "Report Selections";
        EmailMgt: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
        RecID: RecordId;
        RecipientEmail: Text;
    begin

        RecipientEmail := NpXmlDomMgt.GetXmlText(XmlElement, 'sell_to_customer/email', 0, true);
        MagentoSetup.TestField("E-mail Template (Order Conf.)");
        EmailTemplateHeader.Get(MagentoSetup."E-mail Template (Order Conf.)");
        RecRef.GetTable(SalesHeader);
        RecRef.SetRecFilter();
        if EmailTemplateHeader."Report ID" <= 0 then begin
            ReportSelections.SetRange(Usage, ReportSelections.Usage::"S.Order");
            ReportSelections.SetFilter("Report ID", '>%1', 0);
            ReportSelections.FindFirst();
            EmailTemplateHeader."Report ID" := ReportSelections."Report ID";
        end;
        MailErrorMessage := EmailMgt.SendReportTemplate(EmailTemplateHeader."Report ID", RecRef, EmailTemplateHeader, CopyStr(RecipientEmail, 1, 250), true);
        RecID := RecRef.RecordId();
        SalesHeader.Get(RecID);
        exit(MailErrorMessage);
    end;

    local procedure PostOnImport(SalesHeader: Record "Sales Header")
    var
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        IsHandled: Boolean;
    begin
        OnBeforePostOnImport(SalesHeader, IsHandled);
        if IsHandled then
            exit;

        if MagentoSetup."Prevent posting if commented" and OrderHasComments then
            exit;

        if not HasLinesToPostOnImport(SalesHeader) then
            exit;

        if SalesHeader.Status <> SalesHeader.Status::Open then
            ReleaseSalesDoc.PerformManualReopen(SalesHeader);

        ResetSalesLines(SalesHeader);

        MarkLinesForPosting(SalesHeader);
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);
        OnAfterPostOnImport(SalesHeader);
    end;

    local procedure HasLinesToPostOnImport(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
    begin

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '<>%1', 0);
        if SalesLine.FindSet() then
            repeat
                if IsLineToPost(SalesLine) then
                    exit(true);
            until SalesLine.Next() = 0;

        exit(false);
    end;

    local procedure IsLineToPost(SalesLine: Record "Sales Line"): Boolean
    begin
        if MagentoSetup."Post Retail Vouchers on Import" then begin
            if IsRetailVoucherLine(SalesLine) then
                exit(true);
        end;

        if MagentoSetup."Post Tickets on Import" then begin
            if IsTicketLine(SalesLine) then
                exit(true);
        end;

        if MagentoSetup."Post Memberships on Import" then begin
            if IsMembershipLine(SalesLine) then
                exit(true);
        end;

        if HasPostOnImportSetup(SalesLine) then
            exit(true);

        exit(false);
    end;

    local procedure IsRetailVoucherLine(SalesLine: Record "Sales Line"): Boolean
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin

        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("Document Type", SalesLine."Document Type");
        NpRvSalesLine.SetRange("Document No.", SalesLine."Document No.");
        NpRvSalesLine.SetRange("Document Line No.", SalesLine."Line No.");
        exit(NpRvSalesLine.FindFirst());

    end;

    local procedure IsTicketLine(SalesLine: Record "Sales Line"): Boolean
    var
        Item: Record Item;
    begin

        if SalesLine.Type <> SalesLine.Type::Item then
            exit(false);

        if not Item.Get(SalesLine."No.") then
            exit(false);

        exit(Item."NPR Ticket Type" <> '');
    end;

    local procedure IsMembershipLine(SalesLine: Record "Sales Line"): Boolean
    var
        MMMembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MMMembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    begin
        case SalesLine.Type of
            SalesLine.Type::"G/L Account":
                begin
                    if MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ACCOUNT, SalesLine."No.") then
                        exit(true);
                end;
            SalesLine.Type::Item:
                begin
                    if MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ITEM, SalesLine."No.") then
                        exit(true);

                    MMMembershipAlterationSetup.SetRange("Sales Item No.", SalesLine."No.");
                    if MMMembershipAlterationSetup.FindFirst() then
                        exit(true);
                end;
        end;
        exit(false)
    end;

    local procedure HasPostOnImportSetup(SalesLine: Record "Sales Line"): Boolean
    var
        MagentoPostonImportSetup: Record "NPR Magento PostOnImport Setup";
    begin

        if SalesLine.Type = SalesLine.Type::" " then
            exit;

        exit(MagentoPostonImportSetup.Get(SalesLine.Type, SalesLine."No."));

    end;

    local procedure ResetSalesLines(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        PrevRec: Text;
    begin

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '<>%1', 0);
        if SalesLine.FindSet() then
            repeat
                PrevRec := Format(SalesLine);

                SalesLine.Validate("Qty. to Ship", 0);
                SalesLine.Validate("Qty. to Invoice", 0);

                if PrevRec <> Format(SalesLine) then
                    SalesLine.Modify(true);
            until SalesLine.Next() = 0;
    end;

    local procedure MarkLinesForPosting(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
        PrevRec: Text;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '<>%1', 0);
        if SalesLine.FindSet() then
            repeat
                if IsLineToPost(SalesLine) then begin
                    PrevRec := Format(SalesLine);

                    SalesLine.Validate("Qty. to Ship", SalesLine."Outstanding Quantity");

                    if PrevRec <> Format(SalesLine) then
                        SalesLine.Modify(true);
                end;
            until SalesLine.Next() = 0;

        exit(false);
    end;

    local procedure GetContactCustomer(ContactNo: Code[20]; var Customer: Record Customer): Boolean
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
    begin
        Initialize();
        Clear(Contact);

        if not Contact.Get(ContactNo) then
            exit(false);

        ContBusRel.SetRange("Contact No.", Contact."Company No.");
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
        ContBusRel.SetFilter("No.", '<>%1', '');
        if not ContBusRel.FindFirst() then
            exit(false);

        exit(Customer.Get(ContBusRel."No."));
    end;

    local procedure GetCustomer(ExternalCustomerNo: Code[20]; XmlElement: XmlElement; var Customer: Record Customer) Found: Boolean
    var
        CustNo: Code[20];
    begin
        Clear(Customer);
        OnBeforeGetCustomer(CurrImportType, CurrImportEntry, ExternalCustomerNo, XmlElement, Customer, Found);
        if Found then
            exit(Customer.Find());
        Initialize();
        Clear(Customer);
        case MagentoSetup."Customer Mapping" of
            MagentoSetup."Customer Mapping"::"E-mail":
                begin
                    Customer.SetRange("E-Mail", NpXmlDomMgt.GetXmlText(XmlElement, 'email', MaxStrLen(Customer."E-Mail"), false));
                    exit(Customer.FindFirst() and (Customer."E-Mail" <> ''));
                end;
            MagentoSetup."Customer Mapping"::"Phone No.":
                begin
                    Customer.SetRange("Phone No.", NpXmlDomMgt.GetXmlText(XmlElement, 'phone', MaxStrLen(Customer."Phone No."), false));
                    exit(Customer.FindFirst() and (Customer."Phone No." <> ''));
                end;
            MagentoSetup."Customer Mapping"::"E-mail AND Phone No.":
                begin
                    Customer.SetRange("E-Mail", NpXmlDomMgt.GetXmlText(XmlElement, 'email', MaxStrLen(Customer."E-Mail"), false));
                    Customer.SetRange("Phone No.", NpXmlDomMgt.GetXmlText(XmlElement, 'phone', MaxStrLen(Customer."Phone No."), false));
                    exit(Customer.FindFirst() and (Customer."E-Mail" <> '') and (Customer."Phone No." <> ''));
                end;
            MagentoSetup."Customer Mapping"::"E-mail OR Phone No.":
                begin
                    Customer.SetRange("E-Mail", NpXmlDomMgt.GetXmlText(XmlElement, 'email', MaxStrLen(Customer."E-Mail"), false));
                    if Customer.FindFirst() and (Customer."E-Mail" <> '') then
                        exit(true);

                    Clear(Customer);
                    Customer.SetRange("Phone No.", NpXmlDomMgt.GetXmlText(XmlElement, 'phone', MaxStrLen(Customer."Phone No."), false));
                    exit(Customer.FindFirst() and (Customer."Phone No." <> ''));
                end;
            MagentoSetup."Customer Mapping"::"Customer No.":
                begin
                    CustNo := CopyStr(NpXmlDomMgt.GetAttributeCode(XmlElement, '', 'customer_no', MaxStrLen(Customer."No."), false), 1, MaxStrLen(CustNo));
                    if CustNo = '' then
                        exit(false);
                    exit(Customer.Get(CustNo));
                end;
            MagentoSetup."Customer Mapping"::"Phone No. to Customer No.":
                begin
                    CustNo := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'phone', MaxStrLen(Customer."No."), false), 1, MaxStrLen(CustNo));
                    if CustNo = '' then
                        exit(false);

                    exit(Customer.Get(CustNo));
                end;
        end;

        exit(false);
    end;

    local procedure GetCurrencyCode(CurrencyCode: Code[10]): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        Initialize();

        if not MagentoSetup."Use Blank Code for LCY" then
            exit(CurrencyCode);

        GLSetup.Get();
        if GLSetup."LCY Code" = CurrencyCode then
            exit('');

        exit(CurrencyCode);
    end;

    local procedure OrderExists(XmlElement: XmlElement): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesInvHeader: Record "Sales Invoice Header";
        OrderNo: Code[20];
    begin
        OrderNo := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'order_no', true), 1, MaxStrLen(OrderNo));
        if OrderNo = '' then
            exit(true);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("NPR External Order No.", CopyStr(OrderNo, 1, MaxStrLen(SalesHeader."NPR External Order No.")));
        if SalesHeader.FindFirst() then
            exit(true);

        SalesInvHeader.SetRange("NPR External Order No.", CopyStr(OrderNo, 1, MaxStrLen(SalesInvHeader."NPR External Order No.")));
        if SalesInvHeader.FindFirst() then
            exit(true);

        exit(false);
    end;

    local procedure InitCustomer(XmlElement: XmlElement; var Cust: Record Customer; MagentoWebsite: Record "NPR Magento Website")
    var
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesMgt: Codeunit "No. Series";
#ELSE
        NoSeriesMgt: Codeunit NoSeriesManagement;
#ENDIF
    begin
        Initialize();

        Cust.Init();
        Cust."No." := '';
        case MagentoSetup."Customer Mapping" of
            MagentoSetup."Customer Mapping"::"Customer No.":
                begin
                    Cust."No." := CopyStr(NpXmlDomMgt.GetAttributeCode(XmlElement, '', 'customer_no', MaxStrLen(Cust."No."), false), 1, MaxStrLen(Cust."No."));
                end;
            MagentoSetup."Customer Mapping"::"Phone No. to Customer No.":
                begin
                    Cust."No." := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'phone', MaxStrLen(Cust."No."), false), 1, MaxStrLen(Cust."No."));
                end;
            else begin
                if MagentoWebsite."Customer No. Series" <> '' then begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                    Cust."No. Series" := MagentoWebsite."Customer No. Series";
                    Cust."No." := NoSeriesMgt.GetNextNo(Cust."No. Series");
#ELSE
                    NoSeriesMgt.InitSeries(MagentoWebsite."Customer No. Series", Cust."No. Series", Today(), Cust."No.", Cust."No. Series");
#ENDIF
                end;
            end;
        end;
    end;

    local procedure SetFieldText(var RecRef: RecordRef; FieldNo: Integer; Value: Text)
    var
        "Field": Record "Field";
        FieldObsolete: Record "Field";
        RecRefObsolete: RecordRef;
        FieldRef: FieldRef;
        FieldRefObsolete: FieldRef;
    begin
        if not Field.Get(RecRef.Number, FieldNo) then
            exit;

        RecRefObsolete.GetTable(Field);
        if FieldObsolete.Get(RecRefObsolete.Number, 25) then begin
            FieldRefObsolete := RecRefObsolete.Field(25);
            if Format(FieldRefObsolete.Value, 0, 2) <> '0' then
                exit;
        end;
        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Value := Value;
    end;

    internal procedure Initialize()
    begin
        if not Initialized then begin
            MagentoSetup.Get();
            Initialized := true;
        end;
    end;

    local procedure TranslateBarcodeToItemVariant(Barcode: Text[50]; var ItemNo: Code[20]; var VariantCode: Code[10]; var ResolvingTable: Integer): Boolean
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
    begin
        ResolvingTable := 0;
        ItemNo := '';
        VariantCode := '';
        if (Barcode = '') then exit(false);

        // Try Item Table
        if (StrLen(Barcode) <= MaxStrLen(Item."No.")) then begin
            if (Item.Get(UpperCase(Barcode))) then begin
                ResolvingTable := DATABASE::Item;
                ItemNo := Item."No.";
                exit(true);
            end;
        end;

        if (StrLen(Barcode) <= MaxStrLen(ItemReference."Reference No.")) then begin
            ItemReference.SetCurrentKey("Reference Type", "Reference No.");
            ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetFilter("Reference No.", '=%1', UpperCase(Barcode));
            if ItemReference.FindFirst() then begin
                ResolvingTable := DATABASE::"Item Reference";
                ItemNo := ItemReference."Item No.";
                VariantCode := ItemReference."Variant Code";
                exit(true);
            end;
        end;

    end;

    local procedure GetDate(Date1: Date; Date2: Date): Date
    begin
        if Date1 <> 0D then
            exit(Date1);
        if Date2 <> 0D then
            exit(Date2);
        exit(WorkDate());
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetCustomer(ImportType: Record "NPR Nc Import Type"; ImportEntry: Record "NPR Nc Import Entry"; ExternalCustomerNo: Code[20]; Element: XmlElement; var Customer: Record Customer; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyCustomer(ImportType: Record "NPR Nc Import Type"; ImportEntry: Record "NPR Nc Import Entry"; Element: XmlElement; var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesHeader(ImportType: Record "NPR Nc Import Type"; ImportEntry: Record "NPR Nc Import Entry"; Element: XmlElement; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesHeader(ImportType: Record "NPR Nc Import Type"; ImportEntry: Record "NPR Nc Import Entry"; Element: XmlElement; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSalesLine(ImportType: Record "NPR Nc Import Type"; ImportEntry: Record "NPR Nc Import Entry"; Element: XmlElement; var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertCommentLine(ImportType: Record "NPR Nc Import Type"; ImportEntry: Record "NPR Nc Import Entry"; Element: XmlElement; var SalesHeader: Record "Sales Header"; var RecordLink: Record "Record Link")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRelease(ImportType: Record "NPR Nc Import Type"; ImportEntry: Record "NPR Nc Import Entry"; Element: XmlElement; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCommit(ImportType: Record "NPR Nc Import Type"; ImportEntry: Record "NPR Nc Import Entry"; Element: XmlElement; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitSendToStoreDocument(SalesHeader: Record "Sales Header"; NpCsStore: Record "NPR NpCs Store"; NpCsWorkflow: Record "NPR NpCs Workflow"; var NpCsDocument: Record "NPR NpCs Document")
    begin

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertTransferOrder(var TransferHeader: Record "Transfer Header"; var TransferLine: Record "Transfer Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertSalesLineItem(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostOnImport(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostOnImport(var SalesHeader: Record "Sales Header")
    begin
    end;

}

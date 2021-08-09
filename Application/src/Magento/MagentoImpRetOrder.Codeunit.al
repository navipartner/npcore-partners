codeunit 6151420 "NPR Magento Imp. Ret. Order"
{
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: XmlDocument;
    begin
        if Rec.LoadXmlDoc(XmlDoc) then
            ImportSalesReturnOrders(XmlDoc);
    end;

    var
        MagentoSetup: Record "NPR Magento Setup";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        MagentoMgt: Codeunit "NPR Magento Mgt.";
        NpXmlDomMgt: Codeunit "NPR NpXml Dom Mgt.";
        SalesPost: Codeunit "Sales-Post";
        Initialized: Boolean;
        Error001: Label 'Xml Element sell_to_customer is missing';
        Error002: Label 'Item %1 does not exist in %2';

    local procedure ImportSalesReturnOrders(XmlDoc: XmlDocument)
    var
        XmlNodeVar: XmlNode;
        XmlNodeList: XmlNodeList;
    begin
        Initialize();
        if not XmlDoc.SelectNodes('.//*[local-name()="sales_return_order"]', XmlNodeList) then
            exit;
        foreach XmlNodeVar in XmlNodeList do begin
            if XmlNodeVar.IsXmlElement() then
                ImportSalesReturnOrder(XmlNodeVar.AsXmlElement());
        end;
    end;

    local procedure ImportSalesReturnOrder(XmlElement: XmlElement): Boolean
    var
        SalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        if XmlElement.IsEmpty then
            exit(false);
        if OrderExists(XmlElement) then
            exit(false);

        InsertSalesHeader(XmlElement, SalesHeader);
        InsertSalesLines(XmlElement, SalesHeader);
        InsertPaymentLines(XmlElement, SalesHeader);
        InsertComments(XmlElement, SalesHeader);
        if MagentoSetup."Release Order on Import" then
            ReleaseSalesDoc.PerformManualRelease(SalesHeader);

        exit(true);
    end;

    #region Database
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
        end;
    end;

    local procedure InsertComments(XmlElement: XmlElement; var SalesHeader: Record "Sales Header")
    var
        Node: XmlNode;
        XmlNodeList: XmlNodeList;
    begin
        XmlElement.SelectNodes('.//*[local-name()="comment_line"]', XmlNodeList);
        foreach Node in XmlNodeList do begin
            InsertCommentLine(Node.AsXmlElement(), SalesHeader);
        end;
    end;

    local procedure InsertCustomer(XmlElement: XmlElement; IsContactCustomer: Boolean; var Customer: Record Customer): Boolean
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        CustTemplate: Record "Customer Templ.";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        ExternalCustomerNo: Text;
        TaxClass: Text;
        ConfigTemplateCode: Code[10];
        VATBusPostingGroup: Code[20];
        NewCust: Boolean;
        PrevCust: Text;
        CustTemplateCode: Code[20];
    begin
        Initialize();
        ExternalCustomerNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'customer_no', false);
        if IsContactCustomer then begin
            if GetContactCustomer(CopyStr(ExternalCustomerNo, 1, 20), Customer) then
                exit;
        end;

        TaxClass := NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'tax_class', true);
        NewCust := not GetCustomer(XmlElement, Customer);
        if NewCust then begin
            VATBusPostingGroup := MagentoMgt.GetVATBusPostingGroup(TaxClass);

            Customer.Init();
            Customer."No." := '';
            Customer."NPR External Customer No." := CopyStr(ExternalCustomerNo, 1, MaxStrLen(Customer."NPR External Customer No."));
            Customer.Insert(true);
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
            end else begin
                Customer.Validate("Gen. Bus. Posting Group", VATBusPostingGroup);
                Customer.Validate("VAT Bus. Posting Group", VATBusPostingGroup);
                Customer.Validate("Customer Posting Group", MagentoSetup."Customer Posting Group");
                Customer.Validate("Payment Terms Code", MagentoSetup."Payment Terms Code");
            end;
        end;
        PrevCust := Format(Customer);

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
        Customer.City := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'city', MaxStrLen(Customer.City), true), 1, MaxStrLen(Customer.City));
        Customer."Country/Region Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(XmlElement, 'country_code', MaxStrLen(Customer."Country/Region Code"), false)), 1, MaxStrLen(Customer."Country/Region Code"));
        Customer.Contact := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'contact', MaxStrLen(Customer.Contact), false), 1, MaxStrLen(Customer.Contact));
        Customer."E-Mail" := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'email', MaxStrLen(Customer."E-Mail"), true), 1, MaxStrLen(Customer."E-Mail"));
        Customer."Phone No." := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'phone', MaxStrLen(Customer."Phone No."), false), 1, MaxStrLen(Customer."Phone No."));
        RecRef.GetTable(Customer);
        SetFieldText(RecRef, 13600, NpXmlDomMgt.GetXmlText(XmlElement, 'ean', 13, false));
        RecRef.SetTable(Customer);
        Customer."VAT Registration No." := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'vat_registration_no', MaxStrLen(Customer."VAT Registration No."), false), 1, MaxStrLen(Customer."VAT Registration No."));
        Customer."Prices Including VAT" := true;

        if PrevCust = Format(Customer) then
            exit;

        Customer.Modify(true);
    end;

    local procedure InsertPaymentLinePaymentRefund(XmlElement: XmlElement; var SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
        TransactionId: Text;
        PaymentAmount: Decimal;
    begin
        TransactionId := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement, 'transaction_id', MaxStrLen(PaymentLine."No."), true));
        Evaluate(PaymentAmount, NpXmlDomMgt.GetXmlText(XmlElement, 'amount', 0, true), 9);
        if PaymentAmount = 0 then
            exit;
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
        PaymentLine."Posting Date" := SalesHeader."Posting Date";
        PaymentLine."Source Table No." := DATABASE::"Payment Method";
        PaymentLine."Source No." := PaymentMethod.Code;
        PaymentLine.Amount := PaymentAmount;
        PaymentLine."Allow Adjust Amount" := PaymentMapping."Allow Adjust Payment Amount";
        PaymentLine."Payment Gateway Code" := PaymentMapping."Payment Gateway Code";
        PaymentLine.Insert(true);
    end;

    local procedure InsertPaymentLines(XmlElement: XmlElement; var SalesHeader: Record "Sales Header")
    var
        Node: XmlNode;
        XmlNodeList: XmlNodeList;
        LineNo: Integer;
    begin
        if not XmlElement.SelectNodes('.//*[local-name()="payment_refund"]', XmlNodeList) then
            exit;

        foreach Node in XmlNodeList do begin
            InsertPaymentLinePaymentRefund(Node.AsXmlElement(), SalesHeader, LineNo);
        end;
    end;

    local procedure InsertSalesHeader(XmlElement: XmlElement; var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        MagentoWebsite: Record "NPR Magento Website";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        Node: XmlNode;
        NodeList: XmlNodeList;
        RecRef: RecordRef;
        OrderNo: Code[20];
        WebsiteCode: Code[20];
        i: Integer;
    begin
        Initialize();
        Clear(SalesHeader);
        OrderNo := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'return_order_no', true), 1, MaxStrLen(OrderNo));

        if not XmlElement.SelectSingleNode('.//*[local-name()="sell_to_customer"]', Node) then
            Error(Error001);
        InsertCustomer(Node.AsXmlElement(), MagentoSetup."Customers Enabled", Customer);
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
        SalesHeader."No." := '';
        SalesHeader."NPR External Order No." := CopyStr(OrderNo, 1, MaxStrLen(SalesHeader."NPR External Order No."));
        SalesHeader."External Document No." := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'external_document_no', MaxStrLen(SalesHeader."External Document No."), false), 1, MaxStrLen(SalesHeader."External Document No."));
        if SalesHeader."External Document No." = '' then
            SalesHeader."External Document No." := SalesHeader."NPR External Order No.";
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader."Prices Including VAT" := true;

        if XmlElement.SelectSingleNode('.//*[local-name()="ship_to_customer"]', Node) then begin
            SalesHeader."Ship-to Name" := CopyStr(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'name', MaxStrLen(SalesHeader."Ship-to Name"), true), 1, MaxStrLen(SalesHeader."Ship-to Name"));
            SalesHeader."Ship-to Name 2" := CopyStr(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'name_2', MaxStrLen(SalesHeader."Ship-to Name 2"), false), 1, MaxStrLen(SalesHeader."Ship-to Name 2"));
            SalesHeader."Ship-to Address" := CopyStr(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'address', MaxStrLen(SalesHeader."Ship-to Address"), true), 1, MaxStrLen(SalesHeader."Ship-to Address"));
            SalesHeader."Ship-to Address 2" := CopyStr(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'address_2', MaxStrLen(SalesHeader."Ship-to Address 2"), false), 1, MaxStrLen(SalesHeader."Ship-to Address 2"));
            SalesHeader."Ship-to Post Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'post_code', MaxStrLen(SalesHeader."Ship-to Post Code"), true)), 1, MaxStrLen(SalesHeader."Ship-to Post Code"));
            SalesHeader."Ship-to City" := CopyStr(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'city', MaxStrLen(SalesHeader."Ship-to City"), true), 1, MaxStrLen(SalesHeader."Ship-to City"));
            SalesHeader."Ship-to Country/Region Code" := CopyStr(UpperCase(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'country_code', MaxStrLen(SalesHeader."Ship-to Country/Region Code"), false)), 1, MaxStrLen(SalesHeader."Ship-to Country/Region Code"));
            SalesHeader."Ship-to Contact" := CopyStr(NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'contact', MaxStrLen(SalesHeader."Ship-to Contact"), false), 1, MaxStrLen(SalesHeader."Ship-to Contact"));
        end;

        SalesHeader.Validate("Salesperson Code", MagentoSetup."Salesperson Code");
        if NpXmlDomMgt.GetElementBoolean(XmlElement, 'use_customer_salesperson', false) and (Customer."Salesperson Code" <> '') then
            SalesHeader.Validate("Salesperson Code", Customer."Salesperson Code");

        if XmlElement.SelectSingleNode('.//*[local-name()="shipment"]', Node) then begin
            ShipmentMapping.SetRange("External Shipment Method Code", NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'shipment_method', MaxStrLen(ShipmentMapping."External Shipment Method Code"), true));
            ShipmentMapping.FindFirst();
            SalesHeader.Validate("Shipment Method Code", ShipmentMapping."Shipment Method Code");
            SalesHeader.Validate("Shipping Agent Code", ShipmentMapping."Shipping Agent Code");
            SalesHeader.Validate("Shipping Agent Service Code", ShipmentMapping."Shipping Agent Service Code");
            RecRef.GetTable(SalesHeader);
            SetFieldText(RecRef, 6014420, NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'shipment_service', 10, false));
            RecRef.SetTable(SalesHeader);
        end;

        if XmlElement.SelectNodes('.//*[local-name()="payment_refunds/payment_refund"]', NodeList) then begin
            i := 1;
            while (i < NodeList.Count) and (SalesHeader."Payment Method Code" = '') do begin
                NodeList.Get(i, Node);
                PaymentMapping.SetRange("External Payment Method Code",
                  CopyStr(NpXmlDomMgt.GetXmlAttributeText(Node, 'code', true), 1, MaxStrLen(PaymentMapping."External Payment Method Code")));
                PaymentMapping.SetRange("External Payment Type",
                  NpXmlDomMgt.GetXmlText(Node.AsXmlElement(), 'payment_type', MaxStrLen(PaymentMapping."External Payment Type"), false));
                if not PaymentMapping.FindFirst() then begin
                    PaymentMapping.SetRange("External Payment Type");
                    PaymentMapping.FindFirst();
                end;
                SalesHeader.Validate("Payment Method Code", PaymentMapping."Payment Method Code");

                i += 1;
            end;
        end;

        WebsiteCode := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'website_code', true), 1, MaxStrLen(WebsiteCode));
        if (MagentoWebsite.Get(WebsiteCode)) and (MagentoWebsite."Global Dimension 1 Code" <> '') then begin
            SalesHeader.Validate(SalesHeader."Shortcut Dimension 1 Code", MagentoWebsite."Global Dimension 1 Code");
            SalesHeader.Validate("Shortcut Dimension 2 Code", MagentoWebsite."Global Dimension 2 Code");
        end;
        SalesHeader.Validate("Location Code", MagentoWebsite."Location Code");
        SalesHeader.Validate("Currency Code", GetCurrencyCode(CopyStr(NpXmlDomMgt.GetElementCode(XmlElement, 'currency_code', MaxStrLen(SalesHeader."Currency Code"), false), 1, MaxStrLen(SalesHeader."Currency Code"))));
        SalesHeader.Modify(true);
    end;

    local procedure InsertSalesLines(XmlElement: XmlElement; SalesHeader: Record "Sales Header")
    var
        TempSalesLine: Record "Sales Line" temporary;
        Node: XmlNode;
        XmlNodeList: XmlNodeList;
        LineNo: Integer;
        i: Integer;
    begin
        LineNo := 0;

        if XmlElement.SelectNodes('.//*[local-name()="sales_return_order_line"]', XmlNodeList) then
            foreach Node in XmlNodeList do begin
                InsertSalesLine(Node.AsXmlElement(), SalesHeader, LineNo);
            end;

        if XmlElement.SelectNodes('/payment_refunds/payment_refund[payment_fee_refund != 0]', XmlNodeList) then
            foreach Node in XmlNodeList do begin
                XmlNodeList.Get(i, Node);
                InsertSalesLinePaymentFeeRefund(Node.AsXmlElement(), SalesHeader, LineNo);
            end;

        if XmlElement.SelectSingleNode('/shipment_refund[shipment_fee_refund != 0]', Node) then
            InsertSalesLineShipmentFeeRefund(Node.AsXmlElement(), SalesHeader, LineNo);

        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 0);
        TempSalesLine.CalcVATAmountLines(0, SalesHeader, TempSalesLine, TempVATAmountLine);
        TempSalesLine.UpdateVATOnLines(0, SalesHeader, TempSalesLine, TempVATAmountLine);
    end;

    local procedure InsertSalesLine(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SalesLine: Record "Sales Line";
        SalesCommentLine: Record "Sales Comment Line";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        ExternalItemNo: Text;
        UnitofMeasure: Code[10];
        ItemNo: Code[20];
        VariantCode: Code[10];
        LineAmount: Decimal;
        Quantity: Decimal;
        Quantity2: Decimal;
        LineAmountIncVat: Decimal;
        UnitPrice: Decimal;
        UnitPrice2: Decimal;
        VatPct: Decimal;
        Position: Integer;
        TableId: Integer;
    begin
        Initialize();
        case LowerCase(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'type', true)) of
            'comment':
                begin
                    LineNo += 10000;
                    SalesLine.Init();
                    SalesLine."Document Type" := SalesHeader."Document Type";
                    SalesLine."Document No." := SalesHeader."No.";
                    SalesLine."Line No." := LineNo;
                    SalesLine.Insert(true);
                    SalesLine.Validate(Type, SalesLine.Type::" ");
                    SalesLine.Description := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'description', MaxStrLen(SalesLine.Description), true), 1, MaxStrLen(SalesLine.Description));
                    SalesLine.Modify(true);
                end;
            'item':
                begin
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
                            Error(Error002, ItemNo, TableId);

                    if VariantCode <> '' then
                        ItemVariant.Get(ItemNo, VariantCode);
                    Evaluate(UnitPrice, NpXmlDomMgt.GetXmlText(XmlElement, 'unit_price_incl_vat', 0, true), 9);
                    Evaluate(Quantity, NpXmlDomMgt.GetXmlText(XmlElement, 'quantity', 0, true), 9);
                    Evaluate(VatPct, NpXmlDomMgt.GetXmlText(XmlElement, 'vat_percent', 0, true), 9);
                    Evaluate(LineAmount, NpXmlDomMgt.GetXmlText(XmlElement, 'line_amount_incl_vat', 0, true), 9);
                    Evaluate(UnitofMeasure, NpXmlDomMgt.GetXmlText(XmlElement, 'unit_of_measure', MaxStrLen(SalesLine."Unit of Measure Code"), false));
                    LineNo += 10000;
                    SalesLine.Init();
                    SalesLine."Document Type" := SalesHeader."Document Type";
                    SalesLine."Document No." := SalesHeader."No.";
                    SalesLine."Line No." := LineNo;
                    SalesLine.Insert(true);

                    SalesLine.Validate(Type, SalesLine.Type::Item);
                    SalesLine.Validate("No.", ItemNo);
                    SalesLine."Variant Code" := VariantCode;
                    SalesLine.Validate(Quantity, Quantity);
                    if not (UnitofMeasure in ['', '_BLANK_']) then
                        SalesLine.Validate("Unit of Measure Code", UnitofMeasure);
                    SalesLine.Validate("VAT %", VatPct);
                    if UnitPrice > 0 then
                        SalesLine.Validate("Unit Price", UnitPrice)
                    else
                        SalesLine."Unit Price" := UnitPrice;

                    if SalesLine."Unit Price" <> 0 then
                        SalesLine.Validate("Line Amount", LineAmount)
                    else
                        SalesLine."Line Amount" := LineAmount;
                    SalesLine.Modify(true);
                end;
            'fee':
                begin
                    Evaluate(Quantity2, NpXmlDomMgt.GetXmlText(XmlElement, 'quantity', 0, true), 9);
                    Evaluate(LineAmountIncVat, NpXmlDomMgt.GetXmlText(XmlElement, 'line_amount_incl_vat', 0, true), 9);
                    if (Quantity2 = 0) and (LineAmountIncVat = 0) then begin
                        LineNo += 10000;
                        SalesCommentLine.Init();
                        SalesCommentLine."Document Type" := SalesHeader."Document Type";
                        SalesCommentLine."No." := SalesHeader."No.";
                        SalesCommentLine."Document Line No." := 0;
                        SalesCommentLine."Line No." := LineNo;
                        SalesCommentLine.Date := Today();
                        SalesCommentLine.Comment := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'description', MaxStrLen(SalesLine.Description), true), 1, MaxStrLen(SalesCommentLine.Comment));
                        SalesCommentLine.Insert(true);
                    end else begin
                        LineNo += 10000;
                        SalesLine.Init();
                        SalesLine."Document Type" := SalesHeader."Document Type";
                        SalesLine."Document No." := SalesHeader."No.";
                        SalesLine."Line No." := LineNo;
                        SalesLine.Insert(true);
                        ShipmentMapping.SetRange("External Shipment Method Code", NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'external_no', false));
                        ShipmentMapping.FindFirst();
                        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
                        SalesLine.Validate("No.", ShipmentMapping."Shipment Fee No.");
                        if Quantity2 <> 0 then
                            SalesLine.Validate(Quantity, Quantity2);
                        Evaluate(UnitPrice2, NpXmlDomMgt.GetXmlText(XmlElement, 'unit_price_incl_vat', 0, true), 9);
                        SalesLine.Validate("Unit Price", UnitPrice2);
                        SalesLine.Description := CopyStr(NpXmlDomMgt.GetXmlText(XmlElement, 'description', MaxStrLen(SalesLine.Description), true), 1, MaxStrLen(SalesLine.Description));
                        SalesLine.Modify(true);
                    end;
                end;
        end;
    end;

    local procedure InsertSalesLinePaymentFeeRefund(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        PaymentFeeRefund: Decimal;
    begin
        if not Evaluate(PaymentFeeRefund, NpXmlDomMgt.GetXmlText(XmlElement, 'payment_fee_refund', 0, false), 9) then
            exit;
        if PaymentFeeRefund = 0 then
            exit;
        Initialize();
        MagentoSetup.TestField("Payment Fee Account No.");

        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", MagentoSetup."Payment Fee Account No.");
        SalesLine.Validate("Unit Price", PaymentFeeRefund);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineShipmentFeeRefund(XmlElement: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        ShipmentFeeRefund: Decimal;
    begin
        if not Evaluate(ShipmentFeeRefund, NpXmlDomMgt.GetXmlText(XmlElement, 'shipment_fee_refund', 0, false), 9) then
            exit;

        ShipmentMapping.SetRange("External Shipment Method Code", NpXmlDomMgt.GetXmlText(XmlElement, 'shipment_method', MaxStrLen(ShipmentMapping."External Shipment Method Code"), true));
        ShipmentMapping.FindFirst();
        ShipmentMapping.TestField("Shipment Fee No.");

        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", ShipmentMapping."Shipment Fee No.");
        SalesLine.Validate("Unit Price", ShipmentFeeRefund);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);
    end;
    #endregion

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

    local procedure GetCustomer(XmlElement: XmlElement; var Customer: Record Customer): Boolean
    begin
        Initialize();
        Clear(Customer);
        Customer.SetRange("E-Mail", NpXmlDomMgt.GetXmlText(XmlElement, 'email', MaxStrLen(Customer."E-Mail"), false));
        exit(Customer.FindFirst() and (Customer."E-Mail" <> ''));
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
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OrderNo: Code[20];
    begin
        OrderNo := CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement, 'return_order_no', true), 1, MaxStrLen(OrderNo));
        if OrderNo = '' then
            exit(true);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("NPR External Order No.", CopyStr(OrderNo, 1, MaxStrLen(SalesHeader."NPR External Order No.")));
        if SalesHeader.FindFirst() then
            exit(true);

        SalesCrMemoHeader.SetRange("NPR External Order No.", CopyStr(OrderNo, 1, MaxStrLen(SalesCrMemoHeader."NPR External Order No.")));
        if SalesCrMemoHeader.FindFirst() then
            exit(true);

        exit(false);
    end;

    local procedure SetFieldText(var RecRef: RecordRef; FieldNo: Integer; Value: Text)
    var
        "Field": Record "Field";
        FieldRef: FieldRef;
    begin
        if not Field.Get(RecRef.Number, FieldNo) then
            exit;

        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Value := Value;
    end;

    procedure Initialize()
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
}
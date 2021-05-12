codeunit 6151301 "NPR NpEc Sales Doc. Imp. Mgt."
{
    var
        XmlAttributeIsMissingInElementErr: Label 'Xml attribute %1 is missing in <%2>', Comment = '%1=Xml attribute name;%2=Xml element name';
        InvalidLineTypeErr: Label 'Invalid Line Type: %1', Comment = '%1=xml attribute type';
        CustomerMappingNotFoundErr: Label 'Customer Mapping within Country Code "%1" and Post Code "%2" not found';
        XmlElementIsMissingErr: Label 'XmlElement %1 is missing', Comment = '%1=xpath to element';
        CustomerNotFoundErr: Label 'Customer not found and %1 is not enabled', Comment = '%1="E-Commerce Store".FieldCaption("Allow Create Customers")';
        WrongValueTypeInNodeErr: Label 'Value "%1" is not set in proper format in <%2>. (e.g. %3)', Comment = '%1=xml element inner text;%2=xpath to element;%3=BC sample data with XML format';

    procedure DeleteSalesLines(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if not SalesLine.IsEmpty() then
            SalesLine.DeleteAll(true);
    end;

    procedure DeletePaymentLines(var SalesHeader: Record "Sales Header")
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        Clear(PaymentLine);
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        if not PaymentLine.IsEmpty() then
            PaymentLine.DeleteAll(true);
    end;

    procedure DeleteNotes(var SalesHeader: Record "Sales Header")
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.SetRange("Record ID", SalesHeader.RecordId());
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        RecordLink.SetFilter("User ID", '=%1', '');
        if not RecordLink.IsEmpty() then
            RecordLink.DeleteAll(true);
    end;

    local procedure UpsertCustomer(Element: XmlElement; var Customer: Record Customer): Boolean
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        NpEcCustomerMapping: Record "NPR NpEc Customer Mapping";
        NpEcStore: Record "NPR NpEc Store";
        TempCust: Record Customer temporary;
        Element2: XmlElement;
        Node: XmlNode;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        UpdateContFromCust: Codeunit "CustCont-Update";
        RecRef: RecordRef;
        PrevCust: Text;
        NewCustomer: Boolean;
    begin
        FindStore(Element, NpEcStore);
        if not FindCustomer(Element, Customer) then begin
            if not NpEcStore."Allow Create Customers" then
                Error(CustomerNotFoundErr, NpEcStore.FieldCaption("Allow Create Customers"));
            NewCustomer := true;

            Customer.Init();
            Customer."No." := '';
            Customer.Insert(true);
        end;

        PrevCust := Format(Customer);

        FindCustomerMapping(Element, NpEcCustomerMapping);

        if (NpEcCustomerMapping."Config. Template Code" <> '') and ConfigTemplateHeader.Get(NpEcCustomerMapping."Config. Template Code") then begin
            if NpEcStore."Update Customers from S. Order" or NewCustomer then
                RecRef.GetTable(Customer)
            else begin
                TempCust.Init();
                TempCust := Customer;
                TempCust.Insert();
                RecRef.GetTable(TempCust);
            end;

            ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
            RecRef.SetTable(Customer);
        end;

        if not Element.SelectSingleNode('.//sell_to_customer', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'sell_to_customer');

        Element2 := Node.AsXmlElement();
        if not Element2.SelectSingleNode('.//name', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + Element2.Name() + '/' + 'name');
        Customer.Name := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer.Name));
        if Element2.SelectSingleNode('.//name_2', Node) then
            Customer."Name 2" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer."Name 2"));
        if not Element2.SelectSingleNode('.//address', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + Element2.Name() + '/' + 'address');
        Customer.Address := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer.Address));
        if Element2.SelectSingleNode('.//address_2', Node) then
            Customer."Address 2" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer."Address 2"));
        if not Element2.SelectSingleNode('.//post_code', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + Element2.Name() + '/' + 'post_code');
        Customer."Post Code" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer."Post Code"));
        if not Element2.SelectSingleNode('.//city', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + Element2.Name() + '/' + 'city');
        Customer.City := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer.City));
        if Element2.SelectSingleNode('.//country_code', Node) then
            Customer."Country/Region Code" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer."Country/Region Code"));
        if Element2.SelectSingleNode('.//contact', Node) then
            Customer.Contact := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer.Contact));
        if not Element2.SelectSingleNode('.//email', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + Element2.Name() + '/' + 'email');
        Customer."E-Mail" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer."E-Mail"));
        if Element2.SelectSingleNode('.//phone', Node) then
            Customer.Contact := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer.Contact));
        if Element2.SelectSingleNode('.//ean', Node) then begin
            RecRef.GetTable(Customer);
            SetFieldText(RecRef, 13600, copystr(Node.AsXmlElement().InnerText(), 1, 13));
            RecRef.SetTable(Customer);
        end;
        if Element2.SelectSingleNode('.//vat_registration_no', Node) then
            Customer."VAT Registration No." := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer."VAT Registration No."));
        if not Element.SelectSingleNode('.//prices_incl_vat', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'prices_incl_vat');
        if not evaluate(Customer."Prices Including VAT", Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'prices_incl_vat', Format(true, 0, 9));
        if not Element.SelectSingleNode('.//currency_code', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'currency_code');
        Customer."Currency Code" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(Customer."Currency Code"));
        Customer."Currency Code" := GetCurrencyCode(Customer."Currency Code");

        if (not NpEcStore."Update Customers from S. Order") and (not NewCustomer) then
            exit;

        if PrevCust = Format(Customer) then
            exit;

        Customer.Modify(true);
        UpdateContFromCust.OnModify(Customer);
    end;

    procedure InsertNote(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        RecordLink: Record "Record Link";
        Node: XmlNode;
        OutStr: OutStream;
        Note: Text;
        LinkID: Integer;
    begin
        if not Element.SelectSingleNode('.//note', Node) then
            exit;
        if not Node.IsXmlElement() then
            exit;
        Note := Node.AsXmlElement().InnerText();
        if Note = '' then
            exit;

        LinkID := SalesHeader.AddLink('', SalesHeader."No.");
        RecordLink.Get(LinkID);
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Note.CreateOutStream(OutStr);
        OutStr.WriteText(Note);
        RecordLink."User ID" := '';
        RecordLink.Modify(true);
    end;

    local procedure InsertPaymentLine(Element: XmlElement; var SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
        Node: XmlNode;
        Attribute: XmlAttribute;
        ExternalPaymentCode, ExternalPaymentType, TransactionId : Text;
        PaymentAmount, RandDecValue : Decimal;
    begin
        if not Element.SelectSingleNode('.//transaction_id', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'transaction_id');
        TransactionId := UpperCase(copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(PaymentLine."No.")));

        if not Element.SelectSingleNode('.//amount', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'amount');

        RandDecValue := Random(100);
        if not evaluate(PaymentAmount, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'amount', Format(RandDecValue, 0, 9));
        if PaymentAmount = 0 then
            exit;

        if not Element.Attributes().Get('code', Attribute) then
            Error(XmlAttributeIsMissingInElementErr, 'code', Element.Name());
        ExternalPaymentCode := copystr(Attribute.Value(), 1, MaxStrLen(PaymentMapping."External Payment Method Code"));
        if Element.Attributes().Get('card_type', Attribute) then
            ExternalPaymentType := copystr(Attribute.Value(), 1, MaxStrLen(PaymentMapping."External Payment Type"));

        PaymentMapping.SetRange("External Payment Method Code", ExternalPaymentCode);
        PaymentMapping.SetRange("External Payment Type", ExternalPaymentType);
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
        PaymentLine.Description := CopyStr(PaymentMethod.Description + ' ' + GetDocReferenceNo(SalesHeader), 1, MaxStrLen(PaymentLine.Description));
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine."Account Type" := PaymentMethod."Bal. Account Type";
        PaymentLine."Account No." := PaymentMethod."Bal. Account No.";
        PaymentLine."No." := TransactionId;
        PaymentLine."Posting Date" := SalesHeader."Posting Date";
        PaymentLine."Source Table No." := DATABASE::"Payment Method";
        PaymentLine."Source No." := PaymentMethod.Code;
        PaymentLine.Amount := PaymentAmount;
        PaymentLine."Allow Adjust Amount" := PaymentMapping."Allow Adjust Payment Amount";
        PaymentLine."Payment Gateway Code" := PaymentMapping."Payment Gateway Code";
        PaymentLine.Insert(true);
    end;

    procedure InsertPaymentLines(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        Node: XmlNode;
        NodeList: XmlNodeList;
        LineNo: Integer;
    begin
        if not Element.SelectSingleNode('.//payments', Node) then
            exit;

        Element := Node.AsXmlElement();
        if not Element.SelectNodes('.//payment', NodeList) then
            exit;
        foreach Node in NodeList do begin
            Element := Node.AsXmlElement();
            InsertPaymentLine(Element, SalesHeader, LineNo);
        end;
    end;

    procedure InsertOrderHeader(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        Node: XmlNode;
    begin
        FindStore(Element, NpEcStore);

        Clear(SalesHeader);
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := '';
        if Element.SelectSingleNode('.//external_document_no', Node) then
            SalesHeader."External Document No." := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesHeader."No."));
        SalesHeader.Insert(true);

        NpEcDocument.Init();
        NpEcDocument."Entry No." := 0;
        NpEcDocument."Store Code" := NpEcStore.Code;
        NpEcDocument."Reference No." := GetOrderNo(Element);
        NpEcDocument."Document Type" := NpEcDocument."Document Type"::"Sales Order";
        NpEcDocument."Document No." := SalesHeader."No.";
        NpEcDocument.Insert(true);

        if SalesHeader."External Document No." = '' then
            SalesHeader."External Document No." := CopyStr(NpEcDocument."Reference No.", 1, MaxStrLen(SalesHeader."External Document No."));

        SetSellToCustomer(Element, SalesHeader);
        SetShipToCustomer(Element, SalesHeader);
        SetOrderDates(Element, SalesHeader);
        SetShipmentMethod(Element, SalesHeader);
        SetPaymentMethod(Element, SalesHeader);

        if Element.SelectSingleNode('.//currency_code', Node) then
            SalesHeader."Currency Code" := copystr(Node.AsXmlElement().InnerText(), maxstrlen(SalesHeader."Currency Code"));
        SalesHeader.Validate("Currency Code", GetCurrencyCode(SalesHeader."Currency Code"));
        SalesHeader.Validate("Salesperson Code", NpEcStore."Salesperson/Purchaser Code");
        if NpEcStore."Global Dimension 1 Code" <> '' then
            SalesHeader.Validate(SalesHeader."Shortcut Dimension 1 Code", NpEcStore."Global Dimension 1 Code");
        if NpEcStore."Global Dimension 2 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 2 Code", NpEcStore."Global Dimension 2 Code");
        SalesHeader.Validate("Location Code", NpEcStore."Location Code");
        SalesHeader.Modify(true);
    end;

    procedure InsertOrderLines(Element: XmlElement; SalesHeader: Record "Sales Header")
    var
        Node: XmlNode;
        NodeList: XmlNodeList;
        Element2: XmlElement;
        LineNo: Integer;
    begin
        LineNo := 0;

        if not Element.SelectSingleNode('.//sales_order_lines', Node) then
            exit;

        Element2 := Node.AsXmlElement();
        if not Element2.SelectNodes('.//sales_order_line', NodeList) then
            exit;

        foreach Node in NodeList do
            InsertSalesLine(Node.AsXmlElement(), SalesHeader, LineNo);


        if Element.SelectSingleNode('.//shipment_method', Node) then
            InsertSalesLineShipmentFee(Node.AsXmlElement(), SalesHeader, LineNo);
    end;

    local procedure InsertSalesLine(Element: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        Attribute: XmlAttribute;
        LineType: Text;
    begin
        if not Element.Attributes().Get('type', Attribute) then
            Error(XmlAttributeIsMissingInElementErr, 'type', Element.Name());

        LineType := Attribute.Value();
        case LowerCase(LineType) of
            'comment', Format(SalesLine.Type::" ", 0, 2):
                begin
                    InsertSalesLineComment(Element, SalesHeader, LineNo);
                end;
            'item', Format(SalesLine.Type::Item, 0, 2):
                begin
                    InsertSalesLineItem(Element, SalesHeader, LineNo);
                end;
            'gl_account', Format(SalesLine.Type::"G/L Account", 0, 2):
                begin
                    InsertSalesLineGLAccount(Element, SalesHeader, LineNo);
                end;
            else
                Error(InvalidLineTypeErr, LineType);
        end;
    end;

    local procedure InsertSalesLineComment(Element: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        Node: XmlNode;
    begin
        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::" ");

        if not Element.SelectSingleNode('.//description', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'description');
        SalesLine.Description := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesLine.Description));

        if not Element.SelectSingleNode('.//description_2', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'description_2');
        SalesLine."Description 2" := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesLine."Description 2"));

        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineItem(Element: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SalesLine: Record "Sales Line";
        Node: XmlNode;
        Attribute: XmlAttribute;
        RandDecValue, LineAmount, Quantity, UnitPrice, VatPct : Decimal;
        ReferenceNo: Text;
    begin
        if not Element.Attributes().Get('reference_no', Attribute) then
            Error(XmlAttributeIsMissingInElementErr, 'reference_no', Element.Name());

        ReferenceNo := Attribute.Value();
        if not FindItemVariant(ReferenceNo, ItemVariant) then
            exit;

        Item.Get(ItemVariant."Item No.");
        if ItemVariant.Code <> '' then
            ItemVariant.Find();

        if not Element.SelectSingleNode('.//unit_price', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'unit_price');

        RandDecValue := Random(100);
        if not evaluate(UnitPrice, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'unit_price', Format(RandDecValue, 0, 9));

        if not Element.SelectSingleNode('.//quantity', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'quantity');

        if not evaluate(Quantity, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'quantity', Format(RandDecValue, 0, 9));

        if not Element.SelectSingleNode('.//vat_percent', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'vat_percent');

        if not evaluate(VatPct, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'vat_percent', Format(RandDecValue, 0, 9));

        if not Element.SelectSingleNode('.//line_amount', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'line_amount');

        if not evaluate(LineAmount, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'line_amount', Format(RandDecValue, 0, 9));

        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine."Variant Code" := ItemVariant.Code;
        SalesLine.Validate(Quantity, Quantity);
        SalesLine.Validate("VAT %", VatPct);
        if UnitPrice > 0 then
            SalesLine.Validate("Unit Price", UnitPrice)
        else
            SalesLine."Unit Price" := UnitPrice;
        if SalesLine."Unit Price" <> 0 then
            SalesLine.Validate("Line Amount", LineAmount)
        else
            SalesLine."Line Amount" := LineAmount;

        if not Element.SelectSingleNode('.//description', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'description');
        SalesLine.Description := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesLine.Description));

        if not Element.SelectSingleNode('.//description_2', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'description_2');
        SalesLine."Description 2" := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesLine."Description 2"));

        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineGLAccount(Element: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        Node: XmlNode;
        Attribute: XmlAttribute;
        RandDecValue, LineAmount, Quantity, UnitPrice : Decimal;
        AccountNo: Text;
    begin
        if not Element.SelectSingleNode('.//unit_price', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'unit_price');

        RandDecValue := Random(100);
        if not evaluate(UnitPrice, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'unit_price', Format(RandDecValue, 0, 9));

        if not Element.SelectSingleNode('.//quantity', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'quantity');

        if not evaluate(Quantity, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'quantity', Format(RandDecValue, 0, 9));

        if not Element.SelectSingleNode('.//line_amount', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'line_amount');

        if not evaluate(LineAmount, Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'line_amount', Format(RandDecValue, 0, 9));

        if not Element.Attributes().Get('reference_no', Attribute) then
            Error(XmlAttributeIsMissingInElementErr, 'reference_no', Element.Name());

        AccountNo := Attribute.Value();

        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", AccountNo);
        if Quantity <> 0 then
            SalesLine.Validate(Quantity, Quantity);

        SalesLine.Validate("Unit Price", UnitPrice);

        if not Element.SelectSingleNode('.//description', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'description');
        SalesLine.Description := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesLine.Description));

        if not Element.SelectSingleNode('.//description_2', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'description_2');
        SalesLine."Description 2" := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesLine."Description 2"));

        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineShipmentFee(Element: XmlElement; SalesHeader: Record "Sales Header"; var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        Node: XmlNode;
        Attribute: XmlAttribute;
        ShipmentFee: Decimal;
        ExternalPaymentMethodCode: Text;
    begin
        if not Element.SelectSingleNode('.//shipment_fee', Node) then
            exit;
        if not Evaluate(ShipmentFee, Node.AsXmlElement().InnerText()) then
            exit;
        if ShipmentFee = 0 then
            exit;

        if not Element.Attributes().Get('code', Attribute) then
            Error(XmlAttributeIsMissingInElementErr, 'code', Element.Name());
        ExternalPaymentMethodCode := copystr(Attribute.Value(), 1, MaxStrLen(ShipmentMapping."External Shipment Method Code"));

        ShipmentMapping.SetRange("External Shipment Method Code", ExternalPaymentMethodCode);
        ShipmentMapping.FindFirst();
        ShipmentMapping.TestField("Shipment Fee No.");

        LineNo += 10000;
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

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

    procedure UpdateOrderHeader(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        SalesHeader2: Record "Sales Header";
        NpEcStore: Record "NPR NpEc Store";
        Node: XmlNode;
    begin
        SalesHeader.TestField("No.");
        FindStore(Element, NpEcStore);

        SalesHeader.SetHideValidationDialog(true);
        if not FindOrder(Element, SalesHeader2) then
            exit;

        SalesHeader.TestField("Document Type", SalesHeader2."Document Type");
        SalesHeader.TestField("No.", SalesHeader2."No.");

        SetSellToCustomer(Element, SalesHeader);
        SetShipToCustomer(Element, SalesHeader);
        SetOrderDates(Element, SalesHeader);
        SetShipmentMethod(Element, SalesHeader);
        SetPaymentMethod(Element, SalesHeader);

        if Element.SelectSingleNode('.//currency_code', Node) then
            SalesHeader."Currency Code" := CopyStr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesHeader."Currency Code"));
        SalesHeader.Validate("Currency Code", GetCurrencyCode(SalesHeader."Currency Code"));
        SalesHeader.Validate("Salesperson Code", NpEcStore."Salesperson/Purchaser Code");
        if NpEcStore."Global Dimension 1 Code" <> '' then
            SalesHeader.Validate(SalesHeader."Shortcut Dimension 1 Code", NpEcStore."Global Dimension 1 Code");
        if NpEcStore."Global Dimension 2 Code" <> '' then
            SalesHeader.Validate("Shortcut Dimension 2 Code", NpEcStore."Global Dimension 2 Code");
        SalesHeader.Validate("Location Code", NpEcStore."Location Code");
        SalesHeader.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDeleteSalesHeader(var Rec: Record "Sales Header"; RunTrigger: Boolean)
    var
        NpEcDocument: Record "NPR NpEc Document";
    begin
        if Rec.IsTemporary() then
            exit;

        case Rec."Document Type" of
            Rec."Document Type"::Quote:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Quote");
                end;
            Rec."Document Type"::Order:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Order");
                end;
            Rec."Document Type"::Invoice:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Invoice");
                end;
            Rec."Document Type"::"Credit Memo":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Credit Memo");
                end;
            Rec."Document Type"::"Blanket Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Blanket Order");
                end;
            Rec."Document Type"::"Return Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Return Order");
                end;
        end;
        NpEcDocument.SetRange("Document No.", Rec."No.");
        if NpEcDocument.IsEmpty() then
            exit;

        NpEcDocument.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, 80, 'OnAfterPostSalesDoc', '', true, true)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcDocument2: Record "NPR NpEc Document";
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Quote:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Quote");
                end;
            SalesHeader."Document Type"::Order:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Order");
                end;
            SalesHeader."Document Type"::Invoice:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Invoice");
                end;
            SalesHeader."Document Type"::"Credit Memo":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Credit Memo");
                end;
            SalesHeader."Document Type"::"Blanket Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Blanket Order");
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Return Order");
                end;
        end;
        NpEcDocument.SetRange("Document No.", SalesHeader."No.");
        if not NpEcDocument.FindLast() then
            exit;

        if SalesInvHdrNo <> '' then begin
            NpEcDocument2.Init();
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Sales Invoice";
            NpEcDocument2."Document No." := SalesInvHdrNo;
            NpEcDocument2.Insert(true);
        end;

        if SalesCrMemoHdrNo <> '' then begin
            NpEcDocument2.Init();
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Sales Credit Memo";
            NpEcDocument2."Document No." := SalesCrMemoHdrNo;
            NpEcDocument2.Insert(true);
        end;

        if SalesShptHdrNo <> '' then begin
            NpEcDocument2.Init();
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Sales Shipment";
            NpEcDocument2."Document No." := SalesShptHdrNo;
            NpEcDocument2.Insert(true);
        end;

        if RetRcpHdrNo <> '' then begin
            NpEcDocument2.Init();
            NpEcDocument2."Entry No." := 0;
            NpEcDocument2."Store Code" := NpEcDocument."Store Code";
            NpEcDocument2."Reference No." := NpEcDocument."Reference No.";
            NpEcDocument2."Document Type" := NpEcDocument2."Document Type"::"Posted Sales Return Receipt";
            NpEcDocument2."Document No." := RetRcpHdrNo;
            NpEcDocument2.Insert(true);
        end;
    end;

    procedure SetSellToCustomer(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
    begin
        UpsertCustomer(Element, Customer);
        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader."Sell-to Customer Name" := Customer.Name;
        SalesHeader."Sell-to Customer Name 2" := Customer."Name 2";
        SalesHeader."Sell-to Address" := Customer.Address;
        SalesHeader."Sell-to Address 2" := Customer."Address 2";
        SalesHeader."Sell-to Post Code" := Customer."Post Code";
        SalesHeader."Sell-to City" := Customer.City;
        SalesHeader."Sell-to Country/Region Code" := Customer."Country/Region Code";
        SalesHeader."Sell-to Contact" := Customer.Contact;
    end;

    procedure SetShipToCustomer(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        Node: XmlNode;
        Element2: XmlElement;
    begin
        if not Element.SelectSingleNode('.//ship_to_customer', Node) then
            exit;
        Element2 := Node.AsXmlElement();

        if not Element2.SelectSingleNode('.//name', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + Element2.Name() + '/' + 'name');
        SalesHeader."Ship-to Name" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesHeader."Ship-to Name"));
        if Element2.SelectSingleNode('.//name_2', Node) then
            SalesHeader."Ship-to Name 2" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesHeader."Ship-to Name 2"));
        if not Element2.SelectSingleNode('.//address', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + Element2.Name() + '/' + 'address');
        SalesHeader."Ship-to Address" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesHeader."Ship-to Address"));
        if Element2.SelectSingleNode('.//address_2', Node) then
            SalesHeader."Ship-to Address 2" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesHeader."Ship-to Address 2"));
        if not Element2.SelectSingleNode('.//post_code', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + Element2.Name() + '/' + 'post_code');
        SalesHeader."Ship-to Post Code" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesHeader."Ship-to Post Code"));
        if not Element2.SelectSingleNode('.//city', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + Element2.Name() + '/' + 'city');
        SalesHeader."Ship-to City" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesHeader."Ship-to City"));
        if Element2.SelectSingleNode('.//country_code', Node) then
            SalesHeader."Ship-to Country/Region Code" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesHeader."Ship-to Country/Region Code"));
        if Element2.SelectSingleNode('.//contact', Node) then
            SalesHeader."Ship-to Contact" := copystr(Node.AsXmlElement().InnerText(), 1, MaxStrLen(SalesHeader."Ship-to Contact"));
    end;

    procedure SetOrderDates(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        Node: XmlNode;
    begin
        if not Element.SelectSingleNode('.//order_date', Node) then
            Error(XmlElementIsMissingErr, Element.Name() + '/' + 'order_date');

        if not evaluate(SalesHeader."Order Date", Node.AsXmlElement().InnerText(), 9) then
            Error(WrongValueTypeInNodeErr, Node.AsXmlElement().InnerText(), Element.Name() + '/' + 'order_date', Format(today(), 0, 9));

        SalesHeader."Document Date" := SalesHeader."Order Date";
        if Element.SelectSingleNode('.//posting_date', Node) then
            if evaluate(SalesHeader."Posting Date", Node.AsXmlElement().InnerText(), 9) then;

        if SalesHeader."Posting Date" = 0D then
            SalesHeader."Posting Date" := SalesHeader."Order Date";
        SalesHeader.Validate("Posting Date");
    end;

    procedure SetShipmentMethod(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        ShipmentMapping: Record "NPR Magento Shipment Mapping";
        Node: XmlNode;
        Attribute: XmlAttribute;
        ShipmentMethodCode: Text;
    begin
        if Element.SelectSingleNode('.//shipment_method', Node) then begin
            if Node.AsXmlElement().Attributes().Get('code', Attribute) then
                ShipmentMethodCode := Attribute.Value();
        end;
        if ShipmentMethodCode = '' then
            exit;

        ShipmentMapping.SetRange("External Shipment Method Code", ShipmentMethodCode);
        ShipmentMapping.FindFirst();

        SalesHeader.Validate("Shipment Method Code", ShipmentMapping."Shipment Method Code");
        SalesHeader.Validate("Shipping Agent Code", ShipmentMapping."Shipping Agent Code");
        SalesHeader.Validate("Shipping Agent Service Code", ShipmentMapping."Shipping Agent Service Code");
    end;

    procedure SetPaymentMethod(Element: XmlElement; var SalesHeader: Record "Sales Header")
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
        NodeList: XmlNodeList;
        Node: XmlNode;
        Element2: XmlElement;
        Attribute: XmlAttribute;
        ExternalPaymentMethodCode, ExternalPaymentType : Text;
    begin
        if not Element.SelectSingleNode('.//payments', Node) then
            exit;
        Element2 := Node.AsXmlElement();

        if not Element2.SelectNodes('.//payment', NodeList) then
            exit;
        foreach Node in NodeList do begin
            Element2 := Node.AsXmlElement();
            if not Element2.Attributes().Get('code', Attribute) then
                Error(XmlAttributeIsMissingInElementErr, 'code', Element2.Name());
            ExternalPaymentMethodCode := copystr(Attribute.Value(), 1, MaxStrLen(PaymentMapping."External Payment Method Code"));
            if Element2.Attributes().Get('card_type', Attribute) then
                ExternalPaymentType := copystr(Attribute.Value(), 1, MaxStrLen(PaymentMapping."External Payment Type"));

            PaymentMapping.SetRange("External Payment Method Code", ExternalPaymentMethodCode);
            PaymentMapping.SetRange("External Payment Type", ExternalPaymentType);
            if not PaymentMapping.FindFirst() then begin
                PaymentMapping.SetRange("External Payment Type");
                PaymentMapping.FindFirst();
            end;

            if PaymentMapping."Payment Method Code" <> '' then begin
                SalesHeader.Validate("Payment Method Code", PaymentMapping."Payment Method Code");
                exit;
            end;
        end;
    end;

    local procedure FindCustomer(Element: XmlElement; var Customer: Record Customer): Boolean
    var
        NpEcStore: Record "NPR NpEc Store";
        Node: XmlNode;
        Element2: XmlElement;
        Attribute: XmlAttribute;
        CustomerNo, Email, PhoneNo : Text;
    begin
        Clear(Customer);

        if Element.SelectSingleNode('.//sell_to_customer', Node) then begin
            Element2 := Node.AsXmlElement();
            if Element2.Attributes().Get('customer_no', Attribute) then
                CustomerNo := Attribute.Value();
        end;

        if CustomerNo <> '' then begin
            Customer.Get(CustomerNo);
            exit(true);
        end;
        if Element.SelectSingleNode('.//sell_to_customer/email', Node) then
            Email := Node.AsXmlElement().InnerText();
        if Element.SelectSingleNode('.//sell_to_customer/phone', Node) then
            PhoneNo := Node.AsXmlElement().InnerText();

        FindStore(Element, NpEcStore);
        case NpEcStore."Customer Mapping" of
            NpEcStore."Customer Mapping"::"E-mail":
                begin
                    Customer.SetRange("E-Mail", Email);
                    exit(Customer.FindFirst() and (Customer."E-Mail" <> ''));
                end;
            NpEcStore."Customer Mapping"::"Phone No.":
                begin
                    Customer.SetRange("Phone No.", PhoneNo);
                    exit(Customer.FindFirst() and (Customer."Phone No." <> ''));
                end;
            NpEcStore."Customer Mapping"::"E-mail OR Phone No.":
                begin
                    Clear(Customer);
                    Customer.SetRange("E-Mail", Email);
                    if Customer.FindFirst() and (Customer."E-Mail" <> '') then
                        exit(true);

                    Clear(Customer);
                    Customer.SetRange("Phone No.", PhoneNo);
                    exit(Customer.FindFirst() and (Customer."Phone No." <> ''));
                end;
            NpEcStore."Customer Mapping"::"E-mail AND Phone No.":
                begin
                    Clear(Customer);
                    Customer.SetRange("E-Mail", Email);
                    Customer.SetRange("Phone No.", PhoneNo);
                    exit(Customer.FindFirst() and ((Customer."E-Mail" <> '') or (Customer."Phone No." <> '')));
                end;
        end;
    end;

    local procedure FindCustomerMapping(Element: XmlElement; var NpEcCustomerMapping: Record "NPR NpEc Customer Mapping")
    var
        NpEcStore: Record "NPR NpEc Store";
        Node: XmlNode;
        CountryCode: Text;
        PostCode: Text;
    begin
        Clear(NpEcCustomerMapping);
        FindStore(Element, NpEcStore);
        if Element.SelectSingleNode('/country_code', Node) then
            CountryCode := Node.AsXmlElement().InnerText();
        if Element.SelectSingleNode('/post_code', Node) then
            PostCode := Node.AsXmlElement().InnerText();

        if NpEcCustomerMapping.Get(NpEcStore.Code, CountryCode, PostCode) then
            exit;

        if NpEcCustomerMapping.Get(NpEcStore.Code, CountryCode, '') then
            exit;

        if NpEcCustomerMapping.Get(NpEcStore.Code, '', PostCode) then
            exit;

        if NpEcCustomerMapping.Get(NpEcStore.Code, '', '') then
            exit;

        if NpEcStore."Customer Config. Template Code" <> '' then begin
            NpEcCustomerMapping."Config. Template Code" := NpEcStore."Customer Config. Template Code";
            exit;
        end;

        Error(CustomerMappingNotFoundErr, CountryCode, PostCode);
    end;

    local procedure FindItemVariant(ReferenceNo: Text; var ItemVariant: Record "Item Variant"): Boolean
    var
        Item: Record Item;
        ItemRef: Record "Item Reference";
        Position: Integer;
        ItemNo: Text;
        VariantCode: Text;
    begin
        Clear(ItemVariant);

        if ReferenceNo = '' then
            exit(false);

        if StrLen(ReferenceNo) <= MaxStrLen(ItemRef."Reference No.") then begin
            ItemRef.SetRange("Reference Type", ItemRef."Reference Type"::"Bar Code");
            ItemRef.SetRange("Reference No.", UpperCase(ReferenceNo));
            if ItemRef.FindFirst() then begin
                ItemVariant."Item No." := ItemRef."Item No.";
                ItemVariant.Code := ItemRef."Variant Code";
                exit(true);
            end;
        end;

        if StrLen(ReferenceNo) <= MaxStrLen(Item."No.") then begin
            if Item.Get(UpperCase(ReferenceNo)) then begin
                ItemVariant."Item No." := Item."No.";
                exit(true);
            end;
        end;

        Position := StrPos(ReferenceNo, '_');
        if Position > 0 then begin
            ItemNo := UpperCase(CopyStr(ReferenceNo, 1, Position));
            VariantCode := UpperCase(DelStr(ReferenceNo, 1, Position));

            if (StrLen(ItemNo) <= MaxStrLen(ItemVariant."Item No.")) and (StrLen(VariantCode) <= MaxStrLen(ItemVariant.Code)) then begin
                if ItemVariant.Get(ItemNo, VariantCode) then
                    exit(true);
            end;
        end;

        exit(false);
    end;

    procedure FindOrder(Element: XmlElement; var SalesHeader: Record "Sales Header"): Boolean
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        OrderNo: Text;
    begin
        Clear(SalesHeader);

        FindStore(Element, NpEcStore);
        OrderNo := GetOrderNo(Element);
        if OrderNo = '' then
            exit(false);

        NpEcDocument.SetRange("Store Code", NpEcStore.Code);
        NpEcDocument.SetRange("Reference No.", OrderNo);
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Order");
        if not NpEcDocument.FindLast() then
            exit(false);

        exit(SalesHeader.Get(SalesHeader."Document Type"::Order, NpEcDocument."Document No."));
    end;

    procedure FindPostedInvoice(Element: XmlElement; var SalesInvHeader: Record "Sales Invoice Header"): Boolean
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        OrderNo: Text;
    begin
        FindStore(Element, NpEcStore);
        OrderNo := GetOrderNo(Element);
        NpEcDocument.SetRange("Store Code", NpEcStore.Code);
        NpEcDocument.SetRange("Reference No.", OrderNo);
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Posted Sales Invoice");
        if not NpEcDocument.FindLast() then
            exit(false);

        exit(SalesInvHeader.Get(NpEcDocument."Document No."));
    end;

    procedure FindPostedInvoices(Element: XmlElement; var TempSalesInvHeader: Record "Sales Invoice Header" temporary): Boolean
    var
        NpEcDocument: Record "NPR NpEc Document";
        NpEcStore: Record "NPR NpEc Store";
        SalesInvHeader: Record "Sales Invoice Header";
        OrderNo: Text;
    begin
        FindStore(Element, NpEcStore);
        OrderNo := GetOrderNo(Element);
        NpEcDocument.SetRange("Store Code", NpEcStore.Code);
        NpEcDocument.SetRange("Reference No.", OrderNo);
        NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Posted Sales Invoice");
        if not NpEcDocument.FindSet() then
            exit(false);

        repeat
            if SalesInvHeader.Get(NpEcDocument."Document No.") and not TempSalesInvHeader.Get(SalesInvHeader."No.") then begin
                TempSalesInvHeader.Init();
                TempSalesInvHeader := SalesInvHeader;
                TempSalesInvHeader.Insert();
            end;
        until NpEcDocument.Next() = 0;
        exit(TempSalesInvHeader.FindFirst());
    end;

    local procedure FindStore(Element: XmlElement; var NpEcStore: Record "NPR NpEc Store")
    var
        Attribute: XmlAttribute;
    begin
        if not Element.Attributes().Get('store_code', Attribute) then
            exit;

        NpEcStore.Get(Attribute.Value());
    end;

    local procedure GetCurrencyCode(CurrencyCode: Code[10]): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not GLSetup.Get() then
            exit(CurrencyCode);

        if GLSetup."LCY Code" = CurrencyCode then
            exit('');

        exit(CurrencyCode);
    end;

    local procedure GetOrderNo(Element: XmlElement) OrderNo: Text
    var
        Attribute: XmlAttribute;
    begin
        if not Element.Attributes().Get('order_no', Attribute) then
            Error(XmlAttributeIsMissingInElementErr, 'order_no', Element.Name());
        OrderNo := Attribute.Value();
        if OrderNo = '' then
            Error(XmlAttributeIsMissingInElementErr, 'order_no', Element.Name());
    end;

    procedure OrderExists(Element: XmlElement): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if FindOrder(Element, SalesHeader) then
            exit(true);

        if FindPostedInvoice(Element, SalesInvoiceHeader) then
            exit(true);

        exit(false);
    end;

    procedure GetDocReferenceNo(SalesHeader: Record "Sales Header"): Text
    var
        NpEcDocument: Record "NPR NpEc Document";
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Quote:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Quote");
                end;
            SalesHeader."Document Type"::Order:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Order");
                end;
            SalesHeader."Document Type"::Invoice:
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Invoice");
                end;
            SalesHeader."Document Type"::"Credit Memo":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Credit Memo");
                end;
            SalesHeader."Document Type"::"Blanket Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Blanket Order");
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    NpEcDocument.SetRange("Document Type", NpEcDocument."Document Type"::"Sales Return Order");
                end;
        end;
        NpEcDocument.SetRange("Document No.", SalesHeader."No.");
        if NpEcDocument.FindLast() then;
        exit(NpEcDocument."Reference No.");
    end;

    local procedure SetFieldText(var RecRef: RecordRef; FieldNo: Integer; Input: Text)
    var
        FieldRec: Record Field;
        FieldReference: FieldRef;
    begin
        FieldRec.SetRange(TableNo, RecRef.Number());
        FieldRec.SetRange("No.", FieldNo);
        FieldRec.SetRange(ObsoleteState, FieldRec.ObsoleteState::No);
        if FieldRec.IsEmpty() then
            exit;
        FieldReference := RecRef.Field(FieldNo);
        FieldReference.Value := Input;
    end;
}


codeunit 6151301 "NpEc Sales Doc. Import Mgt."
{
    // NPR5.53/MHA /20191205  CASE 380837 Object created - NaviPartner General E-Commerce


    trigger OnRun()
    begin
    end;

    var
        Text000: Label 'Xml attribute %1 is missing in <%2>';
        Text001: Label 'Invalid Line Type: %1';
        Text002: Label 'Customer Mapping within Country Code "%1" and Post Code "%2" not found';
        Text003: Label 'Unknown Item: %1 ';

    local procedure "--- Database"()
    begin
    end;

    procedure DeleteSalesLines(SalesHeader: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        if SalesLine.FindFirst then
          SalesLine.DeleteAll(true);
    end;

    procedure DeletePaymentLines(var SalesHeader: Record "Sales Header")
    var
        CreditVoucher: Record "Credit Voucher";
        PaymentLine: Record "Magento Payment Line";
    begin
        Clear(PaymentLine);
        PaymentLine.SetRange("Document Table No.",DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type",SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.",SalesHeader."No.");
        if PaymentLine.FindFirst then
          PaymentLine.DeleteAll(true);
    end;

    procedure DeleteNotes(var SalesHeader: Record "Sales Header")
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.SetRange("Record ID",SalesHeader.RecordId);
        RecordLink.SetRange(Type,RecordLink.Type::Note);
        RecordLink.SetFilter("User ID",'=%1','');
        if RecordLink.FindFirst then
          RecordLink.DeleteAll(true);
    end;

    local procedure UpsertCustomer(XmlElement: DotNet npNetXmlElement;var Customer: Record Customer): Boolean
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        NpEcCustomerMapping: Record "NpEc Customer Mapping";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        UpdateContFromCust: Codeunit "CustCont-Update";
        RecRef: RecordRef;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        PrevCust: Text;
    begin
        if not FindCustomer(XmlElement,Customer) then begin
          Customer.Init;
          Customer."No." := '';
          Customer.Insert(true);
        end;

        PrevCust := Format(Customer);

        FindCustomerMapping(XmlElement,NpEcCustomerMapping);

        if (NpEcCustomerMapping."Config. Template Code" <> '') and ConfigTemplateHeader.Get(NpEcCustomerMapping."Config. Template Code") then begin
          RecRef.GetTable(Customer);
          ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
          RecRef.SetTable(Customer);
        end;

        Customer.Name := NpXmlDomMgt.GetElementText(XmlElement,'name',MaxStrLen(Customer.Name),true);
        Customer."Name 2" := NpXmlDomMgt.GetElementText(XmlElement,'name_2',MaxStrLen(Customer."Name 2"),false);
        Customer.Address := NpXmlDomMgt.GetElementText(XmlElement,'address',MaxStrLen(Customer.Address),true);
        Customer."Address 2" := NpXmlDomMgt.GetElementText(XmlElement,'address_2',MaxStrLen(Customer.Address),false);
        Customer."Post Code" := UpperCase(NpXmlDomMgt.GetElementCode(XmlElement,'post_code',MaxStrLen(Customer."Post Code"),true));
        Customer.City := NpXmlDomMgt.GetElementText(XmlElement,'city',MaxStrLen(Customer.City),true);
        Customer."Country/Region Code" := NpXmlDomMgt.GetElementCode(XmlElement,'country_code',MaxStrLen(Customer."Country/Region Code"),false);
        Customer.Contact := NpXmlDomMgt.GetElementText(XmlElement,'contact',MaxStrLen(Customer.Contact),false);
        Customer."E-Mail" := NpXmlDomMgt.GetElementText(XmlElement,'email',MaxStrLen(Customer."E-Mail"),true);
        Customer."Phone No." := NpXmlDomMgt.GetElementText(XmlElement,'phone',MaxStrLen(Customer."Phone No."),false);
        RecRef.GetTable(Customer);
        SetFieldText(RecRef,13600,NpXmlDomMgt.GetElementText(XmlElement,'ean',13,false));
        RecRef.SetTable(Customer);
        Customer."VAT Registration No." := NpXmlDomMgt.GetElementText(XmlElement,'vat_registration_no',MaxStrLen(Customer."VAT Registration No."),false);
        Customer."Prices Including VAT" := NpXmlDomMgt.GetElementBoolean(XmlElement,'/*/sales_order/prices_incl_vat',true);
        Customer."Currency Code" := NpXmlDomMgt.GetElementCode(XmlElement,'/*/sales_order/currency_code',MaxStrLen(Customer."Currency Code"),true);
        Customer."Currency Code" := GetCurrencyCode(Customer."Currency Code");

        if PrevCust = Format(Customer) then
          exit;

        Customer.Modify(true);
        UpdateContFromCust.OnModify(Customer);
    end;

    procedure InsertNote(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        RecordLink: Record "Record Link";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        OutStream: OutStream;
        LinkID: Integer;
        BinaryWriter: DotNet npNetBinaryWriter;
        Encoding: DotNet npNetEncoding;
        Note: Text;
    begin
        Note := NpXmlDomMgt.GetElementText(XmlElement,'/*/sales_order/note',0,false);
        if Note  = '' then
          exit;

        LinkID := SalesHeader.AddLink('',SalesHeader."No.");
        RecordLink.Get(LinkID);
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Note.CreateOutStream(OutStream);
        RecordLink."User ID" := '';
        Encoding := Encoding.UTF8;
        BinaryWriter := BinaryWriter.BinaryWriter(OutStream,Encoding);
        BinaryWriter.Write(Note);
        RecordLink.Modify(true);
    end;

    local procedure InsertPaymentLine(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        PaymentLine: Record "Magento Payment Line";
        PaymentMapping: Record "Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        TransactionId: Text;
        PaymentAmount: Decimal;
    begin
        TransactionId := UpperCase(NpXmlDomMgt.GetElementText(XmlElement,'transaction_id',MaxStrLen(PaymentLine."No."),true));
        Evaluate(PaymentAmount,NpXmlDomMgt.GetElementText(XmlElement,'amount',0,true),9);
        if PaymentAmount = 0 then
          exit;

        PaymentMapping.SetRange("External Payment Method Code",CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement,'code',true),1,MaxStrLen(PaymentMapping."External Payment Method Code")));

        PaymentMapping.SetRange("External Payment Type",NpXmlDomMgt.GetElementText(XmlElement,'card_type',MaxStrLen(PaymentMapping."External Payment Type"),false));
        if not PaymentMapping.FindFirst then begin
          PaymentMapping.SetRange("External Payment Type");
          PaymentMapping.FindFirst;
        end;
        PaymentMapping.TestField("Payment Method Code");
        PaymentMethod.Get(PaymentMapping."Payment Method Code");

        LineNo += 10000;
        PaymentLine."Document Table No." := DATABASE::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := LineNo;
        PaymentLine.Description := CopyStr(PaymentMethod.Description + ' ' + SalesHeader."NpEc Document No.",1,MaxStrLen(PaymentLine.Description));
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

    procedure InsertPaymentLines(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        XmlElement2: DotNet npNetXmlElement;
        XmlElementLines: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        LineNo: Integer;
        i: Integer;
    begin
        XmlElementLines := XmlElement.SelectSingleNode('payments');
        if not IsNull(XmlElementLines) then begin
          NpXmlDomMgt.FindNodes(XmlElementLines,'payment',XmlNodeList);
          LineNo := 0;
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElement2 := XmlNodeList.ItemOf(i);

            InsertPaymentLine(XmlElement2,SalesHeader,LineNo);
          end;
        end;
    end;

    procedure InsertOrderHeader(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        NpEcStore: Record "NpEc Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement2: DotNet npNetXmlElement;
    begin
        FindSalesOrder(XmlElement,XmlElement);
        FindStore(XmlElement,NpEcStore);

        Clear(SalesHeader);
        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := '';
        SalesHeader."NpEc Store Code" := NpEcStore.Code;
        SalesHeader."NpEc Document No." := GetOrderNo(XmlElement);
        SalesHeader."External Document No." := NpXmlDomMgt.GetElementCode(XmlElement,'external_document_no',MaxStrLen(SalesHeader."No."),false);
        if SalesHeader."External Document No." = '' then
          SalesHeader."External Document No." := CopyStr(SalesHeader."NpEc Document No.",1,MaxStrLen(SalesHeader."External Document No."));
        SalesHeader.Insert(true);

        SetSellToCustomer(XmlElement,SalesHeader);
        SetShipToCustomer(XmlElement,SalesHeader);
        SetOrderDates(XmlElement,SalesHeader);
        SetShipmentMethod(XmlElement,SalesHeader);
        SetPaymentMethod(XmlElement,SalesHeader);

        SalesHeader."Currency Code" := NpXmlDomMgt.GetElementCode(XmlElement,'currency_code',MaxStrLen(SalesHeader."Currency Code"),false);
        SalesHeader.Validate("Currency Code",GetCurrencyCode(SalesHeader."Currency Code"));
        SalesHeader.Validate("Salesperson Code",NpEcStore."Salesperson/Purchaser Code");
        if NpEcStore."Global Dimension 1 Code" <> '' then
          SalesHeader.Validate(SalesHeader."Shortcut Dimension 1 Code",NpEcStore."Global Dimension 1 Code");
        if NpEcStore."Global Dimension 2 Code" <> '' then
          SalesHeader.Validate("Shortcut Dimension 2 Code",NpEcStore."Global Dimension 2 Code");
        SalesHeader.Validate("Location Code",NpEcStore."Location Code");
        SalesHeader.Modify(true);
    end;

    procedure InsertOrderLines(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header")
    var
        SalesLineTemp: Record "Sales Line" temporary;
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElementLine: DotNet npNetXmlElement;
        XmlElementLines: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        LineNo: Integer;
        i: Integer;
    begin
        LineNo := 0;

        XmlElementLines := XmlElement.SelectSingleNode('sales_order_lines');
        if not IsNull(XmlElementLines) then begin
          NpXmlDomMgt.FindNodes(XmlElementLines,'sales_order_line',XmlNodeList);
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElementLine := XmlNodeList.ItemOf(i);
            InsertSalesLine(XmlElementLine,SalesHeader,LineNo);
          end;
        end;

        if NpXmlDomMgt.FindNode(XmlElement,'shipment_method',XmlElementLine) then
          InsertSalesLineShipmentFee(XmlElementLine,SalesHeader,LineNo);
    end;

    local procedure InsertSalesLine(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        LineType: Text;
    begin
        LineType := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'type',true);
        case LowerCase(LineType) of
          'comment',Format(SalesLine.Type::" ",0,2):
            begin
              InsertSalesLineComment(XmlElement,SalesHeader,LineNo);
            end;
          'item',Format(SalesLine.Type::Item,0,2):
            begin
              InsertSalesLineItem(XmlElement,SalesHeader,LineNo);
            end;
          'gl_account',Format(SalesLine.Type::"G/L Account",0,2):
            begin
              InsertSalesLineGLAccount(XmlElement,SalesHeader,LineNo);
            end;
          else
            Error(Text001,LineType);
        end;
    end;

    local procedure InsertSalesLineComment(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);
        SalesLine.Validate(Type,SalesLine.Type::" ");
        SalesLine.Description := NpXmlDomMgt.GetElementText(XmlElement,'description',MaxStrLen(SalesLine.Description),true);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineItem(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SalesLine: Record "Sales Line";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        TableId: Integer;
        LineAmount: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        VatPct: Decimal;
        ReferenceNo: Text;
    begin
        ReferenceNo := NpXmlDomMgt.GetAttributeText(XmlElement,'','reference_no',0,true);
        if not FindItemVariant(ReferenceNo,ItemVariant) then
          exit;

        Item.Get(ItemVariant."Item No.");
        if ItemVariant.Code <> '' then
          ItemVariant.Find;

        UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price',true);
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement,'quantity',true);
        VatPct := NpXmlDomMgt.GetElementDec(XmlElement,'vat_percent',true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount',true);
        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type,SalesLine.Type::Item);
        SalesLine.Validate("No.",Item."No.");
        SalesLine."Variant Code" := ItemVariant.Code;
        SalesLine.Validate(Quantity,Quantity);
        SalesLine.Validate("VAT %",VatPct);
        if UnitPrice > 0 then
          SalesLine.Validate("Unit Price",UnitPrice)
        else
          SalesLine."Unit Price" := UnitPrice;
        SalesLine.Validate("VAT Prod. Posting Group");

        if SalesLine."Unit Price" <> 0 then
          SalesLine.Validate("Line Amount",LineAmount)
        else
          SalesLine."Line Amount" := LineAmount;
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineGLAccount(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        LineAmount: Decimal;
        Quantity: Decimal;
        UnitPrice: Decimal;
        AccountNo: Text;
    begin
        Quantity := NpXmlDomMgt.GetElementDec(XmlElement,'quantity',true);
        LineAmount := NpXmlDomMgt.GetElementDec(XmlElement,'line_amount',true);
        UnitPrice := NpXmlDomMgt.GetElementDec(XmlElement,'unit_price',true);

        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        AccountNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'','reference_no',MaxStrLen(SalesLine."No."),true);
        SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.",AccountNo);
        if Quantity <> 0 then
          SalesLine.Validate(Quantity,Quantity);

        SalesLine.Validate("Unit Price",UnitPrice);
        SalesLine.Description := NpXmlDomMgt.GetElementText(XmlElement,'description',MaxStrLen(SalesLine.Description),true);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineShipmentFee(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        ShipmentMapping: Record "Magento Shipment Mapping";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        ShipmentFee: Decimal;
    begin
        ShipmentFee := NpXmlDomMgt.GetElementDec(XmlElement,'shipment_fee',false);
        if ShipmentFee = 0 then
          exit;

        ShipmentMapping.SetRange("External Shipment Method Code",NpXmlDomMgt.GetAttributeText(XmlElement,'','code',MaxStrLen(ShipmentMapping."External Shipment Method Code"),true));
        ShipmentMapping.FindFirst;
        ShipmentMapping.TestField("Shipment Fee No.");

        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        case ShipmentMapping."Shipment Fee Type" of
          ShipmentMapping."Shipment Fee Type"::"G/L Account":
            begin
              SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
            end;
          ShipmentMapping."Shipment Fee Type"::Item:
            begin
              SalesLine.Validate(Type,SalesLine.Type::Item);
            end;
          ShipmentMapping."Shipment Fee Type"::Resource:
            begin
              SalesLine.Validate(Type,SalesLine.Type::Resource);
            end;
          ShipmentMapping."Shipment Fee Type"::"Fixed Asset":
            begin
              SalesLine.Validate(Type,SalesLine.Type::"Fixed Asset");
            end;
          ShipmentMapping."Shipment Fee Type"::"Charge (Item)":
            begin
              SalesLine.Validate(Type,SalesLine.Type::"Charge (Item)");
            end;
        end;
        SalesLine.Validate("No.",ShipmentMapping."Shipment Fee No.");
        SalesLine.Validate("Unit Price",ShipmentFee);
        SalesLine.Validate(Quantity,1);
        SalesLine.Modify(true);
    end;

    procedure UpdateOrderHeader(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        NpEcStore: Record "NpEc Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement2: DotNet npNetXmlElement;
    begin
        SalesHeader.TestField("No.");
        FindSalesOrder(XmlElement,XmlElement);
        FindStore(XmlElement,NpEcStore);

        SalesHeader.SetHideValidationDialog(true);
        SalesHeader.TestField("NpEc Store Code",NpEcStore.Code);
        SalesHeader.TestField("NpEc Document No.",GetOrderNo(XmlElement));

        SetSellToCustomer(XmlElement,SalesHeader);
        SetShipToCustomer(XmlElement,SalesHeader);
        SetOrderDates(XmlElement,SalesHeader);
        SetShipmentMethod(XmlElement,SalesHeader);
        SetPaymentMethod(XmlElement,SalesHeader);

        SalesHeader."Currency Code" := NpXmlDomMgt.GetElementCode(XmlElement,'currency_code',MaxStrLen(SalesHeader."Currency Code"),false);
        SalesHeader.Validate("Currency Code",GetCurrencyCode(SalesHeader."Currency Code"));
        SalesHeader.Validate("Salesperson Code",NpEcStore."Salesperson/Purchaser Code");
        if NpEcStore."Global Dimension 1 Code" <> '' then
          SalesHeader.Validate(SalesHeader."Shortcut Dimension 1 Code",NpEcStore."Global Dimension 1 Code");
        if NpEcStore."Global Dimension 2 Code" <> '' then
          SalesHeader.Validate("Shortcut Dimension 2 Code",NpEcStore."Global Dimension 2 Code");
        SalesHeader.Validate("Location Code",NpEcStore."Location Code");
        SalesHeader.Modify(true);
    end;

    local procedure "--- Set Order Header"()
    begin
    end;

    procedure SetSellToCustomer(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        XmlElement2: DotNet npNetXmlElement;
    begin
        FindSalesOrder(XmlElement,XmlElement);
        FindSellToCustomer(XmlElement,XmlElement2);
        UpsertCustomer(XmlElement2,Customer);
        SalesHeader.Validate("Sell-to Customer No.",Customer."No.");
    end;

    procedure SetShipToCustomer(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement2: DotNet npNetXmlElement;
    begin
        FindSalesOrder(XmlElement,XmlElement);
        if not NpXmlDomMgt.FindNode(XmlElement,'ship_to_customer',XmlElement2) then
          exit;

        SalesHeader."Ship-to Name" := NpXmlDomMgt.GetElementText(XmlElement2,'name',MaxStrLen(SalesHeader."Ship-to Name"),true);
        SalesHeader."Ship-to Name 2" := NpXmlDomMgt.GetElementText(XmlElement2,'name_2',MaxStrLen(SalesHeader."Ship-to Name 2"),false);
        SalesHeader."Ship-to Address" := NpXmlDomMgt.GetElementText(XmlElement2,'address',MaxStrLen(SalesHeader."Ship-to Address"),true);
        SalesHeader."Ship-to Address 2" := NpXmlDomMgt.GetElementText(XmlElement2,'address_2',MaxStrLen(SalesHeader."Ship-to Address 2"),false);
        SalesHeader."Ship-to Post Code" := NpXmlDomMgt.GetElementCode(XmlElement2,'post_code',MaxStrLen(SalesHeader."Ship-to Post Code"),true);
        SalesHeader."Ship-to City" := NpXmlDomMgt.GetElementText(XmlElement2,'city',MaxStrLen(SalesHeader."Ship-to City"),true);
        SalesHeader."Ship-to Country/Region Code" := NpXmlDomMgt.GetElementCode(XmlElement2,'country_code',MaxStrLen(SalesHeader."Ship-to Country/Region Code"),false);
        SalesHeader."Ship-to Contact" := NpXmlDomMgt.GetElementText(XmlElement2,'contact',MaxStrLen(SalesHeader."Ship-to Contact"),false);
    end;

    procedure SetOrderDates(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        FindSalesOrder(XmlElement,XmlElement);

        SalesHeader."Order Date" := NpXmlDomMgt.GetElementDate(XmlElement,'order_date',true);
        SalesHeader."Document Date" := SalesHeader."Order Date";
        SalesHeader."Posting Date" := NpXmlDomMgt.GetElementDate(XmlElement,'posting_date',false);
        if SalesHeader."Posting Date" = 0D then
          SalesHeader."Posting Date" := SalesHeader."Order Date";
        SalesHeader.Validate("Posting Date");
    end;

    procedure SetShipmentMethod(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        ShipmentMapping: Record "Magento Shipment Mapping";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        ShipmentMethodCode: Text;
    begin
        FindSalesOrder(XmlElement,XmlElement);

        ShipmentMethodCode := NpXmlDomMgt.GetAttributeText(XmlElement,'shipment_method','code',MaxStrLen(ShipmentMapping."External Shipment Method Code"),false);
        if ShipmentMethodCode = '' then
          exit;

        ShipmentMapping.SetRange("External Shipment Method Code",ShipmentMethodCode);
        ShipmentMapping.FindFirst;
        SalesHeader.Validate("Shipment Method Code",ShipmentMapping."Shipment Method Code");
        SalesHeader.Validate("Shipping Agent Code",ShipmentMapping."Shipping Agent Code");
        SalesHeader.Validate("Shipping Agent Service Code",ShipmentMapping."Shipping Agent Service Code");
    end;

    procedure SetPaymentMethod(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        PaymentMapping: Record "Magento Payment Mapping";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlElement2: DotNet npNetXmlElement;
        ExternalPaymentMethodCode: Text;
        ExternalPaymentType: Text;
    begin
        FindSalesOrder(XmlElement,XmlElement);

        if not NpXmlDomMgt.FindNode(XmlElement,'payments/payment',XmlElement2) then
          exit;

        repeat
          ExternalPaymentMethodCode := NpXmlDomMgt.GetAttributeText(XmlElement2,'','code',MaxStrLen(PaymentMapping."External Payment Method Code"),true);
          PaymentMapping.SetRange("External Payment Method Code",ExternalPaymentMethodCode);
          ExternalPaymentType := NpXmlDomMgt.GetAttributeText(XmlElement2,'','card_type',MaxStrLen(PaymentMapping."External Payment Type"),false);
          PaymentMapping.SetRange("External Payment Type",ExternalPaymentType);
          if not PaymentMapping.FindFirst then begin
            PaymentMapping.SetRange("External Payment Type");
            PaymentMapping.FindFirst;
          end;

          if PaymentMapping."Payment Method Code" <> '' then begin
            SalesHeader.Validate("Payment Method Code",PaymentMapping."Payment Method Code");
            exit;
          end;

          XmlElement2 := XmlElement2.NextSibling;
          if IsNull(XmlElement2) then
            exit;
        until LowerCase(XmlElement2.Name) <> 'payment';
    end;

    local procedure "--- Get/Check"()
    begin
    end;

    local procedure FindCustomer(XmlElement: DotNet npNetXmlElement;var Customer: Record Customer): Boolean
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        CustomerNo: Text;
    begin
        Clear(Customer);

        CustomerNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'/*/sales_order/sell_to_customer','customer_no',MaxStrLen(Customer."No."),false);
        if CustomerNo <> '' then begin
          Customer.Get(CustomerNo);
          exit(true);
        end;

        Customer.SetRange("E-Mail",NpXmlDomMgt.GetElementText(XmlElement,'email',MaxStrLen(Customer."E-Mail"),false));
        exit(Customer.FindFirst and (Customer."E-Mail" <> ''));
    end;

    local procedure FindCustomerMapping(XmlElement: DotNet npNetXmlElement;var NpEcCustomerMapping: Record "NpEc Customer Mapping")
    var
        NpEcStore: Record "NpEc Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        CountryCode: Text;
        PostCode: Text;
    begin
        Clear(NpEcCustomerMapping);
        FindStore(XmlElement,NpEcStore);
        CountryCode := NpXmlDomMgt.GetElementCode(XmlElement,'country_code',MaxStrLen(NpEcCustomerMapping."Store Code"),false);
        PostCode := NpXmlDomMgt.GetElementCode(XmlElement,'post_code',MaxStrLen(NpEcCustomerMapping."Post Code"),false);

        if NpEcCustomerMapping.Get(NpEcStore.Code,CountryCode,PostCode) then
          exit;

        if NpEcCustomerMapping.Get(NpEcStore.Code,CountryCode,'') then
          exit;

        if NpEcCustomerMapping.Get(NpEcStore.Code,'',PostCode) then
          exit;

        if NpEcCustomerMapping.Get(NpEcStore.Code,'','') then
          exit;

        if NpEcStore."Customer Config. Template Code" <> '' then begin
          NpEcCustomerMapping."Config. Template Code" := NpEcStore."Customer Config. Template Code";
          exit;
        end;

        Error(Text002,CountryCode,PostCode);
    end;

    local procedure FindItemVariant(ReferenceNo: Text;var ItemVariant: Record "Item Variant"): Boolean
    var
        Item: Record Item;
        ItemCrossRef: Record "Item Cross Reference";
        Position: Integer;
        ItemNo: Text;
        VariantCode: Text;
    begin
        Clear(ItemVariant);

        if ReferenceNo = '' then
          exit(false);

        if StrLen(ReferenceNo) <= MaxStrLen(ItemCrossRef."Cross-Reference No.") then begin
          ItemCrossRef.SetRange("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::"Bar Code");
          ItemCrossRef.SetRange("Cross-Reference No.",UpperCase(ReferenceNo));
          ItemCrossRef.SetRange("Discontinue Bar Code",false);
          if ItemCrossRef.FindFirst then begin
            ItemVariant."Item No." := ItemCrossRef."Item No.";
            ItemVariant.Code := ItemCrossRef."Variant Code";
            exit(true);
          end;
        end;

        if StrLen(ReferenceNo) <= MaxStrLen(Item."No.") then begin
          if Item.Get(UpperCase(ReferenceNo)) then begin
            ItemVariant."Item No." := Item."No.";
            exit(true);
          end;
        end;

        Position := StrPos(ReferenceNo,'_');
        if Position > 0 then begin
          ItemNo := UpperCase(CopyStr(ReferenceNo,1,Position));
          VariantCode := UpperCase(DelStr(ReferenceNo,1,Position));

          if (StrLen(ItemNo) <= MaxStrLen(ItemVariant."Item No.")) and (StrLen(VariantCode) <= MaxStrLen(ItemVariant.Code)) then begin
            if ItemVariant.Get(ItemNo,VariantCode) then
                exit(true);
          end;
        end;

        exit(false);
    end;

    procedure FindOrder(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header"): Boolean
    var
        NpEcStore: Record "NpEc Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        OrderNo: Text;
        StoreCode: Text;
    begin
        Clear(SalesHeader);

        FindStore(XmlElement,NpEcStore);
        OrderNo := GetOrderNo(XmlElement);
        if OrderNo = '' then
          exit(false);

        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("NpEc Store Code",NpEcStore.Code);
        SalesHeader.SetRange("NpEc Document No.",OrderNo);
        exit(SalesHeader.FindFirst);
    end;

    procedure FindPostedInvoice(XmlElement: DotNet npNetXmlElement;var SalesInvHeader: Record "Sales Invoice Header"): Boolean
    var
        NpEcStore: Record "NpEc Store";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        OrderNo: Text;
    begin
        FindStore(XmlElement,NpEcStore);
        OrderNo := GetOrderNo(XmlElement);
        SalesInvHeader.SetRange("NpEc Store Code",NpEcStore.Code);
        SalesInvHeader.SetRange("NpEc Document No.",OrderNo);
        exit(SalesInvHeader.FindFirst);
    end;

    local procedure FindSalesOrder(XmlElement: DotNet npNetXmlElement;var XmlElement2: DotNet npNetXmlElement)
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        NpXmlDomMgt.FindElement(XmlElement,'/*/sales_order',true,XmlElement2);
    end;

    local procedure FindSellToCustomer(XmlElement: DotNet npNetXmlElement;var XmlElement2: DotNet npNetXmlElement)
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        NpXmlDomMgt.FindElement(XmlElement,'/*/sales_order/sell_to_customer',true,XmlElement2);
    end;

    local procedure FindStore(XmlElement: DotNet npNetXmlElement;var NpEcStore: Record "NpEc Store")
    var
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        StoreCode: Text;
    begin
        StoreCode := NpXmlDomMgt.GetAttributeCode(XmlElement,'/*/sales_order','store_code',MaxStrLen(NpEcStore.Code),true);
        NpEcStore.Get(StoreCode);
    end;

    local procedure GetCurrencyCode(CurrencyCode: Code[10]): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not GLSetup.Get then
          exit(CurrencyCode);

        if GLSetup."LCY Code" = CurrencyCode then
          exit('');

        exit(CurrencyCode);
    end;

    local procedure GetOrderNo(XmlElement: DotNet npNetXmlElement) InvoiceNo: Text
    var
        SalesHeader: Record "Sales Header";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
    begin
        InvoiceNo := NpXmlDomMgt.GetAttributeCode(XmlElement,'/*/sales_order','order_no',MaxStrLen(SalesHeader."NpEc Document No."),true);
        if InvoiceNo = '' then
          Error(Text000,'order_no','sales_order');
    end;

    procedure OrderExists(XmlElement: DotNet npNetXmlElement): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if FindOrder(XmlElement,SalesHeader) then
          exit(true);

        if FindPostedInvoice(XmlElement,SalesInvoiceHeader) then
          exit(true);

        exit(false);
    end;

    local procedure "--- Aux"()
    begin
    end;

    local procedure SetFieldText(var RecRef: RecordRef;FieldNo: Integer;Value: Text)
    var
        "Field": Record "Field";
        FieldRef: FieldRef;
    begin
        if not Field.Get(RecRef.Number,FieldNo) then
          exit;

        FieldRef := RecRef.Field(FieldNo);
        FieldRef.Value := Value;
    end;
}


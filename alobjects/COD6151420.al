codeunit 6151420 "Magento Import Return Order"
{
    // MAG2.12/MHA /20180425  CASE 309647 Object created - Sales Return Order Import
    // MAG2.14/MHA /20180625  CASE 306548 Changed check on Sales Invoice to Sales Credit Memo in OrderExists()
    // MAG2.18/MHA /20190314  CASE 348660 Increased VATBusPostingGroup in InsertCustomer() from 10 to 20 as standard field is increased from NAV2018
    // MAG2.19/MHA /20190306  CASE 347974 Added option to Release Order on Import
    // MAG2.20/MHA /20190411  CASE 349994 Added import of <use_customer_salesperson> in InsertSalesHeader()
    // MAG2.22/MHA /20190621  CASE 359146 Added option to use Blank Code for LCY
    // MAG2.22/MHA /20190710  CASE 360098 Added Customer Template Mapping in InsertCustomer()

    TableNo = "Nc Import Entry";

    trigger OnRun()
    var
        XmlDoc: DotNet npNetXmlDocument;
    begin
        if LoadXmlDoc(XmlDoc) then
          ImportSalesReturnOrders(XmlDoc);
    end;

    var
        MagentoSetup: Record "Magento Setup";
        VATAmountLineTemp: Record "VAT Amount Line" temporary;
        MagentoMgt: Codeunit "Magento Mgt.";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        SalesPost: Codeunit "Sales-Post";
        Initialized: Boolean;
        Error001: Label 'Xml Element sell_to_customer is missing';
        Error002: Label 'Item %1 does not exist in %2';

    local procedure ImportSalesReturnOrders(XmlDoc: DotNet npNetXmlDocument)
    var
        XmlElement: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
    begin
        Initialize;
        if IsNull(XmlDoc) then
          exit;
        XmlElement := XmlDoc.DocumentElement;
        if IsNull(XmlElement) then
          exit;
        if not NpXmlDomMgt.FindNodes(XmlElement,'sales_return_order',XmlNodeList) then
          exit;
        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement := XmlNodeList.ItemOf(i);
          ImportSalesReturnOrder(XmlElement);
        end;
    end;

    local procedure ImportSalesReturnOrder(XmlElement: DotNet npNetXmlElement) Imported: Boolean
    var
        SalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        if IsNull(XmlElement) then
          exit(false);
        if OrderExists(XmlElement) then
          exit(false);

        InsertSalesHeader(XmlElement,SalesHeader);
        InsertSalesLines(XmlElement,SalesHeader);
        InsertPaymentLines(XmlElement,SalesHeader);
        InsertComments(XmlElement,SalesHeader);
        //-MAG2.19 [347974]
        if MagentoSetup."Release Order on Import" then
          ReleaseSalesDoc.PerformManualRelease(SalesHeader);
        //+MAG2.19 [347974]

        exit(true);
    end;

    local procedure "--- Database"()
    begin
    end;

    local procedure InsertCommentLine(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        RecordLink: Record "Record Link";
        CommentLine: Text;
        CommentType: Text;
        OutStream: OutStream;
        LinkID: Integer;
        BinaryWriter: DotNet npNetBinaryWriter;
        Encoding: DotNet npNetEncoding;
    begin
        CommentType := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'type',false);
        CommentLine := NpXmlDomMgt.GetXmlText(XmlElement,'comment',0,true);
        if CommentLine <> '' then begin
          if CommentType <> '' then
            LinkID := SalesHeader.AddLink('',SalesHeader."No." + '-' + CommentType)
          else
            LinkID := SalesHeader.AddLink('',SalesHeader."No.");
          RecordLink.Get(LinkID);
          RecordLink.Type := RecordLink.Type::Note;
          RecordLink.Note.CreateOutStream(OutStream);
          RecordLink."User ID" := '';
          Encoding := Encoding.UTF8;
          BinaryWriter := BinaryWriter.BinaryWriter(OutStream,Encoding);
          if CommentType <> '' then
            BinaryWriter.Write(CommentType + ': ' + CommentLine)
          else
            BinaryWriter.Write(CommentLine);
          RecordLink.Modify(true);
        end;
    end;

    local procedure InsertComments(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        i: Integer;
    begin
        NpXmlDomMgt.FindNodes(XmlElement,'comment_line',XmlNodeList);
        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement2 := XmlNodeList.ItemOf(i);
          InsertCommentLine(XmlElement2,SalesHeader);
        end;
    end;

    local procedure InsertCustomer(XmlElement: DotNet npNetXmlElement;IsContactCustomer: Boolean;var Customer: Record Customer): Boolean
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        CustTemplate: Record "Customer Template";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        ExternalCustomerNo: Text;
        TaxClass: Text;
        ConfigTemplateCode: Code[10];
        VATBusPostingGroup: Code[20];
        NewCust: Boolean;
        PrevCust: Text;
        CustTemplateCode: Code[10];
    begin
        Initialize;
        ExternalCustomerNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'customer_no',false);
        if IsContactCustomer then begin
          if GetContactCustomer(ExternalCustomerNo,Customer)then
            exit;
        end;

        TaxClass := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'tax_class',true);
        NewCust := not GetCustomer(ExternalCustomerNo,XmlElement,Customer);
        if NewCust then begin
          VATBusPostingGroup := MagentoMgt.GetVATBusPostingGroup(TaxClass);

          Customer.Init;
          Customer."No." := '';
          Customer."External Customer No." := ExternalCustomerNo;
          Customer.Insert(true);
          //-MAG2.22 [360098]
          CustTemplateCode := MagentoMgt.GetCustTemplate(Customer);
          if CustTemplateCode <> '' then begin
            CustTemplate.Get(CustTemplateCode);
          //+MAG2.22 [360098]
            Customer."Gen. Bus. Posting Group" := CustTemplate."Gen. Bus. Posting Group";
            Customer."VAT Bus. Posting Group" := CustTemplate."VAT Bus. Posting Group";
            Customer."Customer Posting Group" := CustTemplate."Customer Posting Group";
            //-MAG2.22 [359146]
            Customer."Currency Code" := GetCurrencyCode(CustTemplate."Currency Code");
            //+MAG2.22 [359146]
            Customer."Customer Price Group" := CustTemplate."Customer Price Group";
            Customer."Invoice Disc. Code" := CustTemplate."Invoice Disc. Code";
            Customer."Customer Disc. Group" := CustTemplate."Customer Disc. Group";
            Customer."Allow Line Disc." := CustTemplate."Allow Line Disc.";
            Customer."Payment Terms Code" := CustTemplate."Payment Terms Code";
            Customer."Payment Method Code" := CustTemplate."Payment Method Code";
            Customer."Shipment Method Code" := CustTemplate."Shipment Method Code";
          end else begin
            Customer.Validate("Gen. Bus. Posting Group",VATBusPostingGroup);
            Customer.Validate("VAT Bus. Posting Group",VATBusPostingGroup);
            Customer.Validate("Customer Posting Group",MagentoSetup."Customer Posting Group");
            Customer.Validate("Payment Terms Code",MagentoSetup."Payment Terms Code");
          end;
        end;
        PrevCust := Format(Customer);

        //-MAG2.22 [360098]
        ConfigTemplateCode := MagentoMgt.GetCustConfigTemplate(TaxClass,Customer);
        //+MAG2.22 [360098]
        if (ConfigTemplateCode <> '') and ConfigTemplateHeader.Get(ConfigTemplateCode) then begin
          RecRef.GetTable(Customer);
          ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
          RecRef.SetTable(Customer);
        end;

        Customer.Name := NpXmlDomMgt.GetXmlText(XmlElement,'name',MaxStrLen(Customer.Name),true);
        Customer."Name 2" := NpXmlDomMgt.GetXmlText(XmlElement,'name_2',MaxStrLen(Customer."Name 2"),false);
        Customer.Address := NpXmlDomMgt.GetXmlText(XmlElement,'address',MaxStrLen(Customer.Address),true);
        Customer."Address 2" := NpXmlDomMgt.GetXmlText(XmlElement,'address_2',MaxStrLen(Customer.Address),false);
        Customer."Post Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'post_code',MaxStrLen(Customer."Post Code"),true));
        Customer.City := NpXmlDomMgt.GetXmlText(XmlElement,'city',MaxStrLen(Customer.City),true);
        Customer."Country/Region Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'country_code',MaxStrLen(Customer."Country/Region Code"),false));
        Customer.Contact := NpXmlDomMgt.GetXmlText(XmlElement,'contact',MaxStrLen(Customer.Contact),false);
        Customer."E-Mail" := NpXmlDomMgt.GetXmlText(XmlElement,'email',MaxStrLen(Customer."E-Mail"),true);
        Customer."Phone No." := NpXmlDomMgt.GetXmlText(XmlElement,'phone',MaxStrLen(Customer."Phone No."),false);
        RecRef.GetTable(Customer);
        SetFieldText(RecRef,13600,NpXmlDomMgt.GetXmlText(XmlElement,'ean',13,false));
        RecRef.SetTable(Customer);
        Customer."VAT Registration No." := NpXmlDomMgt.GetXmlText(XmlElement,'vat_registration_no',MaxStrLen(Customer."VAT Registration No."),false);
        Customer."Prices Including VAT" := true;

        if PrevCust = Format(Customer) then
          exit;

        Customer.Modify(true);
    end;

    local procedure InsertPaymentLinePaymentRefund(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        PaymentLine: Record "Magento Payment Line";
        PaymentMapping: Record "Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
        TransactionId: Text;
        PaymentAmount: Decimal;
    begin
        TransactionId := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement,'transaction_id',MaxStrLen(PaymentLine."No."),true));
        Evaluate(PaymentAmount,NpXmlDomMgt.GetXmlText(XmlElement,'amount',0,true),9);
        if PaymentAmount = 0 then
          exit;
        PaymentMapping.SetRange("External Payment Method Code",CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement,'code',true),1,MaxStrLen(PaymentMapping."External Payment Method Code")));

        PaymentMapping.SetRange("External Payment Type",NpXmlDomMgt.GetXmlText(XmlElement,'payment_type',MaxStrLen(PaymentMapping."External Payment Type"),false));
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
        PaymentLine.Description := CopyStr(PaymentMethod.Description + ' ' + SalesHeader."External Order No.",1,MaxStrLen(PaymentLine.Description));
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

    local procedure InsertPaymentLines(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        XmlElement2: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        LineNo: Integer;
        i: Integer;
    begin
        if not NpXmlDomMgt.FindNodes(XmlElement,'payment_refunds/payment_refund',XmlNodeList) then
          exit;

        for i := 0 to XmlNodeList.Count - 1 do begin
          XmlElement2 := XmlNodeList.Item(i);
          InsertPaymentLinePaymentRefund(XmlElement2,SalesHeader,LineNo);
        end;
    end;

    local procedure InsertSalesHeader(XmlElement: DotNet npNetXmlElement;var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        MagentoWebsite: Record "Magento Website";
        ShipmentMapping: Record "Magento Shipment Mapping";
        PaymentMapping: Record "Magento Payment Mapping";
        XmlElement2: DotNet npNetXmlElement;
        XmlElement3: DotNet npNetXmlElement;
        NodeList: DotNet npNetXmlNodeList;
        RecRef: RecordRef;
        OrderNo: Code[20];
        WebsiteCode: Code[20];
        i: Integer;
    begin
        Initialize;
        Clear(SalesHeader);
        OrderNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'return_order_no',true);

        if not NpXmlDomMgt.FindNode(XmlElement,'sell_to_customer',XmlElement2) then
          Error(Error001);
        InsertCustomer(XmlElement2,MagentoSetup."Customers Enabled",Customer);
        SalesHeader.Init;
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
        SalesHeader."No." := '';
        SalesHeader."External Order No." := CopyStr(OrderNo,1,MaxStrLen(SalesHeader."External Order No."));
        SalesHeader."External Document No." := NpXmlDomMgt.GetXmlText(XmlElement,'external_document_no',MaxStrLen(SalesHeader."External Document No."),false);
        if SalesHeader."External Document No." = '' then
          SalesHeader."External Document No." := SalesHeader."External Order No.";
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.",Customer."No.");
        SalesHeader."Prices Including VAT" := true;

        if NpXmlDomMgt.FindNode(XmlElement,'ship_to_customer',XmlElement2) then begin
          SalesHeader."Ship-to Name" := NpXmlDomMgt.GetXmlText(XmlElement2,'name',MaxStrLen(SalesHeader."Ship-to Name"),true);
          SalesHeader."Ship-to Name 2" := NpXmlDomMgt.GetXmlText(XmlElement2,'name_2',MaxStrLen(SalesHeader."Ship-to Name 2"),false);
          SalesHeader."Ship-to Address" := NpXmlDomMgt.GetXmlText(XmlElement2,'address',MaxStrLen(SalesHeader."Ship-to Address"),true);
          SalesHeader."Ship-to Address 2" := NpXmlDomMgt.GetXmlText(XmlElement2,'address_2',MaxStrLen(SalesHeader."Ship-to Address 2"),false);
          SalesHeader."Ship-to Post Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement2,'post_code',MaxStrLen(SalesHeader."Ship-to Post Code"),true));
          SalesHeader."Ship-to City" := NpXmlDomMgt.GetXmlText(XmlElement2,'city',MaxStrLen(SalesHeader."Ship-to City"),true);
          SalesHeader."Ship-to Country/Region Code" := UpperCase(NpXmlDomMgt.GetXmlText(XmlElement2,'country_code',MaxStrLen(SalesHeader."Ship-to Country/Region Code"),false));
          SalesHeader."Ship-to Contact" := NpXmlDomMgt.GetXmlText(XmlElement2,'contact',MaxStrLen(SalesHeader."Ship-to Contact"),false);
        end;

        SalesHeader.Validate("Salesperson Code",MagentoSetup."Salesperson Code");
        //-MAG2.20 [349994]
        if NpXmlDomMgt.GetElementBoolean(XmlElement,'use_customer_salesperson',false) and (Customer."Salesperson Code" <> '') then
          SalesHeader.Validate("Salesperson Code",Customer."Salesperson Code");
        //+MAG2.20 [349994]

        if NpXmlDomMgt.FindNode(XmlElement,'shipment',XmlElement2) then begin
          ShipmentMapping.SetRange("External Shipment Method Code",NpXmlDomMgt.GetXmlText(XmlElement2,'shipment_method',MaxStrLen(ShipmentMapping."External Shipment Method Code"),true));
          ShipmentMapping.FindFirst;
          SalesHeader.Validate("Shipment Method Code",ShipmentMapping."Shipment Method Code");
          SalesHeader.Validate("Shipping Agent Code",ShipmentMapping."Shipping Agent Code");
          SalesHeader.Validate("Shipping Agent Service Code",ShipmentMapping."Shipping Agent Service Code");
          RecRef.GetTable(SalesHeader);
          SetFieldText(RecRef,6014420,NpXmlDomMgt.GetXmlText(XmlElement2,'shipment_service',10,false));
          RecRef.SetTable(SalesHeader);
        end;

        if NpXmlDomMgt.FindNodes(XmlElement,'payment_refunds/payment_refund',NodeList) then begin
          i := 0;
          while (i < NodeList.Count) and (SalesHeader."Payment Method Code" = '') do begin
            XmlElement2 := NodeList.Item(i);
            PaymentMapping.SetRange("External Payment Method Code",
              CopyStr(NpXmlDomMgt.GetXmlAttributeText(XmlElement2,'code',true),1,MaxStrLen(PaymentMapping."External Payment Method Code")));
            PaymentMapping.SetRange("External Payment Type",
              NpXmlDomMgt.GetXmlText(XmlElement2,'payment_type',MaxStrLen(PaymentMapping."External Payment Type"),false));
            if not PaymentMapping.FindFirst then begin
              PaymentMapping.SetRange("External Payment Type");
              PaymentMapping.FindFirst;
            end;
            SalesHeader.Validate("Payment Method Code",PaymentMapping."Payment Method Code");

            i += 1;
          end;
        end;

        WebsiteCode := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'website_code',true);
        if (MagentoWebsite.Get(WebsiteCode)) and (MagentoWebsite."Global Dimension 1 Code" <> '') then begin
          SalesHeader.Validate(SalesHeader."Shortcut Dimension 1 Code",MagentoWebsite."Global Dimension 1 Code");
          SalesHeader.Validate("Shortcut Dimension 2 Code",MagentoWebsite."Global Dimension 2 Code");
        end;
        SalesHeader.Validate("Location Code",MagentoWebsite."Location Code");
        //-MAG2.22 [359146]
        SalesHeader.Validate("Currency Code",GetCurrencyCode(NpXmlDomMgt.GetElementCode(XmlElement,'currency_code',MaxStrLen(SalesHeader."Currency Code"),false)));
        //+MAG2.22 [359146]
        SalesHeader.Modify(true);
    end;

    local procedure InsertSalesLines(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header")
    var
        SalesLineTemp: Record "Sales Line" temporary;
        XmlElementLine: DotNet npNetXmlElement;
        XmlElementLines: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
        LineNo: Integer;
        i: Integer;
    begin
        LineNo := 0;

        if NpXmlDomMgt.FindNodes(XmlElement,'sales_return_order_lines/sales_return_order_line',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElementLine := XmlNodeList.ItemOf(i);
            InsertSalesLine(XmlElementLine,SalesHeader,LineNo);
          end;

        if NpXmlDomMgt.FindNodes(XmlElement,'payment_refunds/payment_refund [payment_fee_refund != 0]',XmlNodeList) then
          for i := 0 to XmlNodeList.Count - 1 do begin
            XmlElementLine := XmlNodeList.ItemOf(i);
            InsertSalesLinePaymentFeeRefund(XmlElementLine,SalesHeader,LineNo);
          end;

        if NpXmlDomMgt.FindNode(XmlElement,'shipment_refund [shipment_fee_refund != 0]',XmlElementLine) then
          InsertSalesLineShipmentFeeRefund(XmlElementLine,SalesHeader,LineNo);

        SalesPost.GetSalesLines(SalesHeader,SalesLineTemp,0);
        SalesLineTemp.CalcVATAmountLines(0,SalesHeader,SalesLineTemp,VATAmountLineTemp);
        SalesLineTemp.UpdateVATOnLines(0,SalesHeader,SalesLineTemp,VATAmountLineTemp);
    end;

    local procedure InsertSalesLine(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SalesLine: Record "Sales Line";
        SalesCommentLine: Record "Sales Comment Line";
        ShipmentMapping: Record "Magento Shipment Mapping";
        XmlElementGiftVoucher: DotNet npNetXmlElement;
        XmlElementGiftVouchers: DotNet npNetXmlElement;
        XmlNodeList: DotNet npNetXmlNodeList;
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
        DiscountAmount: Decimal;
        DiscountPct: Decimal;
        i: Integer;
        Position: Integer;
        TableId: Integer;
    begin
        Initialize;
        case LowerCase(NpXmlDomMgt.GetXmlAttributeText(XmlElement,'type',true)) of
          'comment' :
            begin
              LineNo += 10000;
              SalesLine.Init;
              SalesLine."Document Type" := SalesHeader."Document Type";
              SalesLine."Document No." := SalesHeader."No.";
              SalesLine."Line No." := LineNo;
              SalesLine.Insert(true);
              SalesLine.Validate(Type,SalesLine.Type::" ");
              SalesLine.Description := NpXmlDomMgt.GetXmlText(XmlElement,'description',MaxStrLen(SalesLine.Description),true);
              SalesLine.Modify(true);
            end;
          'item' :
            begin
              ExternalItemNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'external_no',true);
              Position := StrPos(ExternalItemNo,'_');
              if Position = 0 then begin
                ItemNo := CopyStr(ExternalItemNo,1,MaxStrLen(SalesHeader."No."));
                VariantCode := '';
              end else begin
                ItemNo := CopyStr(CopyStr(ExternalItemNo,1,Position - 1),1,MaxStrLen(SalesHeader."No."));
                VariantCode := CopyStr(CopyStr(ExternalItemNo,Position + 1),1,MaxStrLen(SalesHeader."No."));
              end;
              if not Item.Get(ItemNo) then
                if not (TranslateBarcodeToItemVariant(ExternalItemNo,ItemNo,VariantCode,TableId)) then
                  Error(StrSubstNo(Error002,ItemNo,TableId));

              if VariantCode <> '' then
                ItemVariant.Get(ItemNo,VariantCode);
              Evaluate(UnitPrice,NpXmlDomMgt.GetXmlText(XmlElement,'unit_price_incl_vat',0,true),9);
              Evaluate(Quantity,NpXmlDomMgt.GetXmlText(XmlElement,'quantity',0,true),9);
              Evaluate(VatPct,NpXmlDomMgt.GetXmlText(XmlElement,'vat_percent',0,true),9);
              Evaluate(LineAmount,NpXmlDomMgt.GetXmlText(XmlElement,'line_amount_incl_vat',0,true),9);
              Evaluate(UnitofMeasure,NpXmlDomMgt.GetXmlText(XmlElement,'unit_of_measure',MaxStrLen(SalesLine."Unit of Measure Code"),false));
              LineNo += 10000;
              SalesLine.Init;
              SalesLine."Document Type" := SalesHeader."Document Type";
              SalesLine."Document No." := SalesHeader."No.";
              SalesLine."Line No." := LineNo;
              SalesLine.Insert(true);

              SalesLine.Validate(Type,SalesLine.Type::Item);
              SalesLine.Validate("No.",ItemNo);
              SalesLine."Variant Code" := VariantCode;
              SalesLine.Validate(Quantity,Quantity);
              if not (UnitofMeasure in ['','_BLANK_']) then
                SalesLine.Validate("Unit of Measure Code",UnitofMeasure);
              SalesLine.Validate("VAT %",VatPct);
              if UnitPrice > 0 then
                SalesLine.Validate("Unit Price",UnitPrice)
              else
                SalesLine."Unit Price" := UnitPrice;

              if SalesLine."Unit Price" <> 0 then
                SalesLine.Validate("Line Amount",LineAmount)
              else
                SalesLine."Line Amount" := LineAmount;
              SalesLine.Modify(true);
            end;
          'fee' :
            begin
              Evaluate(Quantity2,NpXmlDomMgt.GetXmlText(XmlElement,'quantity',0,true),9);
              Evaluate(LineAmountIncVat,NpXmlDomMgt.GetXmlText(XmlElement,'line_amount_incl_vat',0,true),9);
              if (Quantity2 = 0) and (LineAmountIncVat = 0) then begin
                LineNo += 10000;
                SalesCommentLine.Init;
                SalesCommentLine."Document Type" := SalesHeader."Document Type";
                SalesCommentLine."No." := SalesHeader."No.";
                SalesCommentLine."Document Line No." := 0;
                SalesCommentLine."Line No." := LineNo;
                SalesCommentLine.Date := Today;
                SalesCommentLine.Comment := NpXmlDomMgt.GetXmlText(XmlElement,'description',MaxStrLen(SalesLine.Description),true);
                SalesCommentLine.Insert(true);
              end else begin
                LineNo += 10000;
                SalesLine.Init;
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := LineNo;
                SalesLine.Insert(true);
                ShipmentMapping.SetRange("External Shipment Method Code",NpXmlDomMgt.GetXmlAttributeText(XmlElement,'external_no',false));
                ShipmentMapping.FindFirst;
                SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
                SalesLine.Validate("No.",ShipmentMapping."Shipment Fee No.");
                if Quantity2 <> 0 then
                 SalesLine.Validate(Quantity,Quantity2);
                Evaluate(UnitPrice2,NpXmlDomMgt.GetXmlText(XmlElement,'unit_price_incl_vat',0,true),9);
                SalesLine.Validate("Unit Price",UnitPrice2);
                SalesLine.Description := NpXmlDomMgt.GetXmlText(XmlElement,'description',MaxStrLen(SalesLine.Description),true);
                SalesLine.Modify(true);
              end;
            end;
        end;
    end;

    local procedure InsertSalesLinePaymentFeeRefund(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        PaymentFeeRefund: Decimal;
    begin
        if not Evaluate(PaymentFeeRefund,NpXmlDomMgt.GetXmlText(XmlElement,'payment_fee_refund',0,false),9) then
          exit;
        if PaymentFeeRefund = 0 then
          exit;
        Initialize;
        MagentoSetup.TestField("Payment Fee Account No.");

        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.",MagentoSetup."Payment Fee Account No.");
        SalesLine.Validate("Unit Price",PaymentFeeRefund);
        SalesLine.Validate(Quantity,1);
        SalesLine.Modify(true);
    end;

    local procedure InsertSalesLineShipmentFeeRefund(XmlElement: DotNet npNetXmlElement;SalesHeader: Record "Sales Header";var LineNo: Integer)
    var
        SalesLine: Record "Sales Line";
        ShipmentMapping: Record "Magento Shipment Mapping";
        ShipmentFeeRefund: Decimal;
    begin
        if not Evaluate(ShipmentFeeRefund,NpXmlDomMgt.GetXmlText(XmlElement,'shipment_fee_refund',0,false),9) then
          exit;

        ShipmentMapping.SetRange("External Shipment Method Code",NpXmlDomMgt.GetXmlText(XmlElement,'shipment_method',MaxStrLen(ShipmentMapping."External Shipment Method Code"),true));
        ShipmentMapping.FindFirst;
        ShipmentMapping.TestField("Shipment Fee No.");

        LineNo += 10000;
        SalesLine.Init;
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type,SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.",ShipmentMapping."Shipment Fee No.");
        SalesLine.Validate("Unit Price",ShipmentFeeRefund);
        SalesLine.Validate(Quantity,1);
        SalesLine.Modify(true);
    end;

    local procedure "--- Get/Check"()
    begin
    end;

    local procedure GetContactCustomer(ContactNo: Code[20];var Customer: Record Customer): Boolean
    var
        Contact: Record Contact;
        ContBusRel: Record "Contact Business Relation";
    begin
        Initialize;
        Clear(Contact);
        if not Contact.Get(ContactNo) then
          exit(false);

        ContBusRel.SetRange("Contact No.",Contact."Company No.");
        ContBusRel.SetRange("Link to Table",ContBusRel."Link to Table"::Customer);
        ContBusRel.SetFilter("No.",'<>%1','');
        if not ContBusRel.FindFirst then
          exit(false);

        exit(Customer.Get(ContBusRel."No."));
    end;

    local procedure GetCustomer(ExternalCustomerNo: Code[20];XmlElement: DotNet npNetXmlElement;var Customer: Record Customer): Boolean
    begin
        Initialize;
        Clear(Customer);
        Customer.SetRange("E-Mail",NpXmlDomMgt.GetXmlText(XmlElement,'email',MaxStrLen(Customer."E-Mail"),false));
        exit(Customer.FindFirst and (Customer."E-Mail" <> ''));
    end;

    local procedure GetCurrencyCode(CurrencyCode: Code[10]): Code[10]
    var
        GLSetup: Record "General Ledger Setup";
    begin
        //-MAG2.22 [359146]
        Initialize();

        if not MagentoSetup."Use Blank Code for LCY" then
            exit(CurrencyCode);

        GLSetup.Get;
        if GLSetup."LCY Code" = CurrencyCode then
          exit('');

        exit(CurrencyCode);
        //+MAG2.22 [359146]
    end;

    local procedure OrderExists(XmlElement: DotNet npNetXmlElement): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        OrderNo: Code[20];
    begin
        OrderNo := NpXmlDomMgt.GetXmlAttributeText(XmlElement,'return_order_no',true);
        if OrderNo = '' then
          exit(true);

        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("External Order No.",CopyStr(OrderNo,1,MaxStrLen(SalesHeader."External Order No.")));
        if SalesHeader.FindFirst then
          exit(true);

        //-MAG2.14 [306548]
        // SalesInvHeader.SETRANGE("External Order No.",COPYSTR(OrderNo,1,MAXSTRLEN(SalesInvHeader."External Order No.")));
        // IF SalesInvHeader.FINDFIRST THEN
        //  EXIT(TRUE);
        SalesCrMemoHeader.SetRange("External Order No.",CopyStr(OrderNo,1,MaxStrLen(SalesCrMemoHeader."External Order No.")));
        if SalesCrMemoHeader.FindFirst then
          exit(true);
        //+MAG2.14 [306548]

        exit(false);
    end;

    local procedure "--- Set"()
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

    local procedure "--- Misc"()
    begin
    end;

    procedure Initialize()
    begin
        if not Initialized then begin
          MagentoSetup.Get;
          Initialized := true;
        end;
    end;

    local procedure LoadXmlDoc(NaviConnectImportEntry: Record "Nc Import Entry";var XmlDoc: DotNet npNetXmlDocument): Boolean
    var
        InStr: InStream;
    begin
        NaviConnectImportEntry.CalcFields("Document Source");
        if not NaviConnectImportEntry."Document Source".HasValue then
          exit(false);

        NaviConnectImportEntry."Document Source".CreateInStream(InStr);
        if not IsNull(XmlDoc) then
          Clear(XmlDoc);
        XmlDoc := XmlDoc.XmlDocument;
        XmlDoc.Load(InStr);
        NpXmlDomMgt.RemoveNameSpaces(XmlDoc);
        Clear(InStr);
        exit(true);
    end;

    local procedure TranslateBarcodeToItemVariant(Barcode: Text[50];var ItemNo: Code[20];var VariantCode: Code[10];var ResolvingTable: Integer) Found: Boolean
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemVariant: Record "Item Variant";
        GenericSetupMgt: Codeunit "Magento Generic Setup Mgt.";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        ResolvingTable := 0;
        ItemNo := '';
        VariantCode := '';
        if (Barcode = '') then exit (false);

        if (StrLen (Barcode) <= MaxStrLen (Item."No.")) then begin
          if (Item.Get (UpperCase(Barcode))) then begin
            ResolvingTable := DATABASE::Item;
            ItemNo := Item."No.";
            exit (true);
          end;
        end;

        with ItemCrossReference do begin
          if (StrLen (Barcode) <= MaxStrLen ("Cross-Reference No.")) then begin
            SetCurrentKey ("Cross-Reference Type", "Cross-Reference No.");
            SetFilter ("Cross-Reference Type", '=%1', "Cross-Reference Type"::"Bar Code");
            SetFilter ("Cross-Reference No.", '=%1', UpperCase (Barcode));
            SetFilter ("Discontinue Bar Code", '=%1', false);
            if (FindFirst ()) then begin
              ResolvingTable := DATABASE::"Item Cross Reference";
              ItemNo := "Item No.";
              VariantCode := "Variant Code";
              exit (true);
            end;
          end;
        end;

        if not GenericSetupMgt.OpenRecRef(6014416,RecRef) then
          exit(false);

        if not GenericSetupMgt.OpenFieldRef(RecRef,2,FieldRef) then
          exit(false);
        if StrLen(Barcode) > FieldRef.Length then
          exit(false);
        FieldRef.SetFilter('=%1', UpperCase (Barcode));

        if not GenericSetupMgt.OpenFieldRef(RecRef,4,FieldRef) then
          exit(false);
        FieldRef.SetFilter('=%1',0);

        if not RecRef.FindFirst then
          exit(false);

        if not GenericSetupMgt.OpenFieldRef(RecRef,1,FieldRef) then
          exit(false);

        if not Item.Get(CopyStr(UpperCase(Format(FieldRef.Value)),1,MaxStrLen(Item."No."))) then
          exit (false);

        if GenericSetupMgt.OpenFieldRef(RecRef,6,FieldRef) then begin
          if (Format(FieldRef.Value) <> '') and (not ItemVariant.Get(Item."No.",CopyStr(UpperCase(Format(FieldRef.Value)),1,MaxStrLen(ItemVariant.Code)))) then
              exit(false);
        end;

        ResolvingTable := DATABASE::"Alternative No.";
        ItemNo := Item."No.";
        VariantCode := ItemVariant.Code;
        exit(true);
    end;
}


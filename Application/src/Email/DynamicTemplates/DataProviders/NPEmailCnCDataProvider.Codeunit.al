codeunit 6151082 "NPR NPEmailCnCDataProvider" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    var
        _DynTempDataProvSubs: Codeunit "NPR DynTempDataProvSubs";

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        NpCsDocument: Record "NPR NpCs Document";
        Customer: Record Customer;
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
        JObject, CustomJObject : JsonObject;
        CustomerLanguageCode: Code[10];
        WrongRecordReceivedErr: Label 'The code received a record of an unknown type. Most likely a wrong data driver was used on the Dynamic Template. This is a programming bug.', Locked = true;
        // Locale-invariant option-member identifiers, mirroring the OptionMembers on "NPR NpCs Document". Keep in sync with the table.
        TypeMembersTok: Label 'Send to Store,Collect in Store', Locked = true;
        ProcessingStatusMembersTok: Label ' ,Pending,Confirmed,Rejected,Expired', Locked = true;
        DeliveryStatusMembersTok: Label ' ,Ready,Delivered,Expired', Locked = true;
    begin
        if RecRef.Number() <> Database::"NPR NpCs Document" then
            Error(WrongRecordReceivedErr);

        RecRef.SetTable(NpCsDocument);

        if not Customer.Get(NpCsDocument.ResolveCustomerNo()) then
            Clear(Customer);
        CustomerLanguageCode := Customer."Language Code";

        JObject.Add('document_no', NpCsDocument."Document No.");
        JObject.Add('reference_no', NpCsDocument."Reference No.");
        JObject.Add('document_type', NpCsDocument."Document Type".Names.Get(NpCsDocument."Document Type".Ordinals.IndexOf(NpCsDocument."Document Type".AsInteger())));
        JObject.Add('type', SelectStr(NpCsDocument.Type + 1, TypeMembersTok));
        JObject.Add('processing_status', SelectStr(NpCsDocument."Processing Status" + 1, ProcessingStatusMembersTok));
        JObject.Add('delivery_status', SelectStr(NpCsDocument."Delivery Status" + 1, DeliveryStatusMembersTok));
        JObject.Add('from_store_code', NpCsDocument."From Store Code");
        JObject.Add('to_store_code', NpCsDocument."To Store Code");
        JObject.Add('customer_no', Customer."No.");
        JObject.Add('sell_to_customer_name', NpCsDocument."Sell-to Customer Name");
        JObject.Add('customer_email', NpCsDocument."Customer E-mail");
        JObject.Add('customer_phone_no', NpCsDocument."Customer Phone No.");
        JObject.Add('ship_to_contact', NpCsDocument."Ship-to Contact");
        JObject.Add('processing_expires_at', NpCsDocument."Processing expires at");
        JObject.Add('processing_expires_at_formatted', DataProviderHelper.FormatToTextFromLanguage(NpCsDocument."Processing expires at", CustomerLanguageCode));
        JObject.Add('delivery_expires_at', NpCsDocument."Delivery expires at");
        JObject.Add('delivery_expires_at_formatted', DataProviderHelper.FormatToTextFromLanguage(NpCsDocument."Delivery expires at", CustomerLanguageCode));
        _DynTempDataProvSubs.OnAfterCnCAddHeaderFields(NpCsDocument, JObject);

        AddCustomerCardFields(JObject, NpCsDocument, Customer);
        AddSalesDocumentHeaderFields(JObject, NpCsDocument, CustomerLanguageCode);
        AddTotalsAndLines(JObject, NpCsDocument, CustomerLanguageCode);

        _DynTempDataProvSubs.OnAfterCnCGetContent(NpCsDocument, CustomJObject);
        JObject.Add('custom_fields', CustomJObject);

        exit(JObject);
    end;

    procedure GenerateContentExample(): JsonObject
    var
        JObject, JObjectLine, CustomJObject : JsonObject;
        JArrLines: JsonArray;
    begin
        JObject.Add('document_no', 'CNC-001234');
        JObject.Add('reference_no', 'REF-001234');
        JObject.Add('document_type', 'Order');
        JObject.Add('type', 'Collect in Store');
        JObject.Add('processing_status', 'Confirmed');
        JObject.Add('delivery_status', 'Ready');
        JObject.Add('from_store_code', 'STORE-DK-01');
        JObject.Add('to_store_code', 'STORE-DK-02');
        JObject.Add('customer_no', 'C-00001');
        JObject.Add('sell_to_customer_name', 'John Doe');
        JObject.Add('customer_email', 'customer@example.com');
        JObject.Add('customer_phone_no', '+4512345678');
        JObject.Add('ship_to_contact', 'John Doe');
        JObject.Add('processing_expires_at', CreateDateTime(20240117D, 170000T));
        JObject.Add('processing_expires_at_formatted', Format(CreateDateTime(20240117D, 170000T), 0, '<Standard Format,0>'));
        JObject.Add('delivery_expires_at', CreateDateTime(20240122D, 170000T));
        JObject.Add('delivery_expires_at_formatted', Format(CreateDateTime(20240122D, 170000T), 0, '<Standard Format,0>'));
        _DynTempDataProvSubs.OnAfterCnCAddHeaderFieldsExample(JObject);

        JObject.Add('customer_address', 'Main Street 1');
        JObject.Add('customer_address_2', '');
        JObject.Add('customer_post_code', '1000');
        JObject.Add('customer_city', 'Copenhagen');
        JObject.Add('customer_country_region_code', 'DK');
        JObject.Add('customer_language_code', 'DAN');
        _DynTempDataProvSubs.OnAfterCnCAddCustomerCardFieldsExample(JObject);

        JObject.Add('document_date', 20240115D);
        JObject.Add('document_date_formatted', Format(20240115D, 0, '<Standard Format,0>'));
        JObject.Add('currency_code', 'DKK');
        JObject.Add('external_document_no', 'EXT-001234');
        JObject.Add('shipment_method_code', 'PICKUP');
        JObject.Add('shipment_method_description', 'In-store pickup');
        JObject.Add('payment_method_code', 'CARD');
        JObject.Add('payment_method_description', 'Credit / Debit card');
        _DynTempDataProvSubs.OnAfterCnCAddSalesDocumentHeaderFieldsExample(JObject);

        JObject.Add('total_amount_excl_vat', 100.0);
        JObject.Add('total_amount_excl_vat_formatted', Format(100.0, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('total_amount_incl_vat', 125.0);
        JObject.Add('total_amount_incl_vat_formatted', Format(125.0, 0, '<Precision,2><Standard Format,2>'));
        _DynTempDataProvSubs.OnAfterCnCAddTotalsExample(JObject);

        JObjectLine.Add('line_no', 10000);
        JObjectLine.Add('no', '1000');
        JObjectLine.Add('variant_code', '');
        JObjectLine.Add('description', 'Sample item');
        JObjectLine.Add('description_2', 'Color: Black, Size: L');
        JObjectLine.Add('quantity', 1);
        JObjectLine.Add('quantity_formatted', Format(1, 0, '<Standard Format,0>'));
        JObjectLine.Add('unit_price', 125.0);
        JObjectLine.Add('unit_price_formatted', Format(125.0, 0, '<Precision,2><Standard Format,2>'));
        JObjectLine.Add('line_amount_excl_vat', 100.0);
        JObjectLine.Add('line_amount_excl_vat_formatted', Format(100.0, 0, '<Precision,2><Standard Format,2>'));
        JObjectLine.Add('line_amount_incl_vat', 125.0);
        JObjectLine.Add('line_amount_incl_vat_formatted', Format(125.0, 0, '<Precision,2><Standard Format,2>'));
        JObjectLine.Add('line_discount_amount', 0.0);
        JObjectLine.Add('line_discount_amount_formatted', Format(0.0, 0, '<Precision,2><Standard Format,2>'));
        JObjectLine.Add('vat_pct', 25.0);
        JObjectLine.Add('vat_pct_formatted', Format(25.0, 0, '<Precision,2><Standard Format,2>'));
        _DynTempDataProvSubs.OnAfterCnCAddDocumentLineExample(JObjectLine);
        JArrLines.Add(JObjectLine);
        JObject.Add('document_lines', JArrLines);

        _DynTempDataProvSubs.OnAfterCnCGenerateContentExample(CustomJObject);
        JObject.Add('custom_fields', CustomJObject);

        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
        // No attachments for C&C notifications
    end;

    local procedure AddCustomerCardFields(var JObject: JsonObject; var NpCsDocument: Record "NPR NpCs Document"; var Customer: Record Customer)
    begin
        JObject.Add('customer_address', Customer.Address);
        JObject.Add('customer_address_2', Customer."Address 2");
        JObject.Add('customer_post_code', Customer."Post Code");
        JObject.Add('customer_city', Customer.City);
        JObject.Add('customer_country_region_code', Customer."Country/Region Code");
        JObject.Add('customer_language_code', Customer."Language Code");
        _DynTempDataProvSubs.OnAfterCnCAddCustomerCardFields(NpCsDocument, Customer, JObject);
    end;

    local procedure AddSalesDocumentHeaderFields(var JObject: JsonObject; var NpCsDocument: Record "NPR NpCs Document"; LanguageCode: Code[10])
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
        DocumentDate: Date;
        CurrencyCode: Code[10];
        ExternalDocumentNo: Code[35];
        ShipmentMethodCode: Code[10];
        PaymentMethodCode: Code[10];
        ShipmentMethodDescription: Text[100];
        PaymentMethodDescription: Text[100];
    begin
        case NpCsDocument."Document Type" of
            NpCsDocument."Document Type"::Quote,
            NpCsDocument."Document Type"::Order,
            NpCsDocument."Document Type"::Invoice,
            NpCsDocument."Document Type"::"Credit Memo",
            NpCsDocument."Document Type"::"Blanket Order",
            NpCsDocument."Document Type"::"Return Order":
                begin
                    SalesHeader.SetLoadFields("Document Date", "Currency Code", "External Document No.", "Shipment Method Code", "Payment Method Code");
                    if SalesHeader.Get(NpCsDocument."Document Type", NpCsDocument."Document No.") then begin
                        DocumentDate := SalesHeader."Document Date";
                        CurrencyCode := SalesHeader."Currency Code";
                        ExternalDocumentNo := SalesHeader."External Document No.";
                        ShipmentMethodCode := SalesHeader."Shipment Method Code";
                        PaymentMethodCode := SalesHeader."Payment Method Code";
                    end;
                end;
            NpCsDocument."Document Type"::"Posted Invoice":
                begin
                    SalesInvoiceHeader.SetLoadFields("Document Date", "Currency Code", "External Document No.", "Shipment Method Code", "Payment Method Code");
                    if SalesInvoiceHeader.Get(NpCsDocument."Document No.") then begin
                        DocumentDate := SalesInvoiceHeader."Document Date";
                        CurrencyCode := SalesInvoiceHeader."Currency Code";
                        ExternalDocumentNo := SalesInvoiceHeader."External Document No.";
                        ShipmentMethodCode := SalesInvoiceHeader."Shipment Method Code";
                        PaymentMethodCode := SalesInvoiceHeader."Payment Method Code";
                    end;
                end;
            NpCsDocument."Document Type"::"Posted Credit Memo":
                begin
                    SalesCrMemoHeader.SetLoadFields("Document Date", "Currency Code", "External Document No.", "Shipment Method Code", "Payment Method Code");
                    if SalesCrMemoHeader.Get(NpCsDocument."Document No.") then begin
                        DocumentDate := SalesCrMemoHeader."Document Date";
                        CurrencyCode := SalesCrMemoHeader."Currency Code";
                        ExternalDocumentNo := SalesCrMemoHeader."External Document No.";
                        ShipmentMethodCode := SalesCrMemoHeader."Shipment Method Code";
                        PaymentMethodCode := SalesCrMemoHeader."Payment Method Code";
                    end;
                end;
        end;

        ShipmentMethodDescription := GetShipmentMethodDescription(ShipmentMethodCode);
        PaymentMethodDescription := GetPaymentMethodDescription(PaymentMethodCode);

        JObject.Add('document_date', DocumentDate);
        JObject.Add('document_date_formatted', DataProviderHelper.FormatToTextFromLanguage(DocumentDate, LanguageCode));
        JObject.Add('currency_code', CurrencyCode);
        JObject.Add('external_document_no', ExternalDocumentNo);
        JObject.Add('shipment_method_code', ShipmentMethodCode);
        JObject.Add('shipment_method_description', ShipmentMethodDescription);
        JObject.Add('payment_method_code', PaymentMethodCode);
        JObject.Add('payment_method_description', PaymentMethodDescription);
        _DynTempDataProvSubs.OnAfterCnCAddSalesDocumentHeaderFields(NpCsDocument, JObject);
    end;

    local procedure GetShipmentMethodDescription(ShipmentMethodCode: Code[10]): Text[100]
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        if ShipmentMethodCode = '' then
            exit('');
        ShipmentMethod.SetLoadFields(Description);
        if ShipmentMethod.Get(ShipmentMethodCode) then
            exit(ShipmentMethod.Description);
    end;

    local procedure GetPaymentMethodDescription(PaymentMethodCode: Code[10]): Text[100]
    var
        PaymentMethod: Record "Payment Method";
    begin
        if PaymentMethodCode = '' then
            exit('');
        PaymentMethod.SetLoadFields(Description);
        if PaymentMethod.Get(PaymentMethodCode) then
            exit(PaymentMethod.Description);
    end;

    local procedure AddTotalsAndLines(var JObject: JsonObject; var NpCsDocument: Record "NPR NpCs Document"; LanguageCode: Code[10])
    var
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
        JArrLines: JsonArray;
        TotalExclVat: Decimal;
        TotalInclVat: Decimal;
    begin
        case NpCsDocument."Document Type" of
            NpCsDocument."Document Type"::Quote,
            NpCsDocument."Document Type"::Order,
            NpCsDocument."Document Type"::Invoice,
            NpCsDocument."Document Type"::"Credit Memo",
            NpCsDocument."Document Type"::"Blanket Order",
            NpCsDocument."Document Type"::"Return Order":
                AddLinesFromSalesHeader(NpCsDocument."Document Type", NpCsDocument."Document No.", JArrLines, TotalExclVat, TotalInclVat, LanguageCode);
            NpCsDocument."Document Type"::"Posted Invoice":
                AddLinesFromPostedInvoice(NpCsDocument."Document No.", JArrLines, TotalExclVat, TotalInclVat, LanguageCode);
            NpCsDocument."Document Type"::"Posted Credit Memo":
                AddLinesFromPostedCrMemo(NpCsDocument."Document No.", JArrLines, TotalExclVat, TotalInclVat, LanguageCode);
        end;

        JObject.Add('total_amount_excl_vat', TotalExclVat);
        JObject.Add('total_amount_excl_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(TotalExclVat, LanguageCode));
        JObject.Add('total_amount_incl_vat', TotalInclVat);
        JObject.Add('total_amount_incl_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(TotalInclVat, LanguageCode));
        _DynTempDataProvSubs.OnAfterCnCAddTotals(NpCsDocument, JObject);
        JObject.Add('document_lines', JArrLines);
    end;

    local procedure AddLinesFromSalesHeader(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; var JArrLines: JsonArray; var TotalExclVat: Decimal; var TotalInclVat: Decimal; LanguageCode: Code[10])
    var
        SalesLine: Record "Sales Line";
        JObjectLine: JsonObject;
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
    begin
        SalesLine.SetRange("Document Type", DocumentType);
        SalesLine.SetRange("Document No.", DocumentNo);
        SalesLine.SetFilter(Type, '<>%1', SalesLine.Type::" ");
        SalesLine.SetFilter("No.", '<>%1', '');
        SalesLine.SetLoadFields("Line No.", "No.", "Variant Code", Description, "Description 2", Quantity, "Unit Price", Amount, "Amount Including VAT", "Line Discount Amount", "VAT %");
        if SalesLine.FindSet() then
            repeat
                Clear(JObjectLine);
                JObjectLine.Add('line_no', SalesLine."Line No.");
                JObjectLine.Add('no', SalesLine."No.");
                JObjectLine.Add('variant_code', SalesLine."Variant Code");
                JObjectLine.Add('description', SalesLine.Description);
                JObjectLine.Add('description_2', SalesLine."Description 2");
                JObjectLine.Add('quantity', SalesLine.Quantity);
                JObjectLine.Add('quantity_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesLine.Quantity, LanguageCode));
                JObjectLine.Add('unit_price', SalesLine."Unit Price");
                JObjectLine.Add('unit_price_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesLine."Unit Price", LanguageCode));
                JObjectLine.Add('line_amount_excl_vat', SalesLine.Amount);
                JObjectLine.Add('line_amount_excl_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesLine.Amount, LanguageCode));
                JObjectLine.Add('line_amount_incl_vat', SalesLine."Amount Including VAT");
                JObjectLine.Add('line_amount_incl_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesLine."Amount Including VAT", LanguageCode));
                JObjectLine.Add('line_discount_amount', SalesLine."Line Discount Amount");
                JObjectLine.Add('line_discount_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesLine."Line Discount Amount", LanguageCode));
                JObjectLine.Add('vat_pct', SalesLine."VAT %");
                JObjectLine.Add('vat_pct_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesLine."VAT %", LanguageCode));
                _DynTempDataProvSubs.OnAfterCnCAddSalesLine(SalesLine, JObjectLine);
                JArrLines.Add(JObjectLine);
                TotalExclVat += SalesLine.Amount;
                TotalInclVat += SalesLine."Amount Including VAT";
            until SalesLine.Next() = 0;
    end;

    local procedure AddLinesFromPostedInvoice(DocumentNo: Code[20]; var JArrLines: JsonArray; var TotalExclVat: Decimal; var TotalInclVat: Decimal; LanguageCode: Code[10])
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        JObjectLine: JsonObject;
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
    begin
        SalesInvoiceLine.SetRange("Document No.", DocumentNo);
        SalesInvoiceLine.SetFilter(Type, '<>%1', SalesInvoiceLine.Type::" ");
        SalesInvoiceLine.SetFilter("No.", '<>%1', '');
        SalesInvoiceLine.SetLoadFields("Line No.", "No.", "Variant Code", Description, "Description 2", Quantity, "Unit Price", Amount, "Amount Including VAT", "Line Discount Amount", "VAT %");
        if SalesInvoiceLine.FindSet() then
            repeat
                Clear(JObjectLine);
                JObjectLine.Add('line_no', SalesInvoiceLine."Line No.");
                JObjectLine.Add('no', SalesInvoiceLine."No.");
                JObjectLine.Add('variant_code', SalesInvoiceLine."Variant Code");
                JObjectLine.Add('description', SalesInvoiceLine.Description);
                JObjectLine.Add('description_2', SalesInvoiceLine."Description 2");
                JObjectLine.Add('quantity', SalesInvoiceLine.Quantity);
                JObjectLine.Add('quantity_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine.Quantity, LanguageCode));
                JObjectLine.Add('unit_price', SalesInvoiceLine."Unit Price");
                JObjectLine.Add('unit_price_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine."Unit Price", LanguageCode));
                JObjectLine.Add('line_amount_excl_vat', SalesInvoiceLine.Amount);
                JObjectLine.Add('line_amount_excl_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine.Amount, LanguageCode));
                JObjectLine.Add('line_amount_incl_vat', SalesInvoiceLine."Amount Including VAT");
                JObjectLine.Add('line_amount_incl_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine."Amount Including VAT", LanguageCode));
                JObjectLine.Add('line_discount_amount', SalesInvoiceLine."Line Discount Amount");
                JObjectLine.Add('line_discount_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine."Line Discount Amount", LanguageCode));
                JObjectLine.Add('vat_pct', SalesInvoiceLine."VAT %");
                JObjectLine.Add('vat_pct_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine."VAT %", LanguageCode));
                _DynTempDataProvSubs.OnAfterCnCAddSalesInvoiceLine(SalesInvoiceLine, JObjectLine);
                JArrLines.Add(JObjectLine);
                TotalExclVat += SalesInvoiceLine.Amount;
                TotalInclVat += SalesInvoiceLine."Amount Including VAT";
            until SalesInvoiceLine.Next() = 0;
    end;

    local procedure AddLinesFromPostedCrMemo(DocumentNo: Code[20]; var JArrLines: JsonArray; var TotalExclVat: Decimal; var TotalInclVat: Decimal; LanguageCode: Code[10])
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        JObjectLine: JsonObject;
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
    begin
        SalesCrMemoLine.SetRange("Document No.", DocumentNo);
        SalesCrMemoLine.SetFilter(Type, '<>%1', SalesCrMemoLine.Type::" ");
        SalesCrMemoLine.SetFilter("No.", '<>%1', '');
        SalesCrMemoLine.SetLoadFields("Line No.", "No.", "Variant Code", Description, "Description 2", Quantity, "Unit Price", Amount, "Amount Including VAT", "Line Discount Amount", "VAT %");
        if SalesCrMemoLine.FindSet() then
            repeat
                Clear(JObjectLine);
                JObjectLine.Add('line_no', SalesCrMemoLine."Line No.");
                JObjectLine.Add('no', SalesCrMemoLine."No.");
                JObjectLine.Add('variant_code', SalesCrMemoLine."Variant Code");
                JObjectLine.Add('description', SalesCrMemoLine.Description);
                JObjectLine.Add('description_2', SalesCrMemoLine."Description 2");
                JObjectLine.Add('quantity', SalesCrMemoLine.Quantity);
                JObjectLine.Add('quantity_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesCrMemoLine.Quantity, LanguageCode));
                JObjectLine.Add('unit_price', SalesCrMemoLine."Unit Price");
                JObjectLine.Add('unit_price_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesCrMemoLine."Unit Price", LanguageCode));
                JObjectLine.Add('line_amount_excl_vat', SalesCrMemoLine.Amount);
                JObjectLine.Add('line_amount_excl_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesCrMemoLine.Amount, LanguageCode));
                JObjectLine.Add('line_amount_incl_vat', SalesCrMemoLine."Amount Including VAT");
                JObjectLine.Add('line_amount_incl_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesCrMemoLine."Amount Including VAT", LanguageCode));
                JObjectLine.Add('line_discount_amount', SalesCrMemoLine."Line Discount Amount");
                JObjectLine.Add('line_discount_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesCrMemoLine."Line Discount Amount", LanguageCode));
                JObjectLine.Add('vat_pct', SalesCrMemoLine."VAT %");
                JObjectLine.Add('vat_pct_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesCrMemoLine."VAT %", LanguageCode));
                _DynTempDataProvSubs.OnAfterCnCAddSalesCrMemoLine(SalesCrMemoLine, JObjectLine);
                JArrLines.Add(JObjectLine);
                TotalExclVat += SalesCrMemoLine.Amount;
                TotalInclVat += SalesCrMemoLine."Amount Including VAT";
            until SalesCrMemoLine.Next() = 0;
    end;
}

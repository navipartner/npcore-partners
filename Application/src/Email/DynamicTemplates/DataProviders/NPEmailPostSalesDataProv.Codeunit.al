codeunit 6151095 "NPR NPEmailPostSalesDataProv" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PostSalesDocEmailEvents: Codeunit "NPR PostSalesDocEmailEvents";
        JObject: JsonObject;
        WrongRecordReceivedErr: Label 'The code received a record of table id %1 (expected Sales Invoice Header). Most likely a wrong data driver was used on the Dynamic Template. This is a programming bug.', Locked = true;
    begin
        if RecRef.Number() <> Database::"Sales Invoice Header" then
            Error(WrongRecordReceivedErr, Format(RecRef.Number()));
        RecRef.SetTable(SalesInvoiceHeader);

        AddSalesInvoiceHeaderContent(SalesInvoiceHeader, JObject);
        AddPaymentInfo(SalesInvoiceHeader, JObject);

        PostSalesDocEmailEvents.OnAfterGetContent(SalesInvoiceHeader, JObject);

        exit(JObject);
    end;

    procedure GenerateContentExample(): JsonObject
    var
        PostSalesDocEmailEvents: Codeunit "NPR PostSalesDocEmailEvents";
        JObject: JsonObject;
        JPaymentMethod: JsonObject;
        JPaymentMethods: JsonArray;
        JShipToAddress: JsonObject;
        JBillToAddress: JsonObject;
        JSellToAddress: JsonObject;
    begin
        JObject.Add('document_no', 'PSI-001234');
        JObject.Add('order_no', 'SO-001234');
        JObject.Add('external_document_no', 'WEB-2026-001234');
        JObject.Add('external_order_no', 'ECOM-2026-001234');
        JObject.Add('posting_date', Today);
        JObject.Add('posting_date_formatted', Format(Today, 0, '<Standard Format,0>'));
        JObject.Add('document_date', Today);
        JObject.Add('document_date_formatted', Format(Today, 0, '<Standard Format,0>'));
        JObject.Add('due_date', CalcDate('<+30D>', Today));
        JObject.Add('due_date_formatted', Format(CalcDate('<+30D>', Today), 0, '<Standard Format,0>'));
        JObject.Add('currency_code', 'EUR');
        JObject.Add('shipment_method', 'DHL');
        JObject.Add('shipping_agent', 'DHL');
        JObject.Add('payment_method', 'CARD');
        JObject.Add('your_reference', 'PO-998877');
        JObject.Add('salesperson_code', 'SP001');
        JObject.Add('salesperson_name', 'Jane Smith');
        JObject.Add('language_code', 'ENU');

        JSellToAddress.Add('customer_no', 'C-00001');
        JSellToAddress.Add('name', 'John Doe');
        JSellToAddress.Add('address', 'Main St 1');
        JSellToAddress.Add('city', 'Copenhagen');
        JSellToAddress.Add('post_code', '1000');
        JSellToAddress.Add('country', 'DK');
        JSellToAddress.Add('contact', 'John Doe');
        JSellToAddress.Add('email', 'customer@example.com');
        JSellToAddress.Add('phone', '+4512345678');
        PostSalesDocEmailEvents.OnAfterAddExampleSellToInfo(JSellToAddress);
        JObject.Add('sell_to', JSellToAddress);

        JBillToAddress.Add('name', 'John Doe');
        JBillToAddress.Add('address', 'Main St 1');
        JBillToAddress.Add('city', 'Copenhagen');
        JBillToAddress.Add('post_code', '1000');
        JBillToAddress.Add('country', 'DK');
        JBillToAddress.Add('contact', 'John Doe');
        JBillToAddress.Add('email', 'invoice@example.com');
        PostSalesDocEmailEvents.OnAfterAddExampleBillToInfo(JBillToAddress);
        JObject.Add('bill_to', JBillToAddress);

        JShipToAddress.Add('name', 'John Doe');
        JShipToAddress.Add('address', 'Main St 1');
        JShipToAddress.Add('city', 'Copenhagen');
        JShipToAddress.Add('post_code', '1000');
        JShipToAddress.Add('country', 'DK');
        JShipToAddress.Add('contact', 'John Doe');
        PostSalesDocEmailEvents.OnAfterAddExampleShipToInfo(JShipToAddress);
        JObject.Add('ship_to', JShipToAddress);

        AddExampleLines(JObject);

        JObject.Add('original_amount', 150.00);
        JObject.Add('original_amount_formatted', Format(150.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('discount_amount', 20.00);
        JObject.Add('discount_amount_formatted', Format(20.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('amount_after_discount', 130.00);
        JObject.Add('amount_after_discount_formatted', Format(130.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('amount_including_vat', 162.50);
        JObject.Add('amount_including_vat_formatted', Format(162.50, 0, '<Precision,2><Standard Format,2>'));

        PostSalesDocEmailEvents.OnAfterAddExampleSalesInvoiceHeaderJson(JObject);

        JObject.Add('points_used', 500);
        JObject.Add('points_used_formatted', Format(500.0, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('gift_card_used', 10.00);
        JObject.Add('gift_card_used_formatted', Format(10.00, 0, '<Precision,2><Standard Format,2>'));

        JPaymentMethod.Add('method', 'Visa');
        JPaymentMethod.Add('amount', 120.00);
        JPaymentMethod.Add('amount_formatted', Format(120.00, 0, '<Precision,2><Standard Format,2>'));
        PostSalesDocEmailEvents.OnAfterAddExamplePaymentMethodJson(JPaymentMethod);
        JPaymentMethods.Add(JPaymentMethod);
        JObject.Add('payment_methods', JPaymentMethods);

        PostSalesDocEmailEvents.OnAfterGenerateContentExample(JObject);

        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
    end;

    local procedure AddSalesInvoiceHeaderContent(SalesInvoiceHeader: Record "Sales Invoice Header"; var JObject: JsonObject)
    var
        Customer: Record Customer;
        Salesperson: Record "Salesperson/Purchaser";
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
        PostSalesDocEmailEvents: Codeunit "NPR PostSalesDocEmailEvents";
        OriginalAmount: Decimal;
        DiscountAmount: Decimal;
        SalespersonName: Text[50];
        BillToEmail: Text[80];
        LanguageCode: Code[10];
    begin
        LanguageCode := SalesInvoiceHeader."Language Code";

        Salesperson.SetLoadFields(Name);
        if Salesperson.Get(SalesInvoiceHeader."Salesperson Code") then
            SalespersonName := Salesperson.Name;

        Customer.SetLoadFields("E-Mail");
        if Customer.Get(SalesInvoiceHeader."Bill-to Customer No.") then
            BillToEmail := Customer."E-Mail";

        SalesInvoiceHeader.CalcFields("Amount Including VAT");

        JObject.Add('document_no', SalesInvoiceHeader."No.");
        JObject.Add('order_no', SalesInvoiceHeader."Order No.");
        JObject.Add('external_document_no', SalesInvoiceHeader."External Document No.");
        JObject.Add('external_order_no', SalesInvoiceHeader."NPR External Order No.");
        JObject.Add('posting_date', SalesInvoiceHeader."Posting Date");
        JObject.Add('posting_date_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceHeader."Posting Date", LanguageCode));
        JObject.Add('document_date', SalesInvoiceHeader."Document Date");
        JObject.Add('document_date_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceHeader."Document Date", LanguageCode));
        JObject.Add('due_date', SalesInvoiceHeader."Due Date");
        JObject.Add('due_date_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceHeader."Due Date", LanguageCode));
        JObject.Add('currency_code', SalesInvoiceHeader."Currency Code");
        JObject.Add('shipment_method', SalesInvoiceHeader."Shipment Method Code");
        JObject.Add('shipping_agent', SalesInvoiceHeader."Shipping Agent Code");
        JObject.Add('payment_method', SalesInvoiceHeader."Payment Method Code");
        JObject.Add('your_reference', SalesInvoiceHeader."Your Reference");
        JObject.Add('salesperson_code', SalesInvoiceHeader."Salesperson Code");
        JObject.Add('salesperson_name', SalespersonName);
        JObject.Add('language_code', SalesInvoiceHeader."Language Code");

        AddSellToInfo(SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."Sell-to Customer Name",
            SalesInvoiceHeader."Sell-to Address", SalesInvoiceHeader."Sell-to City", SalesInvoiceHeader."Sell-to Post Code",
            SalesInvoiceHeader."Sell-to Country/Region Code", SalesInvoiceHeader."Sell-to Contact",
            SalesInvoiceHeader."Sell-to E-Mail", SalesInvoiceHeader."Sell-to Phone No.", JObject);

        AddBillToInfo(SalesInvoiceHeader."Bill-to Name", SalesInvoiceHeader."Bill-to Address",
            SalesInvoiceHeader."Bill-to City", SalesInvoiceHeader."Bill-to Post Code",
            SalesInvoiceHeader."Bill-to Country/Region Code", SalesInvoiceHeader."Bill-to Contact", BillToEmail, JObject);

        AddShipToInfo(SalesInvoiceHeader."Ship-to Name", SalesInvoiceHeader."Ship-to Address",
            SalesInvoiceHeader."Ship-to City", SalesInvoiceHeader."Ship-to Post Code",
            SalesInvoiceHeader."Ship-to Country/Region Code", SalesInvoiceHeader."Ship-to Contact", JObject);

        AddSalesInvoiceLines(SalesInvoiceHeader, JObject, OriginalAmount, DiscountAmount);

        JObject.Add('original_amount', OriginalAmount);
        JObject.Add('original_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(OriginalAmount, LanguageCode));
        JObject.Add('discount_amount', DiscountAmount);
        JObject.Add('discount_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(DiscountAmount, LanguageCode));
        JObject.Add('amount_after_discount', OriginalAmount - DiscountAmount);
        JObject.Add('amount_after_discount_formatted', DataProviderHelper.FormatToTextFromLanguage(OriginalAmount - DiscountAmount, LanguageCode));
        JObject.Add('amount_including_vat', SalesInvoiceHeader."Amount Including VAT");
        JObject.Add('amount_including_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceHeader."Amount Including VAT", LanguageCode));

        PostSalesDocEmailEvents.OnAfterAddSalesInvoiceHeaderJson(SalesInvoiceHeader, JObject);
    end;

    local procedure AddExampleLines(var JObject: JsonObject)
    var
        PostSalesDocEmailEvents: Codeunit "NPR PostSalesDocEmailEvents";
        JLine: JsonObject;
        JLines: JsonArray;
    begin
        JLine.Add('line_no', 10000);
        JLine.Add('type', 'Item');
        JLine.Add('no', 'ITEM-001');
        JLine.Add('description', 'Sample Product');
        JLine.Add('variant_code', '');
        JLine.Add('quantity', 2);
        JLine.Add('quantity_formatted', Format(2.0, 0, '<Precision,2><Standard Format,2>'));
        JLine.Add('unit_of_measure', 'PCS');
        JLine.Add('unit_price', 75.00);
        JLine.Add('unit_price_formatted', Format(75.00, 0, '<Precision,2><Standard Format,2>'));
        JLine.Add('line_discount_amount', 20.00);
        JLine.Add('line_discount_amount_formatted', Format(20.00, 0, '<Precision,2><Standard Format,2>'));
        JLine.Add('line_amount', 130.00);
        JLine.Add('line_amount_formatted', Format(130.00, 0, '<Precision,2><Standard Format,2>'));
        JLine.Add('amount_including_vat', 162.50);
        JLine.Add('amount_including_vat_formatted', Format(162.50, 0, '<Precision,2><Standard Format,2>'));
        JLine.Add('vat_percent', 25);
        JLine.Add('vat_percent_formatted', Format(25.0, 0, '<Precision,2><Standard Format,2>'));
        PostSalesDocEmailEvents.OnAfterAddExampleSalesInvoiceLineJson(JLine);
        JLines.Add(JLine);
        JObject.Add('lines', JLines);
    end;

    local procedure AddSalesInvoiceLines(SalesInvoiceHeader: Record "Sales Invoice Header"; var JObject: JsonObject; var OriginalAmount: Decimal; var DiscountAmount: Decimal)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
        PostSalesDocEmailEvents: Codeunit "NPR PostSalesDocEmailEvents";
        JLine: JsonObject;
        JLines: JsonArray;
        LanguageCode: Code[10];
    begin
        LanguageCode := SalesInvoiceHeader."Language Code";

        SalesInvoiceLine.SetLoadFields("Line No.", Type, "No.", Description, "Variant Code", Quantity, "Unit of Measure Code", "Unit Price", "Line Discount Amount", Amount, "Amount Including VAT", "VAT %");
        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        if SalesInvoiceLine.FindSet() then
            repeat
                OriginalAmount += SalesInvoiceLine.Amount + SalesInvoiceLine."Line Discount Amount";
                DiscountAmount += SalesInvoiceLine."Line Discount Amount";

                Clear(JLine);
                JLine.Add('line_no', SalesInvoiceLine."Line No.");
                JLine.Add('type', SalesInvoiceLine.Type.Names().Get(SalesInvoiceLine.Type.Ordinals().IndexOf(SalesInvoiceLine.Type.AsInteger())));
                JLine.Add('no', SalesInvoiceLine."No.");
                JLine.Add('description', SalesInvoiceLine.Description);
                JLine.Add('variant_code', SalesInvoiceLine."Variant Code");
                JLine.Add('quantity', SalesInvoiceLine.Quantity);
                JLine.Add('quantity_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine.Quantity, LanguageCode));
                JLine.Add('unit_of_measure', SalesInvoiceLine."Unit of Measure Code");
                JLine.Add('unit_price', SalesInvoiceLine."Unit Price");
                JLine.Add('unit_price_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine."Unit Price", LanguageCode));
                JLine.Add('line_discount_amount', SalesInvoiceLine."Line Discount Amount");
                JLine.Add('line_discount_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine."Line Discount Amount", LanguageCode));
                JLine.Add('line_amount', SalesInvoiceLine.Amount);
                JLine.Add('line_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine.Amount, LanguageCode));
                JLine.Add('amount_including_vat', SalesInvoiceLine."Amount Including VAT");
                JLine.Add('amount_including_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine."Amount Including VAT", LanguageCode));
                JLine.Add('vat_percent', SalesInvoiceLine."VAT %");
                JLine.Add('vat_percent_formatted', DataProviderHelper.FormatToTextFromLanguage(SalesInvoiceLine."VAT %", LanguageCode));
                PostSalesDocEmailEvents.OnAfterAddSalesInvoiceLineJson(SalesInvoiceLine, JLine);
                JLines.Add(JLine);
            until SalesInvoiceLine.Next() = 0;

        JObject.Add('lines', JLines);
    end;

    local procedure AddSellToInfo(CustomerNo: Code[20]; CustomerName: Text[100]; Address: Text[100]; City: Text[30];
        PostCode: Code[20]; CountryCode: Code[10]; Contact: Text[100];
        Email: Text[80]; Phone: Text[30]; var JObject: JsonObject)
    var
        PostSalesDocEmailEvents: Codeunit "NPR PostSalesDocEmailEvents";
        JSellTo: JsonObject;
    begin
        JSellTo.Add('customer_no', CustomerNo);
        JSellTo.Add('name', CustomerName);
        JSellTo.Add('address', Address);
        JSellTo.Add('city', City);
        JSellTo.Add('post_code', PostCode);
        JSellTo.Add('country', CountryCode);
        JSellTo.Add('contact', Contact);
        JSellTo.Add('email', Email);
        JSellTo.Add('phone', Phone);
        PostSalesDocEmailEvents.OnAfterAddSellToInfo(JSellTo);
        JObject.Add('sell_to', JSellTo);
    end;

    local procedure AddBillToInfo(BillToName: Text[100]; Address: Text[100]; City: Text[30];
        PostCode: Code[20]; CountryCode: Code[10]; Contact: Text[100]; Email: Text[80]; var JObject: JsonObject)
    var
        PostSalesDocEmailEvents: Codeunit "NPR PostSalesDocEmailEvents";
        JBillTo: JsonObject;
    begin
        JBillTo.Add('name', BillToName);
        JBillTo.Add('address', Address);
        JBillTo.Add('city', City);
        JBillTo.Add('post_code', PostCode);
        JBillTo.Add('country', CountryCode);
        JBillTo.Add('contact', Contact);
        JBillTo.Add('email', Email);
        PostSalesDocEmailEvents.OnAfterAddBillToInfo(JBillTo);
        JObject.Add('bill_to', JBillTo);
    end;

    local procedure AddShipToInfo(ShipToName: Text[100]; Address: Text[100]; City: Text[30];
        PostCode: Code[20]; CountryCode: Code[10]; Contact: Text[100]; var JObject: JsonObject)
    var
        PostSalesDocEmailEvents: Codeunit "NPR PostSalesDocEmailEvents";
        JShipTo: JsonObject;
    begin
        JShipTo.Add('name', ShipToName);
        JShipTo.Add('address', Address);
        JShipTo.Add('city', City);
        JShipTo.Add('post_code', PostCode);
        JShipTo.Add('country', CountryCode);
        JShipTo.Add('contact', Contact);
        PostSalesDocEmailEvents.OnAfterAddShipToInfo(JShipTo);
        JObject.Add('ship_to', JShipTo);
    end;

    local procedure AddPaymentInfo(SalesInvoiceHeader: Record "Sales Invoice Header"; var JObject: JsonObject)
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
        PostSalesDocEmailEvents: Codeunit "NPR PostSalesDocEmailEvents";
        JPaymentMethod: JsonObject;
        JPaymentMethods: JsonArray;
        PointsUsed: Decimal;
        GiftCardUsed: Decimal;
        LanguageCode: Code[10];
    begin
        LanguageCode := SalesInvoiceHeader."Language Code";

        MagentoPaymentLine.SetLoadFields("Source No.", Amount, "Points Payment", "Payment Type");
        MagentoPaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        // Posted-invoice payment lines are stored with Document Type 0 (not ::Invoice); see MagentoPmtMgt.
        MagentoPaymentLine.SetRange("Document Type", 0);
        MagentoPaymentLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        if MagentoPaymentLine.FindSet() then
            repeat
                Clear(JPaymentMethod);
                JPaymentMethod.Add('method', MagentoPaymentLine."Source No.");
                JPaymentMethod.Add('amount', MagentoPaymentLine.Amount);
                JPaymentMethod.Add('amount_formatted', DataProviderHelper.FormatToTextFromLanguage(MagentoPaymentLine.Amount, LanguageCode));
                PostSalesDocEmailEvents.OnAfterAddPaymentMethodJson(MagentoPaymentLine, JPaymentMethod);
                JPaymentMethods.Add(JPaymentMethod);

                if MagentoPaymentLine."Points Payment" then
                    PointsUsed += MagentoPaymentLine.Amount
                else
                    if MagentoPaymentLine."Payment Type" = MagentoPaymentLine."Payment Type"::Voucher then
                        GiftCardUsed += MagentoPaymentLine.Amount;
            until MagentoPaymentLine.Next() = 0;

        JObject.Add('points_used', PointsUsed);
        JObject.Add('points_used_formatted', DataProviderHelper.FormatToTextFromLanguage(PointsUsed, LanguageCode));
        JObject.Add('gift_card_used', GiftCardUsed);
        JObject.Add('gift_card_used_formatted', DataProviderHelper.FormatToTextFromLanguage(GiftCardUsed, LanguageCode));
        JObject.Add('payment_methods', JPaymentMethods);
    end;
}

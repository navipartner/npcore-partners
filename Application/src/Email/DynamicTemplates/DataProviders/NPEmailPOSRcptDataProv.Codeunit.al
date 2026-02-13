#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6151008 "NPR NPEmailPOSRcptDataProv" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        POSEntry: Record "NPR POS Entry";
        WrongRecordReceivedErr: Label 'The code received a record of type %1 (expected NPR POS Entry). Most likely a wrong data driver was used on the Dynamic Template.';
    begin
        if RecRef.Number() <> Database::"NPR POS Entry" then
            Error(WrongRecordReceivedErr, RecRef.Name());
        RecRef.SetTable(POSEntry);
        exit(POSEntryToJson(POSEntry));
    end;

    procedure GenerateContentExample(): JsonObject
    var
        JObject: JsonObject;
        JSalesLines: JsonArray;
        JPaymentLines: JsonArray;
        JTaxLines: JsonArray;
        JDigitalReceipts: JsonArray;
        JSalesLine: JsonObject;
        JPaymentLine: JsonObject;
        JTaxLine: JsonObject;
        JDigitalReceipt: JsonObject;
    begin
        JObject.Add('entry_no', 12345);
        JObject.Add('document_no', 'TIC000123');
        JObject.Add('fiscal_no', 'FIS000456');
        JObject.Add('pos_store_code', 'STORE01');
        JObject.Add('pos_unit_no', 'POS01');
        JObject.Add('entry_date', 20250209D);
        JObject.Add('entry_date_formatted', Format(20250209D, 0, '<Standard Format,0>'));
        JObject.Add('posting_date', 20250209D);
        JObject.Add('posting_date_formatted', Format(20250209D, 0, '<Standard Format,0>'));
        JObject.Add('document_date', 20250209D);
        JObject.Add('document_date_formatted', Format(20250209D, 0, '<Standard Format,0>'));
        JObject.Add('starting_time', 100000T);
        JObject.Add('starting_time_formatted', Format(100000T, 0, '<Standard Format,0>'));
        JObject.Add('ending_time', 103000T);
        JObject.Add('ending_time_formatted', Format(103000T, 0, '<Standard Format,0>'));
        JObject.Add('entry_type', 1);
        JObject.Add('entry_type_text', 'Direct Sale');
        JObject.Add('description', 'POS Sale Transaction');
        JObject.Add('customer_no', 'CUST00001');
        JObject.Add('customer_name', 'John Doe');
        JObject.Add('customer_email', 'john.doe@example.com');
        JObject.Add('customer_phone', '+1234567890');
        JObject.Add('customer_address', '123 Main St');
        JObject.Add('customer_city', 'New York');
        JObject.Add('customer_post_code', '10001');
        JObject.Add('customer_country', 'US');
        JObject.Add('salesperson_code', 'SP001');
        JObject.Add('salesperson_name', 'Jane Smith');
        JObject.Add('currency_code', 'USD');
        JObject.Add('currency_factor', 1.0);
        JObject.Add('amount_excl_tax', 100.00);
        JObject.Add('amount_excl_tax_formatted', Format(100.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('tax_amount', 8.00);
        JObject.Add('tax_amount_formatted', Format(8.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('discount_amount', 5.00);
        JObject.Add('discount_amount_formatted', Format(5.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('rounding_amount', 0.00);
        JObject.Add('rounding_amount_formatted', Format(0.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('amount_incl_tax', 108.00);
        JObject.Add('amount_incl_tax_formatted', Format(108.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('amount_incl_tax_and_round', 108.00);
        JObject.Add('amount_incl_tax_and_round_formatted', Format(108.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('payment_amount', 108.00);
        JObject.Add('payment_amount_formatted', Format(108.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('language_code', 'ENU');

        JSalesLine.Add('line_no', 10000);
        JSalesLine.Add('type', 2);
        JSalesLine.Add('type_text', 'Item');
        JSalesLine.Add('no', 'ITEM001');
        JSalesLine.Add('description', 'Sample Product');
        JSalesLine.Add('quantity', 2.0);
        JSalesLine.Add('unit_price', 50.00);
        JSalesLine.Add('unit_price_formatted', Format(50.00, 0, '<Precision,2><Standard Format,2>'));
        JSalesLine.Add('line_discount_percent', 5.0);
        JSalesLine.Add('line_discount_amount', 5.00);
        JSalesLine.Add('line_discount_amount_formatted', Format(5.00, 0, '<Precision,2><Standard Format,2>'));
        JSalesLine.Add('vat_percent', 8.0);
        JSalesLine.Add('amount_excl_vat', 95.00);
        JSalesLine.Add('amount_excl_vat_formatted', Format(95.00, 0, '<Precision,2><Standard Format,2>'));
        JSalesLine.Add('amount_incl_vat', 102.60);
        JSalesLine.Add('amount_incl_vat_formatted', Format(102.60, 0, '<Precision,2><Standard Format,2>'));
        JSalesLines.Add(JSalesLine);
        JObject.Add('sales_lines', JSalesLines);

        JPaymentLine.Add('line_no', 10000);
        JPaymentLine.Add('payment_method_code', 'CARD');
        JPaymentLine.Add('payment_method_description', 'Credit Card');
        JPaymentLine.Add('amount', 108.00);
        JPaymentLine.Add('amount_formatted', Format(108.00, 0, '<Precision,2><Standard Format,2>'));
        JPaymentLine.Add('payment_fee_percent', 0.0);
        JPaymentLine.Add('payment_fee_amount', 0.00);
        JPaymentLine.Add('payment_amount', 108.00);
        JPaymentLine.Add('payment_amount_formatted', Format(108.00, 0, '<Precision,2><Standard Format,2>'));
        JPaymentLines.Add(JPaymentLine);
        JObject.Add('payment_lines', JPaymentLines);

        JTaxLine.Add('vat_identifier', 'STANDARD');
        JTaxLine.Add('tax_percent', 8.0);
        JTaxLine.Add('tax_base_amount', 100.00);
        JTaxLine.Add('tax_base_amount_formatted', Format(100.00, 0, '<Precision,2><Standard Format,2>'));
        JTaxLine.Add('tax_amount', 8.00);
        JTaxLine.Add('tax_amount_formatted', Format(8.00, 0, '<Precision,2><Standard Format,2>'));
        JTaxLines.Add(JTaxLine);
        JObject.Add('tax_lines', JTaxLines);

        Clear(JDigitalReceipt);
        JDigitalReceipt.Add('digital_receipt_id', 'fiskaly-abc123');
        JDigitalReceipt.Add('pdf_link', 'https://receipt.fiskaly.com/pdf/abc123');
        JDigitalReceipt.Add('qr_code_link', 'https://receipt.fiskaly.com/qr/abc123');
        JDigitalReceipt.Add('entry_no', 123456);
        JDigitalReceipts.Add(JDigitalReceipt);

        Clear(JDigitalReceipt);
        JDigitalReceipt.Add('digital_receipt_id', 'fiskaly-def456');
        JDigitalReceipt.Add('pdf_link', 'https://receipt.fiskaly.com/pdf/def456');
        JDigitalReceipt.Add('qr_code_link', 'https://receipt.fiskaly.com/qr/def456');
        JDigitalReceipt.Add('entry_no', 123457);
        JDigitalReceipts.Add(JDigitalReceipt);

        JObject.Add('digital_receipts', JDigitalReceipts);

        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin

    end;

    local procedure POSEntryToJson(POSEntry: Record "NPR POS Entry"): JsonObject
    var
        Customer: Record Customer;
        Salesperson: Record "Salesperson/Purchaser";
        JObject: JsonObject;
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
        LanguageCode: Code[10];
        CustomerName: Text[100];
        CustomerEmail: Text[80];
        CustomerPhone: Text[30];
        CustomerAddress: Text[100];
        CustomerCity: Text[30];
        CustomerPostCode: Code[20];
        CustomerCountry: Code[10];
        SalespersonName: Text[50];
    begin
        LanguageCode := '';
        if Customer.Get(POSEntry."Customer No.") then begin
            LanguageCode := Customer."Language Code";
            CustomerName := Customer.Name;
            CustomerEmail := Customer."E-Mail";
            CustomerPhone := Customer."Phone No.";
            CustomerAddress := Customer.Address;
            CustomerCity := Customer.City;
            CustomerPostCode := Customer."Post Code";
            CustomerCountry := Customer."Country/Region Code";
        end;

        if Salesperson.Get(POSEntry."Salesperson Code") then
            SalespersonName := Salesperson.Name;

        POSEntry.CalcFields("Payment Amount");

        JObject.Add('entry_no', POSEntry."Entry No.");
        JObject.Add('document_no', POSEntry."Document No.");
        JObject.Add('fiscal_no', POSEntry."Fiscal No.");
        JObject.Add('pos_store_code', POSEntry."POS Store Code");
        JObject.Add('pos_unit_no', POSEntry."POS Unit No.");
        JObject.Add('entry_date', POSEntry."Entry Date");
        JObject.Add('entry_date_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Entry Date", LanguageCode));
        JObject.Add('posting_date', POSEntry."Posting Date");
        JObject.Add('posting_date_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Posting Date", LanguageCode));
        JObject.Add('document_date', POSEntry."Document Date");
        JObject.Add('document_date_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Document Date", LanguageCode));
        JObject.Add('starting_time', POSEntry."Starting Time");
        JObject.Add('starting_time_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Starting Time", LanguageCode));
        JObject.Add('ending_time', POSEntry."Ending Time");
        JObject.Add('ending_time_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Ending Time", LanguageCode));
        JObject.Add('entry_type', POSEntry."Entry Type");
        JObject.Add('entry_type_text', Format(POSEntry."Entry Type"));
        JObject.Add('description', POSEntry.Description);
        JObject.Add('customer_no', POSEntry."Customer No.");
        JObject.Add('customer_name', CustomerName);
        JObject.Add('customer_email', CustomerEmail);
        JObject.Add('customer_phone', CustomerPhone);
        JObject.Add('customer_address', CustomerAddress);
        JObject.Add('customer_city', CustomerCity);
        JObject.Add('customer_post_code', CustomerPostCode);
        JObject.Add('customer_country', CustomerCountry);
        JObject.Add('salesperson_code', POSEntry."Salesperson Code");
        JObject.Add('salesperson_name', SalespersonName);
        JObject.Add('currency_code', POSEntry."Currency Code");
        JObject.Add('currency_factor', POSEntry."Currency Factor");
        JObject.Add('amount_excl_tax', POSEntry."Amount Excl. Tax");
        JObject.Add('amount_excl_tax_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Amount Excl. Tax", LanguageCode));
        JObject.Add('tax_amount', POSEntry."Tax Amount");
        JObject.Add('tax_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Tax Amount", LanguageCode));
        JObject.Add('discount_amount', POSEntry."Discount Amount");
        JObject.Add('discount_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Discount Amount", LanguageCode));
        JObject.Add('rounding_amount', POSEntry."Rounding Amount (LCY)");
        JObject.Add('rounding_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Rounding Amount (LCY)", LanguageCode));
        JObject.Add('amount_incl_tax', POSEntry."Amount Incl. Tax");
        JObject.Add('amount_incl_tax_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Amount Incl. Tax", LanguageCode));
        JObject.Add('amount_incl_tax_and_round', POSEntry."Amount Incl. Tax & Round");
        JObject.Add('amount_incl_tax_and_round_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Amount Incl. Tax & Round", LanguageCode));
        JObject.Add('payment_amount', POSEntry."Payment Amount");
        JObject.Add('payment_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntry."Payment Amount", LanguageCode));
        JObject.Add('language_code', LanguageCode);

        JObject.Add('sales_lines', GetSalesLines(POSEntry."Entry No.", LanguageCode));
        JObject.Add('payment_lines', GetPaymentLines(POSEntry."Entry No.", LanguageCode));
        JObject.Add('tax_lines', GetTaxLines(POSEntry."Entry No.", LanguageCode));
        JObject.Add('digital_receipts', GetDigitalReceipts(POSEntry."Entry No."));

        exit(JObject);
    end;

    local procedure GetSalesLines(POSEntryNo: Integer; LanguageCode: Code[10]): JsonArray
    var
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        JSalesLines: JsonArray;
        JSalesLine: JsonObject;
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
    begin
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntryNo);
        if POSEntrySalesLine.FindSet() then
            repeat
                Clear(JSalesLine);
                JSalesLine.Add('line_no', POSEntrySalesLine."Line No.");
                JSalesLine.Add('type', POSEntrySalesLine.Type);
                JSalesLine.Add('type_text', Format(POSEntrySalesLine.Type));
                JSalesLine.Add('no', POSEntrySalesLine."No.");
                JSalesLine.Add('description', POSEntrySalesLine.Description);
                JSalesLine.Add('quantity', POSEntrySalesLine.Quantity);
                JSalesLine.Add('unit_price', POSEntrySalesLine."Unit Price");
                JSalesLine.Add('unit_price_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntrySalesLine."Unit Price", LanguageCode));
                JSalesLine.Add('line_discount_percent', POSEntrySalesLine."Line Discount %");
                JSalesLine.Add('line_discount_amount', POSEntrySalesLine."Line Discount Amount Incl. VAT");
                JSalesLine.Add('line_discount_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntrySalesLine."Line Discount Amount Incl. VAT", LanguageCode));
                JSalesLine.Add('vat_percent', POSEntrySalesLine."VAT %");
                JSalesLine.Add('amount_excl_vat', POSEntrySalesLine."Amount Excl. VAT");
                JSalesLine.Add('amount_excl_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntrySalesLine."Amount Excl. VAT", LanguageCode));
                JSalesLine.Add('amount_incl_vat', POSEntrySalesLine."Amount Incl. VAT");
                JSalesLine.Add('amount_incl_vat_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntrySalesLine."Amount Incl. VAT", LanguageCode));
                JSalesLines.Add(JSalesLine);
            until POSEntrySalesLine.Next() = 0;
        exit(JSalesLines);
    end;

    local procedure GetPaymentLines(POSEntryNo: Integer; LanguageCode: Code[10]): JsonArray
    var
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        JPaymentLines: JsonArray;
        JPaymentLine: JsonObject;
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
    begin
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntryNo);
        if POSEntryPaymentLine.FindSet() then
            repeat
                Clear(JPaymentLine);
                JPaymentLine.Add('line_no', POSEntryPaymentLine."Line No.");
                JPaymentLine.Add('payment_method_code', POSEntryPaymentLine."POS Payment Method Code");
                JPaymentLine.Add('payment_method_description', POSEntryPaymentLine.Description);
                JPaymentLine.Add('amount', POSEntryPaymentLine.Amount);
                JPaymentLine.Add('amount_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntryPaymentLine.Amount, LanguageCode));
                JPaymentLine.Add('payment_fee_percent', POSEntryPaymentLine."Payment Fee %");
                JPaymentLine.Add('payment_fee_amount', POSEntryPaymentLine."Payment Fee Amount");
                JPaymentLine.Add('payment_fee_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntryPaymentLine."Payment Fee Amount", LanguageCode));
                JPaymentLine.Add('payment_amount', POSEntryPaymentLine."Payment Amount");
                JPaymentLine.Add('payment_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntryPaymentLine."Payment Amount", LanguageCode));
                JPaymentLines.Add(JPaymentLine);
            until POSEntryPaymentLine.Next() = 0;
        exit(JPaymentLines);
    end;

    local procedure GetTaxLines(POSEntryNo: Integer; LanguageCode: Code[10]): JsonArray
    var
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        JTaxLines: JsonArray;
        JTaxLine: JsonObject;
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
    begin
        POSEntryTaxLine.SetRange("POS Entry No.", POSEntryNo);
        if POSEntryTaxLine.FindSet() then
            repeat
                Clear(JTaxLine);
                JTaxLine.Add('vat_identifier', POSEntryTaxLine."VAT Identifier");
                JTaxLine.Add('tax_percent', POSEntryTaxLine."Tax %");
                JTaxLine.Add('tax_base_amount', POSEntryTaxLine."Tax Base Amount");
                JTaxLine.Add('tax_base_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntryTaxLine."Tax Base Amount", LanguageCode));
                JTaxLine.Add('tax_amount', POSEntryTaxLine."Tax Amount");
                JTaxLine.Add('tax_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(POSEntryTaxLine."Tax Amount", LanguageCode));
                JTaxLines.Add(JTaxLine);
            until POSEntryTaxLine.Next() = 0;
        exit(JTaxLines);
    end;

    local procedure GetDigitalReceipts(POSEntryNo: Integer): JsonArray
    var
        POSSaleDigitalReceiptEntry: Record "NPR POSSale Dig. Receipt Entry";
        JDigitalReceipts: JsonArray;
        JDigitalReceipt: JsonObject;
    begin
        POSSaleDigitalReceiptEntry.SetRange("POS Entry No.", POSEntryNo);
        if POSSaleDigitalReceiptEntry.FindSet() then
            repeat
                Clear(JDigitalReceipt);
                JDigitalReceipt.Add('digital_receipt_id', POSSaleDigitalReceiptEntry.Id);
                JDigitalReceipt.Add('pdf_link', POSSaleDigitalReceiptEntry.PDFLink);
                JDigitalReceipt.Add('qr_code_link', POSSaleDigitalReceiptEntry."QR Code Link");
                JDigitalReceipt.Add('entry_no', POSSaleDigitalReceiptEntry."Entry No.");
                JDigitalReceipts.Add(JDigitalReceipt);
            until POSSaleDigitalReceiptEntry.Next() = 0;
        exit(JDigitalReceipts);
    end;
}
#endif

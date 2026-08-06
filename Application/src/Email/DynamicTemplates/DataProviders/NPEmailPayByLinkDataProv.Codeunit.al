codeunit 6151247 "NPR NPEmailPayByLinkDataProv" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
        JObject: JsonObject;
        CustomerName: Text;
        CustomerEmail: Text;
        CurrencyCode: Code[10];
        LanguageCode: Code[10];
        WrongRecordReceivedErr: Label 'The code received a record of an unknown type. Most likely a wrong data provider was used on the Dynamic Template. This is a programming bug.', Locked = true;
    begin
        if RecRef.Number() <> Database::"NPR Magento Payment Line" then
            Error(WrongRecordReceivedErr);

        RecRef.SetTable(MagentoPaymentLine);

        case MagentoPaymentLine."Document Table No." of
            Database::"Sales Header":
                begin
                    SalesHeader.SetLoadFields("Bill-to Name", "Bill-to Customer No.", "Currency Code", "Language Code");
                    if SalesHeader.Get(MagentoPaymentLine."Document Type", MagentoPaymentLine."Document No.") then begin
                        CustomerName := SalesHeader."Bill-to Name";
                        CurrencyCode := SalesHeader."Currency Code";
                        LanguageCode := SalesHeader."Language Code";
                        if Customer.Get(SalesHeader."Bill-to Customer No.") then
                            CustomerEmail := Customer."E-Mail";
                    end;
                end;
            Database::"Sales Invoice Header":
                begin
                    SalesInvoiceHeader.SetLoadFields("Bill-to Name", "Bill-to Customer No.", "Currency Code", "Language Code");
                    if SalesInvoiceHeader.Get(MagentoPaymentLine."Document No.") then begin
                        CustomerName := SalesInvoiceHeader."Bill-to Name";
                        CurrencyCode := SalesInvoiceHeader."Currency Code";
                        LanguageCode := SalesInvoiceHeader."Language Code";
                        if Customer.Get(SalesInvoiceHeader."Bill-to Customer No.") then
                            CustomerEmail := Customer."E-Mail";
                    end;
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    SalesCrMemoHeader.SetLoadFields("Bill-to Name", "Bill-to Customer No.", "Currency Code", "Language Code");
                    if SalesCrMemoHeader.Get(MagentoPaymentLine."Document No.") then begin
                        CustomerName := SalesCrMemoHeader."Bill-to Name";
                        CurrencyCode := SalesCrMemoHeader."Currency Code";
                        LanguageCode := SalesCrMemoHeader."Language Code";
                        if Customer.Get(SalesCrMemoHeader."Bill-to Customer No.") then
                            CustomerEmail := Customer."E-Mail";
                    end;
                end;
            Database::"NPR Ecom Sales Header":
                begin
                    EcomSalesHeader.SetLoadFields("Sell-to Name", "Sell-to Email", "Currency Code", "Language Code");
                    if EcomSalesHeader.GetBySystemId(MagentoPaymentLine."NPR Inc Ecom Sale Id") then begin
                        CustomerName := EcomSalesHeader."Sell-to Name";
                        CustomerEmail := EcomSalesHeader."Sell-to Email";
                        CurrencyCode := EcomSalesHeader."Currency Code";
                        LanguageCode := EcomSalesHeader."Language Code";
                    end;
                end;
        end;

        if CurrencyCode = '' then begin
            GeneralLedgerSetup.SetLoadFields("LCY Code");
            GeneralLedgerSetup.Get();
            CurrencyCode := GeneralLedgerSetup."LCY Code";
        end;

        JObject.Add('pay_by_link_url', MagentoPaymentLine."Pay by Link URL");
        JObject.Add('document_no', MagentoPaymentLine."Document No.");
        JObject.Add('requested_amount', MagentoPaymentLine."Requested Amount");
        JObject.Add('requested_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(MagentoPaymentLine."Requested Amount", LanguageCode));
        JObject.Add('currency_code', CurrencyCode);
        JObject.Add('language_code', LanguageCode);
        JObject.Add('description', MagentoPaymentLine.Description);
        JObject.Add('transaction_id', MagentoPaymentLine."Transaction ID");
        JObject.Add('expires_at', MagentoPaymentLine."Expires At");
        JObject.Add('expires_at_formatted', DataProviderHelper.FormatToTextFromLanguage(MagentoPaymentLine."Expires At", LanguageCode));
        JObject.Add('customer_name', CustomerName);
        JObject.Add('customer_email', CustomerEmail);
        JObject.Add('external_reference_no', MagentoPaymentLine."External Reference No.");
        exit(JObject);
    end;

    procedure GenerateContentExample(): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add('pay_by_link_url', 'https://pay.example.com/link/ABC123');
        JObject.Add('document_no', 'SI-0001234');
        JObject.Add('requested_amount', 150.00);
        JObject.Add('requested_amount_formatted', Format(150.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('currency_code', 'EUR');
        JObject.Add('language_code', 'ENU');
        JObject.Add('description', 'Payment for order SI-0001234');
        JObject.Add('transaction_id', 'TRANS-ABC-001');
        JObject.Add('expires_at', CreateDateTime(20250101D, 120000T));
        JObject.Add('expires_at_formatted', Format(CreateDateTime(20250101D, 120000T), 0, '<Standard Format,0>'));
        JObject.Add('customer_name', 'Hans Hansen');
        JObject.Add('customer_email', 'hans@example.com');
        JObject.Add('external_reference_no', 'EXT-REF-001');
        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
    end;
}

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248185 "NPR NPEmailDigNotifDataProv" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    var
        _Events: Codeunit "NPR Dig. Notif. Events";

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        DigitalProdNotifEntry: Record "NPR Digital Notification Entry";
        JObject: JsonObject;
    begin
        RecRef.SetTable(DigitalProdNotifEntry);
        JObject := GetNotificationContent(DigitalProdNotifEntry);
        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
        // No attachments - manifest URL is embedded in email
    end;

    procedure GenerateContentExample(): JsonObject
    var
        JObject, JObjectLine, JObjectPaymentLine : JsonObject;
        JArrLines, JArrPaymentLines : JsonArray;
    begin
        JObject.Add('order_number', 'MAG-2024-001234');
        JObject.Add('recipient_email', 'customer@example.com');
        JObject.Add('recipient_name', 'John Doe');
        JObject.Add('language_code', 'ENU');
        JObject.Add('doc_type', 'Ecom Sales Document');
        JObject.Add('notification_type', 'Order Confirmation');
        JObject.Add('source_document_id', '12345678-1234-1234-1234-123456789abc');
        JObject.Add('posted_doc_no', '');
        JObject.Add('ecom_document_type', 'Order');
        JObject.Add('customer_no', 'C-00001');
        JObject.Add('document_date', Format(20240115D, 0, '<Standard Format,0>'));
        JObject.Add('currency_code', 'EUR');
        JObject.Add('total_amount_excl_vat', 100.0);
        JObject.Add('total_amount_excl_vat_formatted', Format(100.0, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('total_amount_incl_vat', 125.0);
        JObject.Add('total_amount_incl_vat_formatted', Format(125.0, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('invoice_discount_amount', 25.0);
        JObject.Add('invoice_discount_amount_formatted', Format(25.0, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('manifest_url', '');
        _Events.OnAfterAddExampleHeaderFieldsToJson(JObject);

        JObjectLine.Add('line_no', 10000);
        JObjectLine.Add('asset_type', 'Voucher');
        JObjectLine.Add('no', '1000');
        JObjectLine.Add('variant_code', '');
        JObjectLine.Add('description', 'Gift Voucher 100 EUR');
        JObjectLine.Add('quantity', 1);
        JObjectLine.Add('unit_price_incl_vat', 125.0);
        JObjectLine.Add('unit_price_incl_vat_formatted', Format(125.0, 0, '<Precision,2><Standard Format,2>'));
        JObjectLine.Add('line_amount_excl_vat', 100.0);
        JObjectLine.Add('line_amount_excl_vat_formatted', Format(100.0, 0, '<Precision,2><Standard Format,2>'));
        JObjectLine.Add('line_amount_incl_vat', 125.0);
        JObjectLine.Add('line_amount_incl_vat_formatted', Format(125.0, 0, '<Precision,2><Standard Format,2>'));
        JObjectLine.Add('line_discount_amount', 0.0);
        JObjectLine.Add('line_discount_amount_formatted', Format(0.0, 0, '<Precision,2><Standard Format,2>'));
        JObjectLine.Add('vat_pct', 25.0);
        JObjectLine.Add('vat_pct_formatted', Format(25.0, 0, '<Precision,2><Standard Format,2>'));
        _Events.OnAfterAddExampleLineJson(JObjectLine);
        JArrLines.Add(JObjectLine);
        JObject.Add('document_lines', JArrLines);

        JObjectPaymentLine.Add('line_no', 10000);
        JObjectPaymentLine.Add('payment_method_type', 'Payment Method');
        JObjectPaymentLine.Add('external_payment_type', 'card');
        JObjectPaymentLine.Add('external_payment_method_code', 'visa');
        JObjectPaymentLine.Add('description', 'Visa');
        JObjectPaymentLine.Add('amount', 125.0);
        JObjectPaymentLine.Add('amount_formatted', Format(125.0, 0, '<Precision,2><Standard Format,2>'));
        JObjectPaymentLine.Add('captured_amount', 125.0);
        JObjectPaymentLine.Add('captured_amount_formatted', Format(125.0, 0, '<Precision,2><Standard Format,2>'));
        JObjectPaymentLine.Add('invoiced_amount', 125.0);
        JObjectPaymentLine.Add('invoiced_amount_formatted', Format(125.0, 0, '<Precision,2><Standard Format,2>'));
        JObjectPaymentLine.Add('date_authorized', Format(20240115D, 0, '<Standard Format,0>'));
        JObjectPaymentLine.Add('expires_at', Format(CreateDateTime(20240129D, 0T), 0, 9));
        JObjectPaymentLine.Add('payment_reference', 'PSP-ABC-12345');
        JObjectPaymentLine.Add('card_brand', 'Visa');
        JObjectPaymentLine.Add('masked_card_number', '************1234');
        _Events.OnAfterAddExamplePaymentLineJson(JObjectPaymentLine);
        JArrPaymentLines.Add(JObjectPaymentLine);
        JObject.Add('payment_lines', JArrPaymentLines);

        _Events.OnAfterGenerateContentExample(JObject);
        exit(JObject);
    end;

    local procedure GetNotificationContent(NotifEntry: Record "NPR Digital Notification Entry"): JsonObject
    var
        TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        JObject: JsonObject;
        JArrLines, JArrPaymentLines : JsonArray;
    begin
        if NotifEntry."Document Type" = NotifEntry."Document Type"::"Ecom Sales Document" then
            exit(GetEcomNotificationContent(NotifEntry));

        // Non-ecom path (Invoice / Credit Memo): buffer-based, no extensibility events.
        PopulateBuffersFromNotifEntry(NotifEntry, TempHeaderBuffer, TempLineBuffer);

        AddNotifEntryFields(JObject, NotifEntry);

        AddHeaderFieldsFromBuffer(JObject, TempHeaderBuffer);

        JObject.Add('manifest_url', GetManifestUrl(NotifEntry."Manifest ID"));

        AddLinesFromBuffer(JArrLines, TempHeaderBuffer, TempLineBuffer);
        JObject.Add('document_lines', JArrLines);

        // Non-ecom paths have no payment lines; the empty array is kept for output-shape parity.
        JObject.Add('payment_lines', JArrPaymentLines);

        exit(JObject);
    end;

    local procedure GetEcomNotificationContent(NotifEntry: Record "NPR Digital Notification Entry"): JsonObject
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        DigitalOrderNotifMgt: Codeunit "NPR Digital Order Notif. Mgt.";
        JObject: JsonObject;
        JArrLines, JArrPaymentLines : JsonArray;
        CurrencyCode: Code[10];
        TotalAmountExclVAT, TotalAmountInclVAT : Decimal;
    begin
        AddNotifEntryFields(JObject, NotifEntry);

        if not EcomSalesHeader.GetBySystemId(NotifEntry."Source Document Id") then begin
            JObject.Add('manifest_url', GetManifestUrl(NotifEntry."Manifest ID"));
            JObject.Add('document_lines', JArrLines);
            JObject.Add('payment_lines', JArrPaymentLines);
            exit(JObject);
        end;

        CurrencyCode := DigitalOrderNotifMgt.GetEffectiveCurrencyCode(EcomSalesHeader."Currency Code");

        JObject.Add('ecom_document_type', EcomSalesHeader."Document Type".Names.Get(
            EcomSalesHeader."Document Type".Ordinals.IndexOf(
                EcomSalesHeader."Document Type".AsInteger())));
        JObject.Add('customer_no', EcomSalesHeader."Sell-to Customer No.");
        JObject.Add('document_date', Format(EcomSalesHeader."Received Date", 0, '<Standard Format,0>'));
        JObject.Add('currency_code', CurrencyCode);

        AddLinesFromEcomDoc(JArrLines, EcomSalesHeader, TotalAmountExclVAT, TotalAmountInclVAT);

        JObject.Add('total_amount_excl_vat', TotalAmountExclVAT);
        JObject.Add('total_amount_excl_vat_formatted', Format(TotalAmountExclVAT, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('total_amount_incl_vat', TotalAmountInclVAT);
        JObject.Add('total_amount_incl_vat_formatted', Format(TotalAmountInclVAT, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('invoice_discount_amount', 0.0);
        JObject.Add('invoice_discount_amount_formatted', Format(0.0, 0, '<Precision,2><Standard Format,2>'));

        JObject.Add('manifest_url', GetManifestUrl(NotifEntry."Manifest ID"));
        _Events.OnAfterAddEcomSalesDocHeaderFieldsToJson(EcomSalesHeader, JObject);

        JObject.Add('document_lines', JArrLines);

        AddPaymentLinesFromEcomDoc(JArrPaymentLines, EcomSalesHeader);
        JObject.Add('payment_lines', JArrPaymentLines);

        _Events.OnAfterGetEcomSalesDocContent(EcomSalesHeader, JObject);
        exit(JObject);
    end;

    local procedure AddLinesFromEcomDoc(
        var JArrLines: JsonArray;
        var EcomSalesHeader: Record "NPR Ecom Sales Header";
        var TotalAmountExclVAT: Decimal;
        var TotalAmountInclVAT: Decimal)
    var
        TempCandidateLine: Record "NPR Ecom Sales Line" temporary;
        DigitalOrderNotifMgt: Codeunit "NPR Digital Order Notif. Mgt.";
        WalletExtLineIds: Dictionary of [Text[100], Boolean];
        JObjectLine: JsonObject;
        AssetType: Enum "NPR Dig. Notif. Asset Type";
        LineAmountExclVAT, LineAmountInclVAT : Decimal;
    begin
        DigitalOrderNotifMgt.CollectEcomLinesAndWalletSet(EcomSalesHeader."Entry No.", TempCandidateLine, WalletExtLineIds);

        if not TempCandidateLine.FindSet() then
            exit;

        repeat
            if DigitalOrderNotifMgt.ShouldEmitEcomAssetLine(TempCandidateLine, WalletExtLineIds) then begin
                Clear(JObjectLine);
                AssetType := DigitalOrderNotifMgt.IdentifyEcomLineAssetType(TempCandidateLine."Is Attraction Wallet", TempCandidateLine.Subtype);

                DigitalOrderNotifMgt.CalcEcomLineAmounts(TempCandidateLine."Line Amount", TempCandidateLine."VAT %", EcomSalesHeader."Price Excl. VAT", LineAmountExclVAT, LineAmountInclVAT);

                JObjectLine.Add('line_no', TempCandidateLine."Line No.");
                JObjectLine.Add('no', TempCandidateLine."No.");
                JObjectLine.Add('variant_code', TempCandidateLine."Variant Code");
                JObjectLine.Add('asset_type', GetAssetTypeName(AssetType));
                JObjectLine.Add('description', TempCandidateLine.Description);
                JObjectLine.Add('quantity', TempCandidateLine.Quantity);
                JObjectLine.Add('unit_price_incl_vat', TempCandidateLine."Unit Price");
                JObjectLine.Add('unit_price_incl_vat_formatted', Format(TempCandidateLine."Unit Price", 0, '<Precision,2><Standard Format,2>'));
                JObjectLine.Add('line_amount_excl_vat', LineAmountExclVAT);
                JObjectLine.Add('line_amount_excl_vat_formatted', Format(LineAmountExclVAT, 0, '<Precision,2><Standard Format,2>'));
                JObjectLine.Add('line_amount_incl_vat', LineAmountInclVAT);
                JObjectLine.Add('line_amount_incl_vat_formatted', Format(LineAmountInclVAT, 0, '<Precision,2><Standard Format,2>'));
                JObjectLine.Add('line_discount_amount', 0.0);
                JObjectLine.Add('line_discount_amount_formatted', Format(0.0, 0, '<Precision,2><Standard Format,2>'));
                JObjectLine.Add('vat_pct', TempCandidateLine."VAT %");
                JObjectLine.Add('vat_pct_formatted', Format(TempCandidateLine."VAT %", 0, '<Precision,2><Standard Format,2>'));

                _Events.OnAfterAddEcomSalesDocLineJson(EcomSalesHeader, TempCandidateLine, JObjectLine);

                JArrLines.Add(JObjectLine);

                TotalAmountExclVAT += LineAmountExclVAT;
                TotalAmountInclVAT += LineAmountInclVAT;
            end;
        until TempCandidateLine.Next() = 0;
    end;

    local procedure PopulateBuffersFromNotifEntry(
        NotifEntry: Record "NPR Digital Notification Entry";
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary)
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        DigitalOrderNotifMgt: Codeunit "NPR Digital Order Notif. Mgt.";
    begin
        case NotifEntry."Document Type" of
            NotifEntry."Document Type"::Invoice:
                begin
                    if SalesInvHeader.Get(NotifEntry."Posted Document No.") then
                        DigitalOrderNotifMgt.PopulateBuffersFromInvoice(SalesInvHeader, NotifEntry."Notification Type", TempHeaderBuffer, TempLineBuffer);
                end;
            NotifEntry."Document Type"::"Credit Memo":
                begin
                    if SalesCrMemoHeader.Get(NotifEntry."Posted Document No.") then
                        DigitalOrderNotifMgt.PopulateBuffersFromCrMemo(SalesCrMemoHeader, NotifEntry."Notification Type", TempHeaderBuffer, TempLineBuffer);
                end;
        end;
    end;

    local procedure AddNotifEntryFields(var JObject: JsonObject; NotifEntry: Record "NPR Digital Notification Entry")
    begin
        JObject.Add('order_number', NotifEntry."External Order No.");
        JObject.Add('recipient_email', NotifEntry."Recipient E-mail");
        JObject.Add('recipient_name', NotifEntry."Recipient Name");
        JObject.Add('language_code', NotifEntry."Language Code");
        JObject.Add('doc_type', NotifEntry."Document Type".Names.Get(
            NotifEntry."Document Type".Ordinals.IndexOf(
                NotifEntry."Document Type".AsInteger())));
        JObject.Add('notification_type', NotifEntry."Notification Type".Names.Get(
            NotifEntry."Notification Type".Ordinals.IndexOf(
                NotifEntry."Notification Type".AsInteger())));
        JObject.Add('source_document_id', Format(NotifEntry."Source Document Id", 0, 4).ToLower());
        JObject.Add('posted_doc_no', NotifEntry."Posted Document No.");
    end;

    local procedure AddHeaderFieldsFromBuffer(var JObject: JsonObject; var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary)
    begin
        if not TempHeaderBuffer.FindFirst() then
            exit;

        JObject.Add('customer_no', TempHeaderBuffer."Customer No.");
        JObject.Add('document_date', Format(TempHeaderBuffer."Document Date", 0, '<Standard Format,0>'));
        JObject.Add('currency_code', TempHeaderBuffer."Currency Code");
        JObject.Add('total_amount_excl_vat', TempHeaderBuffer."Total Amount Excl. VAT");
        JObject.Add('total_amount_excl_vat_formatted', Format(TempHeaderBuffer."Total Amount Excl. VAT", 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('total_amount_incl_vat', TempHeaderBuffer."Total Amount Incl. VAT");
        JObject.Add('total_amount_incl_vat_formatted', Format(TempHeaderBuffer."Total Amount Incl. VAT", 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('invoice_discount_amount', TempHeaderBuffer."Invoice Discount Amount");
        JObject.Add('invoice_discount_amount_formatted', Format(TempHeaderBuffer."Invoice Discount Amount", 0, '<Precision,2><Standard Format,2>'));
    end;

    local procedure AddLinesFromBuffer(
        var JArrLines: JsonArray;
        var TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        var TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary)
    var
        DigitalOrderNotifMgt: Codeunit "NPR Digital Order Notif. Mgt.";
        JObjectLine: JsonObject;
        AssetType: Enum "NPR Dig. Notif. Asset Type";
    begin
        if not TempLineBuffer.FindSet() then
            exit;

        repeat
            Clear(JObjectLine);
            JObjectLine.Add('line_no', TempLineBuffer."Line No.");
            JObjectLine.Add('no', TempLineBuffer."No.");
            JObjectLine.Add('variant_code', TempLineBuffer."Variant Code");

            AssetType := DigitalOrderNotifMgt.IdentifyAssetType(TempHeaderBuffer, TempLineBuffer);
            JObjectLine.Add('asset_type', GetAssetTypeName(AssetType));

            JObjectLine.Add('description', TempLineBuffer.Description);
            JObjectLine.Add('quantity', TempLineBuffer.Quantity);
            JObjectLine.Add('unit_price_incl_vat', TempLineBuffer."Unit Price");
            JObjectLine.Add('unit_price_incl_vat_formatted', Format(TempLineBuffer."Unit Price", 0, '<Precision,2><Standard Format,2>'));
            JObjectLine.Add('line_amount_excl_vat', TempLineBuffer.Amount);
            JObjectLine.Add('line_amount_excl_vat_formatted', Format(TempLineBuffer.Amount, 0, '<Precision,2><Standard Format,2>'));
            JObjectLine.Add('line_amount_incl_vat', TempLineBuffer."Amount Including VAT");
            JObjectLine.Add('line_amount_incl_vat_formatted', Format(TempLineBuffer."Amount Including VAT", 0, '<Precision,2><Standard Format,2>'));
            JObjectLine.Add('line_discount_amount', TempLineBuffer."Line Discount Amount");
            JObjectLine.Add('line_discount_amount_formatted', Format(TempLineBuffer."Line Discount Amount", 0, '<Precision,2><Standard Format,2>'));
            JObjectLine.Add('vat_pct', TempLineBuffer."VAT %");
            JObjectLine.Add('vat_pct_formatted', Format(TempLineBuffer."VAT %", 0, '<Precision,2><Standard Format,2>'));

            JArrLines.Add(JObjectLine);
        until TempLineBuffer.Next() = 0;
    end;

    local procedure AddPaymentLinesFromEcomDoc(
        var JArrPaymentLines: JsonArray;
        var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        JObjectPaymentLine: JsonObject;
    begin
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if not EcomSalesPmtLine.FindSet() then
            exit;

        repeat
            Clear(JObjectPaymentLine);
            JObjectPaymentLine.Add('line_no', EcomSalesPmtLine."Line No.");
            JObjectPaymentLine.Add('payment_method_type', EcomSalesPmtLine."Payment Method Type".Names.Get(
                EcomSalesPmtLine."Payment Method Type".Ordinals.IndexOf(
                    EcomSalesPmtLine."Payment Method Type".AsInteger())));
            JObjectPaymentLine.Add('external_payment_type', EcomSalesPmtLine."External Payment Type");
            JObjectPaymentLine.Add('external_payment_method_code', EcomSalesPmtLine."External Payment Method Code");
            JObjectPaymentLine.Add('description', EcomSalesPmtLine.Description);
            JObjectPaymentLine.Add('amount', EcomSalesPmtLine.Amount);
            JObjectPaymentLine.Add('amount_formatted', Format(EcomSalesPmtLine.Amount, 0, '<Precision,2><Standard Format,2>'));
            JObjectPaymentLine.Add('captured_amount', EcomSalesPmtLine."Captured Amount");
            JObjectPaymentLine.Add('captured_amount_formatted', Format(EcomSalesPmtLine."Captured Amount", 0, '<Precision,2><Standard Format,2>'));
            JObjectPaymentLine.Add('invoiced_amount', EcomSalesPmtLine."Invoiced Amount");
            JObjectPaymentLine.Add('invoiced_amount_formatted', Format(EcomSalesPmtLine."Invoiced Amount", 0, '<Precision,2><Standard Format,2>'));
            // Payment-state signals: templates can branch on date_authorized (empty when payment has not
            // been authorized — e.g. failed auth retries) and expires_at (auth/payment expiration).
            JObjectPaymentLine.Add('date_authorized', Format(EcomSalesPmtLine."Date Authorized", 0, '<Standard Format,0>'));
            JObjectPaymentLine.Add('expires_at', Format(EcomSalesPmtLine."Expires At", 0, 9));
            JObjectPaymentLine.Add('payment_reference', EcomSalesPmtLine."Payment Reference");
            JObjectPaymentLine.Add('card_brand', EcomSalesPmtLine."Card Brand");
            JObjectPaymentLine.Add('masked_card_number', EcomSalesPmtLine."Masked Card Number");

            _Events.OnAfterAddEcomSalesDocPaymentLineJson(EcomSalesHeader, EcomSalesPmtLine, JObjectPaymentLine);

            JArrPaymentLines.Add(JObjectPaymentLine);
        until EcomSalesPmtLine.Next() = 0;
    end;

    local procedure GetAssetTypeName(AssetType: Enum "NPR Dig. Notif. Asset Type"): Text
    begin
        // Return the (untranslated) enum value name, not the caption, so the JSON asset_type stays stable across languages.
        exit(AssetType.Names().Get(AssetType.Ordinals().IndexOf(AssetType.AsInteger())));
    end;

    local procedure GetManifestUrl(ManifestId: Guid) Url: Text[250]
    var
        NpDesigner: Codeunit "NPR NPDesigner";
    begin
        if (IsNullGuid(ManifestId)) then
            exit;

        NpDesigner.GetManifestUrl(ManifestId, Url);
    end;
}
#endif

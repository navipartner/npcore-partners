#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248185 "NPR NPEmailDigNotifDataProv" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

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
        JObject, JObjectLine : JsonObject;
        JArrLines: JsonArray;
    begin
        JObject.Add('order_number', 'MAG-2024-001234');
        JObject.Add('recipient_email', 'customer@example.com');
        JObject.Add('recipient_name', 'John Doe');
        JObject.Add('language_code', 'ENU');
        JObject.Add('doc_type', 'Invoice');
        JObject.Add('posted_doc_no', 'SI-001234');
        JObject.Add('customer_no', 'C-00001');
        JObject.Add('document_date', Format(20240115D, 0, '<Standard Format,0>'));
        JObject.Add('currency_code', 'EUR');
        JObject.Add('total_amount_excl_vat', 100.0);
        JObject.Add('total_amount_excl_vat_formatted', Format(100.0, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('total_amount_incl_vat', 125.0);
        JObject.Add('total_amount_incl_vat_formatted', Format(125.0, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('invoice_discount_amount', 25.0);
        JObject.Add('invoice_discount_amount_formatted', Format(25.0, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('manifest_url', 'https://npdesigner.example.com/manifest/12345678-1234-1234-1234-123456789abc');

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
        JArrLines.Add(JObjectLine);
        JObject.Add('document_lines', JArrLines);

        exit(JObject);
    end;

    local procedure GetNotificationContent(NotifEntry: Record "NPR Digital Notification Entry"): JsonObject
    var
        TempHeaderBuffer: Record "NPR Digital Doc. Header Buffer" temporary;
        TempLineBuffer: Record "NPR Digital Doc. Line Buffer" temporary;
        JObject: JsonObject;
        JArrLines: JsonArray;
    begin
        PopulateBuffersFromNotifEntry(NotifEntry, TempHeaderBuffer, TempLineBuffer);

        JObject.Add('order_number', NotifEntry."External Order No.");
        JObject.Add('recipient_email', NotifEntry."Recipient E-mail");
        JObject.Add('recipient_name', NotifEntry."Recipient Name");
        JObject.Add('language_code', NotifEntry."Language Code");
        JObject.Add('doc_type', NotifEntry."Document Type".Names.Get(
            NotifEntry."Document Type".Ordinals.IndexOf(
                NotifEntry."Document Type".AsInteger())));
        JObject.Add('posted_doc_no', NotifEntry."Posted Document No.");

        AddHeaderFieldsFromBuffer(JObject, TempHeaderBuffer);

        JObject.Add('manifest_url', GetManifestUrl(NotifEntry."Manifest ID"));

        AddLinesFromBuffer(JArrLines, TempHeaderBuffer, TempLineBuffer);
        JObject.Add('document_lines', JArrLines);

        exit(JObject);
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
                        DigitalOrderNotifMgt.PopulateBuffersFromInvoice(SalesInvHeader, TempHeaderBuffer, TempLineBuffer);
                end;
            NotifEntry."Document Type"::"Credit Memo":
                begin
                    if SalesCrMemoHeader.Get(NotifEntry."Posted Document No.") then
                        DigitalOrderNotifMgt.PopulateBuffersFromCrMemo(SalesCrMemoHeader, TempHeaderBuffer, TempLineBuffer);
                end;
        end;
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
        AssetType: Option None,Voucher,"Member Card",Coupon,Ticket,Wallet;
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

    local procedure GetAssetTypeName(AssetTypeOrdinal: Integer): Text[20]
    begin
        case AssetTypeOrdinal of
            0:
                exit('None');
            1:
                exit('Voucher');
            2:
                exit('Member Card');
            3:
                exit('Coupon');
            4:
                exit('Ticket');
            5:
                exit('Wallet');
        end;
        exit('None');
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

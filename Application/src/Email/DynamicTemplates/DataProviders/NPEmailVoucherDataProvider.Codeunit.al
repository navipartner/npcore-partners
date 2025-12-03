#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248563 "NPR NPEmailVoucherDataProvider" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        Voucher: Record "NPR NpRv Voucher";
        WrongRecordReceivedErr: Label 'The code received a record of an unknown type. Most likely a wrong data driver was used on the Dynamic Template.';
    begin
        if RecRef.Number() <> Database::"NPR NpRv Voucher" then
            Error(WrongRecordReceivedErr);
        RecRef.SetTable(Voucher);
        exit(VoucherToJson(Voucher));
    end;

    procedure GenerateContentExample(): JsonObject
    var
        JObject: JsonObject;
        Voucher: Record "NPR NpRv Voucher";
    begin
        JObject.Add('voucher_no', '000000');
        JObject.Add('voucher_type', 'GIFTVOUCHER');
        JObject.Add('description', 'Giftvoucher 0000000');
        JObject.Add('reference_no', '1234567890123');
        JObject.Add('starting_date', CreateDateTime(20250101D, 0T));
        JObject.Add('starting_date_formatted', Format(CreateDateTime(20250101D, 0T), 0, '<Standard Format,0>'));
        JObject.Add('ending_date', CreateDateTime(20251231D, 0T));
        JObject.Add('ending_date_formatted', Format(CreateDateTime(20251231D, 0T), 0, '<Standard Format,0>'));
        JObject.Add('no_series', 'VOUCHERS');
        JObject.Add('arch_no_series', 'ARCH_VOUCHERS');
        JObject.Add('arch_no', 'A000000');
        JObject.Add('account_no', 'ACC00000');
        JObject.Add('provision_account_no', 'ACC00001');
        JObject.Add('allow_top_up', true);
        JObject.Add('open', true);
        JObject.Add('amount', 150.00);
        JObject.Add('amount_formatted', Format(150.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('initial_amount', 520.00);
        JObject.Add('initial_amount_formatted', Format(520.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('reserved_amount', 25.00);
        JObject.Add('reserved_amount_formatted', Format(25.00, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('in_use_quantity', 2);
        JObject.Add('sms_template_code', 'SMS TEMPLATE');
        JObject.Add('send_voucher_module', 'SEND MODULE');
        JObject.Add('send_via_print', false);
        JObject.Add('send_via_email', true);
        JObject.Add('send_via_sms', true);
        JObject.Add('validate_voucher_module', 'VALIDATE MODULE');
        JObject.Add('apply_payment_module', 'APPLY MODULE');
        JObject.Add('customer_no', 'CUST00000');
        JObject.Add('contact_no', 'CONT00000');
        JObject.Add('name', 'Voucher Name');
        JObject.Add('name2', 'Voucher Name2');
        JObject.Add('address', 'Voucher Address');
        JObject.Add('address2', 'Voucher Address 2');
        JObject.Add('post_code', 'Post Code');
        JObject.Add('city', 'City');
        JObject.Add('county', 'County');
        JObject.Add('country_region_code', 'Country/Region Code');
        JObject.Add('email', 'test@example.com');
        JObject.Add('phone_no', '1234567890');
        JObject.Add('language_code', 'GER');
        JObject.Add('voucher_message', 'Up to 250 character message');
        JObject.Add('spfy_send_from_shopify', false);
        JObject.Add('spfy_send_on', 0DT);
        JObject.Add('spfy_send_on_formatted', Format(0DT, 0, '<Standard Format,0>'));
        JObject.Add('spfy_liquid_template_suffix', 'abc');
        JObject.Add('spfy_recipient_email', 'test@example.com');
        JObject.Add('spfy_recipient_name', '');
        JObject.Add('issue_date', 20250101D);
        JObject.Add('issue_date_formatted', Format(20250101D, 0, '<Standard Format,0>'));
        JObject.Add('issue_register_no', 'POS00000');
        JObject.Add('issue_document_type', Voucher."Issue Document Type"::"Audit Roll");
        JObject.Add('issue_document_no', 'TIC00000');
        JObject.Add('issue_external_document_no', 'EXT00000');
        JObject.Add('issue_user_id', 'POSUSER');
        JObject.Add('issue_partner_code', 'PARTNER');
        JObject.Add('partner_clearing', true);
        JObject.Add('no_send', 2);
        JObject.Add('disabled_for_web_service', false);
        JObject.Add('comment', 'Up to 250 character message');
        JObject.Add('manifest_url', 'https://assets.npretail.app/manifest/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx');
        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
    end;

    local procedure VoucherToJson(Voucher: Record "NPR NpRv Voucher"): JsonObject
    var
        JObject: JsonObject;
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
    begin
        Voucher.CalcFields(Open, Amount, "Initial Amount", "Reserved Amount", "In-use Quantity", "Send Voucher Module", "Validate Voucher Module", "Apply Payment Module", "Issue Date", "Issue Register No.", "Issue Document Type", "Issue Document No.", "Issue External Document No.", "Issue User ID", "Issue Partner Code", "Partner Clearing", "No. Send");
        JObject.Add('voucher_no', Voucher."No.");
        JObject.Add('voucher_type', Voucher."Voucher Type");
        JObject.Add('description', Voucher.Description);
        JObject.Add('reference_no', Voucher."Reference No.");
        JObject.Add('starting_date', Voucher."Starting Date");
        JObject.Add('starting_date_formatted', DataProviderHelper.FormatToTextFromLanguage(Voucher."Starting Date", Voucher."Language Code"));
        JObject.Add('ending_date', Voucher."Ending Date");
        JObject.Add('ending_date_formatted', DataProviderHelper.FormatToTextFromLanguage(Voucher."Ending Date", Voucher."Language Code"));
        JObject.Add('no_series', Voucher."No. Series");
        JObject.Add('arch_no_series', Voucher."Arch. No. Series");
        JObject.Add('arch_no', Voucher."Arch. No.");
        JObject.Add('account_no', Voucher."Account No.");
        JObject.Add('provision_account_no', Voucher."Provision Account No.");
        JObject.Add('allow_top_up', Voucher."Allow Top-up");
        JObject.Add('open', Voucher.Open);
        JObject.Add('amount', Voucher.Amount);
        JObject.Add('amount_formatted', DataProviderHelper.FormatToTextFromLanguage(Voucher.Amount, Voucher."Language Code"));
        JObject.Add('initial_amount', Voucher."Initial Amount");
        JObject.Add('initial_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(Voucher."Initial Amount", Voucher."Language Code"));
        JObject.Add('reserved_amount', Voucher."Reserved Amount");
        JObject.Add('reserved_amount_formatted', DataProviderHelper.FormatToTextFromLanguage(Voucher."Reserved Amount", Voucher."Language Code"));
        JObject.Add('in_use_quantity', Voucher."In-use Quantity");
        JObject.Add('sms_template_code', Voucher."SMS Template Code");
        JObject.Add('send_voucher_module', Voucher."Send Voucher Module");
        JObject.Add('send_via_print', Voucher."Send via Print");
        JObject.Add('send_via_email', Voucher."Send via E-mail");
        JObject.Add('send_via_sms', Voucher."Send via SMS");
        JObject.Add('validate_voucher_module', Voucher."Validate Voucher Module");
        JObject.Add('apply_payment_module', Voucher."Apply Payment Module");
        JObject.Add('customer_no', Voucher."Customer No.");
        JObject.Add('contact_no', Voucher."Contact No.");
        JObject.Add('name', Voucher.Name);
        JObject.Add('name2', Voucher."Name 2");
        JObject.Add('address', Voucher.Address);
        JObject.Add('address2', Voucher."Address 2");
        JObject.Add('post_code', Voucher."Post Code");
        JObject.Add('city', Voucher.City);
        JObject.Add('county', Voucher.County);
        JObject.Add('country_region_code', Voucher."Country/Region Code");
        JObject.Add('email', Voucher."E-mail");
        JObject.Add('phone_no', Voucher."Phone No.");
        JObject.Add('language_code', Voucher."Language Code");
        JObject.Add('voucher_message', Voucher."Voucher Message");
        JObject.Add('spfy_send_from_shopify', Voucher."Spfy Send from Shopify");
        JObject.Add('spfy_send_on', Voucher."Spfy Send on");
        JObject.Add('spfy_send_on_formatted', DataProviderHelper.FormatToTextFromLanguage(Voucher."Spfy Send on", Voucher."Language Code"));
        JObject.Add('spfy_liquid_template_suffix', Voucher."Spfy Liquid Template Suffix");
        JObject.Add('spfy_recipient_email', Voucher."Spfy Recipient E-mail");
        JObject.Add('spfy_recipient_name', Voucher."Spfy Recipient Name");
        JObject.Add('issue_date', Voucher."Issue Date");
        JObject.Add('issue_date_formatted', DataProviderHelper.FormatToTextFromLanguage(Voucher."Issue Date", Voucher."Language Code"));
        JObject.Add('issue_register_no', Voucher."Issue Register No.");
        JObject.Add('issue_document_type', Voucher."Issue Document Type");
        JObject.Add('issue_document_no', Voucher."Issue Document No.");
        JObject.Add('issue_external_document_no', Voucher."Issue External Document No.");
        JObject.Add('issue_user_id', Voucher."Issue User ID");
        JObject.Add('issue_partner_code', Voucher."Issue Partner Code");
        JObject.Add('partner_clearing', Voucher."Partner Clearing");
        JObject.Add('no_send', Voucher."No. Send");
        JObject.Add('disabled_for_web_service', Voucher."Disabled for Web Service");
        JObject.Add('comment', Voucher.Comment);
        JObject.Add('manifest_url', GetManifestUrl(Voucher."Voucher Type", Voucher."Language Code", Voucher.SystemId, Voucher."Reference No."));
        exit(JObject);
    end;

    local procedure GetManifestUrl(VoucherTypeCode: Code[20]; LanguageCode: Code[10]; AssetId: Guid; ExternalReferenceNumber: Text[50]) Url: Text[250]
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        DesignerManifestFacade: Codeunit "NPR NPDesignerManifestFacade";
        ManifestId: Guid;
    begin
        if (not VoucherType.Get(VoucherTypeCode)) then
            exit('');

        if (VoucherType.PDFDesignerTemplateId = '') then
            exit('');

        ManifestId := DesignerManifestFacade.CreateManifest(VoucherType.PDFDesignerTemplateId, LanguageCode, false);
        if (DesignerManifestFacade.AddAssetToManifest(ManifestId, Database::"NPR NpRv Voucher", AssetId, ExternalReferenceNumber, VoucherType.PDFDesignerTemplateId)) then
            if (not DesignerManifestFacade.GetManifestUrl(ManifestId, Url)) then
                Url := '';
    end;

}
#endif

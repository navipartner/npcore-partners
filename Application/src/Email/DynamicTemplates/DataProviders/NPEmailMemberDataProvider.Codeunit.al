#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248377 "NPR NPEmailMemberDataProvider" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    var
        _DynTempDataProvSubs: Codeunit "NPR DynTempDataProvSubs";

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        Entry: Record "NPR MM Member Notific. Entry";
        EntryBuffer: Record "NPR MMMemberNotificEntryBuf";
        JObject, CustomJObject : JsonObject;
        WrongRecordReceivedErr: Label 'The code received a record of an unknown type. Most likely a wrong data driver was used on the Dynamic Template.';
    begin
        if (RecRef.Number <> Database::"NPR MM Member Notific. Entry") then
            Error(WrongRecordReceivedErr);

        RecRef.SetTable(Entry);

        JObject.Add('coupon_reference_no', Entry."Coupon Reference No.");
        JObject.Add('coupon_starting_date', Entry."Coupon Starting Date");
        JObject.Add('coupon_ending_date', Entry."Coupon Ending Date");
        JObject.Add('coupon_discount_type', Entry."Coupon Discount Type");
        JObject.Add('coupon_discount_amount', Entry."Coupon Discount Amount");
        JObject.Add('coupon_discount_pct', Entry."Coupon Discount %");
        JObject.Add('coupon_description', Entry."Coupon Description");
        JObject.Add('member_external_no', Entry."External Member No.");
        JObject.Add('member_name', Entry."Display Name");
        JObject.Add('member_first_name', Entry."First Name");
        JObject.Add('member_middle_name', Entry."Middle Name");
        JObject.Add('member_last_name', Entry."Last Name");
        JObject.Add('member_email_address', Entry."E-Mail Address");
        JObject.Add('member_phone_no', Entry."Phone No.");
        JObject.Add('member_post_code', Entry."Post Code Code");
        JObject.Add('member_city', Entry.City);
        JObject.Add('member_country_code', Entry."Country Code");
        JObject.Add('member_country', Entry.Country);
        JObject.Add('member_birthday', Entry.Birthday);
        JObject.Add('member_card_no', Entry."External Member Card No.");
        JObject.Add('membership_code', Entry."Membership Code");
        JObject.Add('membership_external_no', Entry."External Membership No.");
        JObject.Add('membership_valid_from', Entry."Membership Valid From");
        JObject.Add('membership_valid_until', Entry."Membership Valid Until");
        JObject.Add('membership_description', Entry."Membership Description");
        JObject.Add('membership_auto_renew', "NPR MM MembershipAutoRenew".Names().Get("NPR MM MembershipAutoRenew".Ordinals().IndexOf("NPR MM MembershipAutoRenew"::YES_INTERNAL.AsInteger())));
        JObject.Add('membership_remaining_points', Entry."Remaining Points");
        JObject.Add('community_description', Entry."Community Description");
        JObject.Add('subscription_rejected_reason_code', Entry."Rejected Reason Code");
        JObject.Add('subscription_rejected_reason_description', Entry."Rejected Reason Description");
        JObject.Add('pay_by_link_url', Entry."Pay by Link URL");
        JObject.Add('client_sign_up_url', Entry.ClientSignUpUrl);
        JObject.Add('wallet_pass_id', Entry."Wallet Pass Id");
        JObject.Add('wallet_url', Entry."Wallet Pass Landing URL");

        EntryBuffer.TransferFields(Entry, true);
        EntryBuffer.SystemId := Entry.SystemId;
        EntryBuffer.Insert();
        _DynTempDataProvSubs.OnAfterMemberGetContent(EntryBuffer, CustomJObject);
        JObject.Add('custom_fields', CustomJObject);

        exit(JObject);
    end;

    procedure GenerateContentExample(): JsonObject
    var
        JObject, CustomJObject : JsonObject;
    begin
        JObject.Add('coupon_reference_no', 'COUPON1234');
        JObject.Add('coupon_starting_date', 20250101D);
        JObject.Add('coupon_ending_date', 20251231D);
        JObject.Add('coupon_discount_type', 'Discount Amount');
        JObject.Add('coupon_discount_amount', 100.0);
        JObject.Add('coupon_discount_pct', 25);
        JObject.Add('coupon_description', 'Test coupon!');
        JObject.Add('member_external_no', 'MM1234567890');
        JObject.Add('member_name', 'Hans Jens Hansen');
        JObject.Add('member_first_name', 'Hans');
        JObject.Add('member_middle_name', 'Jens');
        JObject.Add('member_last_name', 'Hansen');
        JObject.Add('member_email_address', 'test@example.com');
        JObject.Add('member_phone_no', '+4512345678');
        JObject.Add('member_post_code', '2200');
        JObject.Add('member_city', 'Copenhagen');
        JObject.Add('member_country_code', 'DK');
        JObject.Add('member_country', 'Denmark');
        JObject.Add('member_birthday', 20200101D);
        JObject.Add('member_card_no', 'DEMO-123414-T');
        JObject.Add('membership_code', 'GOLD');
        JObject.Add('membership_external_no', 'MS123456789');
        JObject.Add('membership_valid_from', 20250101D);
        JObject.Add('membership_valid_until', 20251130D);
        JObject.Add('membership_description', 'Gold membership');
        JObject.Add('membership_auto_renew', "NPR MM MembershipAutoRenew".Names().Get("NPR MM MembershipAutoRenew".Ordinals().IndexOf("NPR MM MembershipAutoRenew"::YES_INTERNAL.AsInteger())));
        JObject.Add('membership_remaining_points', 0);
        JObject.Add('community_description', 'Awesome member community');
        JObject.Add('subscription_rejected_reason_code', 'Failed');
        JObject.Add('subscription_rejected_reason_description', 'Insufficient funds available.');
        JObject.Add('pay_by_link_url', 'https://payment.example.com/session/123456789');
        JObject.Add('client_sign_up_url', 'https://signup.example.com/973d46f0-a08c-45e3-a9ac-0da53b28648a');
        JObject.Add('wallet_pass_id', 'ABCD1234');
        JObject.Add('wallet_url', 'https://passes.example.com');

        _DynTempDataProvSubs.OnAfterMemberGenerateContentExample(CustomJObject);
        JObject.Add('custom_fields', CustomJObject);

        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
        // do nothing, we don't support adding attachments
    end;
}
#endif
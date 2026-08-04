#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248408 "NPR NPEmailTicketDataProvider" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        Entry: Record "NPR TM Ticket Notif. Entry";
        JObject: JsonObject;
        WrongRecordReceivedErr: Label 'The code received a record of an unknown type. Most likely a wrong data driver was used on the Dynamic Template.';
        DataProviderHelper: Codeunit "NPR DynTemplateDataProvHelper";
    begin
        if (RecRef.Number() <> Database::"NPR TM Ticket Notif. Entry") then
            Error(WrongRecordReceivedErr);

        RecRef.SetTable(Entry);

        JObject.Add('ticket_type_code', Entry."Ticket Type Code");
        JObject.Add('ticket_token', Entry."Ticket Token");
        JObject.Add('ticket_item_no', Entry."Ticket Item No.");
        JObject.Add('ticket_variant_code', Entry."Ticket Variant Code");
        JObject.Add('ticket_external_item_no', Entry."Ticket External Item No.");
        JObject.Add('ticket_external_no', Entry."External Ticket No.");
        JObject.Add('ticket_relevant_date', Entry."Relevant Date");
        JObject.Add('ticket_relevant_date_formatted', DataProviderHelper.FormatToTextFromLanguage(Entry."Relevant Date", Entry."Ticket Holder Preferred Lang"));
        JObject.Add('ticket_relevant_time', Entry."Relevant Time");
        JObject.Add('ticket_relevant_time_formatted', DataProviderHelper.FormatToTextFromLanguage(Entry."Relevant Time", Entry."Ticket Holder Preferred Lang"));
        JObject.Add('ticket_relevant_datetime', Entry."Relevant Datetime");
        JObject.Add('ticket_relevant_datetime_formatted', DataProviderHelper.FormatToTextFromLanguage(Entry."Relevant Datetime", Entry."Ticket Holder Preferred Lang"));
        JObject.Add('ticket_holder_name', Entry."Ticket Holder Name");
        JObject.Add('ticket_holder_email', Entry."Ticket Holder E-Mail");
        JObject.Add('ticket_bom_description', Entry."Ticket BOM Description");
        JObject.Add('ticket_bom_admission_description', Entry."Ticket BOM Adm. Description");
        JObject.Add('ticket_admission_event_description', Entry."Adm. Event Description");
        JObject.Add('ticket_admission_location_description', Entry."Adm. Location Description");
        JObject.Add('admission_code', Entry."Admission Code");
        JObject.Add('notification_address', Entry."Notification Address");
        JObject.Add('event_start_date', Entry."Event Start Date");
        JObject.Add('event_start_date_formatted', DataProviderHelper.FormatToTextFromLanguage(Entry."Event Start Date", Entry."Ticket Holder Preferred Lang"));
        JObject.Add('event_start_time', Entry."Event Start Time");
        JObject.Add('event_start_time_formatted', DataProviderHelper.FormatToTextFromLanguage(Entry."Event Start Time", Entry."Ticket Holder Preferred Lang"));
        JObject.Add('eticket_pass_id', Entry."eTicket Pass Id");
        JObject.Add('eticket_pass_landing_url', Entry."eTicket Pass Landing URL");
        JObject.Add('published_ticket_url', Entry."Published Ticket URL");
        JObject.Add('npdesigner_template_id', Entry.NPDesignerTemplateId);
        JObject.Add('external_order_no', Entry."External Order No.");
        JObject.Add('quantity_to_admit', Entry."Quantity To Admit");
        JObject.Add('entry_no', Entry."Entry No.");
        JObject.Add('notification_group_id', Entry."Notification Group Id");
        JObject.Add('date_to_notify', Entry."Date To Notify");
        JObject.Add('date_to_notify_formatted', DataProviderHelper.FormatToTextFromLanguage(Entry."Date To Notify", Entry."Ticket Holder Preferred Lang"));
        JObject.Add('time_to_notify', Entry."Time To Notify");
        JObject.Add('time_to_notify_formatted', DataProviderHelper.FormatToTextFromLanguage(Entry."Time To Notify", Entry."Ticket Holder Preferred Lang"));
        JObject.Add('notification_trigger', GetEnumValueName(RecRef, Entry.FieldNo("Notification Trigger"), Entry."Notification Trigger".AsInteger()));
        JObject.Add('template_code', Entry."Template Code");
        JObject.Add('notification_process_method', GetEnumValueName(RecRef, Entry.FieldNo("Notification Process Method"), Entry."Notification Process Method".AsInteger()));
        JObject.Add('ticket_no', Entry."Ticket No.");
        JObject.Add('ticket_list_price', Entry."Ticket List Price");
        JObject.Add('ticket_list_price_formatted', DataProviderHelper.FormatToTextFromLanguage(Entry."Ticket List Price", Entry."Ticket Holder Preferred Lang"));
        JObject.Add('detention_time_seconds', Entry."Detention Time Seconds");
        JObject.Add('notification_profile_code', Entry."Notification Profile Code");
        JObject.Add('notification_engine', GetEnumValueName(RecRef, Entry.FieldNo("Notification Engine"), Entry."Notification Engine"));
        JObject.Add('notification_method', GetEnumValueName(RecRef, Entry.FieldNo("Notification Method"), Entry."Notification Method".AsInteger()));
        JObject.Add('authorization_code', Entry."Authorization Code");
        JObject.Add('ticket_expire_date', Entry."Expire Date");
        JObject.Add('ticket_expire_date_formatted', DataProviderHelper.FormatToTextFromLanguage(Entry."Expire Date", Entry."Ticket Holder Preferred Lang"));
        JObject.Add('ticket_expire_time', Entry."Expire Time");
        JObject.Add('ticket_expire_time_formatted', DataProviderHelper.FormatToTextFromLanguage(Entry."Expire Time", Entry."Ticket Holder Preferred Lang"));
        JObject.Add('ticket_expire_datetime', Entry."Expire Datetime");
        JObject.Add('ticket_expire_datetime_formatted', DataProviderHelper.FormatToTextFromLanguage(Entry."Expire Datetime", Entry."Ticket Holder Preferred Lang"));
        JObject.Add('ticket_voided', Entry.Voided);
        JObject.Add('ticket_no_for_printing', Entry."Ticket No. for Printing");
        JObject.Add('admission_schedule_entry_no', Entry."Admission Schedule Entry No.");
        JObject.Add('det_ticket_access_entry_no', Entry."Det. Ticket Access Entry No.");
        JObject.Add('extra_text', Entry."Extra Text");
        JObject.Add('section', Entry.Section);
        JObject.Add('row', Entry.Row);
        JObject.Add('seat', Entry.Seat);
        JObject.Add('ticket_holder_preferred_language', Entry."Ticket Holder Preferred Lang");
        JObject.Add('waiting_list_reference_code', Entry."Waiting List Reference Code");
        JObject.Add('ticket_trigger_type', GetEnumValueName(RecRef, Entry.FieldNo("Ticket Trigger Type"), Entry."Ticket Trigger Type".AsInteger()));
        JObject.Add('eticket_type_code', Entry."eTicket Type Code");
        JObject.Add('eticket_pass_default_url', Entry."eTicket Pass Default URL");
        JObject.Add('eticket_pass_android_url', Entry."eTicket Pass Andriod URL");
        JObject.Add('npdesigner_manifest_id', FormatGuid(Entry.NPDesignerManifestId));
        exit(JObject);
    end;

    procedure GenerateContentExample(): JsonObject
    var
        JObject: JsonObject;
    begin
        JObject.Add('ticket_type_code', 'ENTRY');
        JObject.Add('ticket_token', 'ABCD1234');
        JObject.Add('ticket_item_no', 'ENTRANCE-TICK');
        JObject.Add('ticket_variant_code', 'CHILD');
        JObject.Add('ticket_external_item_no', '123456789');
        JObject.Add('ticket_external_no', 'BIL123456789');
        JObject.Add('ticket_relevant_date', 20250101D);
        JObject.Add('ticket_relevant_date_formatted', Format(20250101D, 0, '<Standard Format,0>'));
        JObject.Add('ticket_relevant_time', 110000T);
        JObject.Add('ticket_relevant_time_formatted', Format(110000T, 0, '<Standard Format,0>'));
        JObject.Add('ticket_relevant_datetime', CreateDateTime(20250101D, 110000T));
        JObject.Add('ticket_relevant_datetime_formatted', Format(CreateDateTime(20250101D, 110000T), 0, '<Standard Format,0>'));
        JObject.Add('ticket_holder_name', 'Hans Hansen');
        JObject.Add('ticket_holder_email', 'test@example.com');
        JObject.Add('ticket_bom_description', 'Entrance');
        JObject.Add('ticket_bom_admission_description', 'Entrance');
        JObject.Add('ticket_admission_event_description', 'Everyday');
        JObject.Add('ticket_admission_location_description', 'Everyday Entrance');
        JObject.Add('admission_code', 'ENTRANCE');
        JObject.Add('notification_address', 'test@example.com');
        JObject.Add('event_start_date', 20250101D);
        JObject.Add('event_start_date_formatted', Format(20250101D, 0, '<Standard Format,0>'));
        JObject.Add('event_start_time', 110000T);
        JObject.Add('event_start_time_formatted', Format(110000T, 0, '<Standard Format,0>'));
        JObject.Add('eticket_pass_id', 'ABCDE1234');
        JObject.Add('eticket_pass_landing_url', 'https://passes.example.com');
        JObject.Add('published_ticket_url', 'https://tickets.example.com');
        JObject.Add('npdesigner_template_id', 'ENTRY_TEMPLATE');
        JObject.Add('external_order_no', 'EXT-ORD-001');
        JObject.Add('quantity_to_admit', 2);
        JObject.Add('entry_no', 1);
        JObject.Add('notification_group_id', 1);
        JObject.Add('date_to_notify', 20250101D);
        JObject.Add('date_to_notify_formatted', Format(20250101D, 0, '<Standard Format,0>'));
        JObject.Add('time_to_notify', 100000T);
        JObject.Add('time_to_notify_formatted', Format(100000T, 0, '<Standard Format,0>'));
        JObject.Add('notification_trigger', 'NP_DESIGNER');
        JObject.Add('template_code', 'CONFIRM');
        JObject.Add('notification_process_method', 'INLINE');
        JObject.Add('ticket_no', 'TK000001');
        JObject.Add('ticket_list_price', 125.0);
        JObject.Add('ticket_list_price_formatted', Format(125.0, 0, '<Precision,2><Standard Format,2>'));
        JObject.Add('detention_time_seconds', 300);
        JObject.Add('notification_profile_code', 'DEFAULT');
        JObject.Add('notification_engine', 'NPR_INTERNAL');
        JObject.Add('notification_method', 'EMAIL');
        JObject.Add('authorization_code', 'AUTH01');
        JObject.Add('ticket_expire_date', 20250201D);
        JObject.Add('ticket_expire_date_formatted', Format(20250201D, 0, '<Standard Format,0>'));
        JObject.Add('ticket_expire_time', 235959T);
        JObject.Add('ticket_expire_time_formatted', Format(235959T, 0, '<Standard Format,0>'));
        JObject.Add('ticket_expire_datetime', CreateDateTime(20250201D, 235959T));
        JObject.Add('ticket_expire_datetime_formatted', Format(CreateDateTime(20250201D, 235959T), 0, '<Standard Format,0>'));
        JObject.Add('ticket_voided', false);
        JObject.Add('ticket_no_for_printing', 'BIL123456789');
        JObject.Add('admission_schedule_entry_no', 1);
        JObject.Add('det_ticket_access_entry_no', 1);
        JObject.Add('extra_text', 'Please arrive 15 minutes early');
        JObject.Add('section', 'A');
        JObject.Add('row', '1');
        JObject.Add('seat', '12');
        JObject.Add('ticket_holder_preferred_language', 'ENU');
        JObject.Add('waiting_list_reference_code', 'A7X-9K2');
        JObject.Add('ticket_trigger_type', 'SALES');
        JObject.Add('eticket_type_code', 'ENTRY-PASS');
        JObject.Add('eticket_pass_default_url', 'https://passes.example.com/default');
        JObject.Add('eticket_pass_android_url', 'https://passes.example.com/android');
        JObject.Add('npdesigner_manifest_id', 'a1b2c3d4-e5f6-4a1b-8c2d-3e4f5a6b7c8d');
        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
        // do nothing, we don't support adding attachments
    end;

    local procedure GetEnumValueName(var RecRef: RecordRef; FieldNo: Integer; OrdinalValue: Integer): Text
    var
        FldRef: FieldRef;
    begin
        FldRef := RecRef.Field(FieldNo);
        exit(FldRef.GetEnumValueNameFromOrdinalValue(OrdinalValue));
    end;

    local procedure FormatGuid(Value: Guid): Text
    begin
        if (IsNullGuid(Value)) then
            exit('');
        exit(Format(Value, 0, 4).ToLower());
    end;
}
#endif
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248408 "NPR NPEmailTicketDataProvider" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        Entry: Record "NPR TM Ticket Notif. Entry";
        JObject: JsonObject;
        WrongRecordReceivedErr: Label 'The code received a record of an unknown type. Most likely a wrong data driver was used on the Dynamic Template.';
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
        JObject.Add('ticket_relevant_time', Entry."Relevant Time");
        JObject.Add('ticket_relevant_datetime', Entry."Relevant Datetime");
        JObject.Add('ticket_holder_name', Entry."Ticket Holder Name");
        JObject.Add('ticket_holder_email', Entry."Ticket Holder E-Mail");
        JObject.Add('ticket_bom_description', Entry."Ticket BOM Description");
        JObject.Add('ticket_bom_admission_description', Entry."Ticket BOM Adm. Description");
        JObject.Add('ticket_admission_event_description', Entry."Adm. Event Description");
        JObject.Add('ticket_admission_location_description', Entry."Adm. Location Description");
        JObject.Add('admission_code', Entry."Admission Code");
        JObject.Add('notification_address', Entry."Notification Address");
        JObject.Add('event_start_date', Entry."Event Start Date");
        JObject.Add('event_start_time', Entry."Event Start Time");
        JObject.Add('eticket_pass_id', Entry."eTicket Pass Id");
        JObject.Add('eticket_pass_landing_url', Entry."eTicket Pass Landing URL");
        JObject.Add('published_ticket_url', Entry."Published Ticket URL");
        JObject.Add('npdesigner_template_id', Entry.NPDesignerTemplateId);
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
        JObject.Add('ticket_relevant_time', 110000T);
        JObject.Add('ticket_relevant_datetime', CreateDateTime(20250101D, 110000T));
        JObject.Add('ticket_holder_name', 'Hans Hansen');
        JObject.Add('ticket_holder_email', 'test@example.com');
        JObject.Add('ticket_bom_description', 'Entrance');
        JObject.Add('ticket_bom_admission_description', 'Entrance');
        JObject.Add('ticket_admission_event_description', 'Everyday');
        JObject.Add('ticket_admission_location_description', 'Everyday Entrance');
        JObject.Add('admission_code', 'ENTRANCE');
        JObject.Add('notification_address', 'test@example.com');
        JObject.Add('event_start_date', 20250101D);
        JObject.Add('event_start_time', 110000T);
        JObject.Add('eticket_pass_id', 'ABCDE1234');
        JObject.Add('eticket_pass_landing_url', 'https://passes.example.com');
        JObject.Add('published_ticket_url', 'https://tickets.example.com');
        JObject.Add('npdesigner_template_id', 'ENTRY_TEMPLATE');
        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
        // do nothing, we don't support adding attachments
    end;
}
#endif
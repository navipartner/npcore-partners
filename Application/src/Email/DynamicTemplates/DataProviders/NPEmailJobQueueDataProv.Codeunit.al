codeunit 6151254 "NPR NPEmailJobQueueDataProv" implements "NPR IDynamicTemplateDataProvider"
{
    Access = Internal;

    procedure GetContent(RecRef: RecordRef): JsonObject
    var
        JobQueueEntry: Record "Job Queue Entry";
        JObject: JsonObject;
        WrongRecordReceivedErr: Label 'The code received a record of an unknown type. Most likely a wrong data provider was used on the Dynamic Template. This is a programming bug.', Locked = true;
    begin
        if RecRef.Number() <> Database::"Job Queue Entry" then
            Error(WrongRecordReceivedErr);

        RecRef.SetTable(JobQueueEntry);
        JobQueueEntry.CalcFields("Object Caption to Run");

        JObject.Add('company_name', CompanyName());
        JObject.Add('job_queue_entry_id', Format(JobQueueEntry.ID, 0, 4).ToLower());
        JObject.Add('description', JobQueueEntry.Description);
        JObject.Add('object_type_to_run', Format(JobQueueEntry."Object Type to Run"));
        JObject.Add('object_id_to_run', JobQueueEntry."Object ID to Run");
        JObject.Add('object_caption_to_run', JobQueueEntry."Object Caption to Run");
        JObject.Add('parameter_string', JobQueueEntry."Parameter String");
        JObject.Add('job_queue_category_code', JobQueueEntry."Job Queue Category Code");
        JObject.Add('status', Format(JobQueueEntry.Status));
        JObject.Add('error_message', JobQueueEntry."Error Message");
        JObject.Add('user_id', JobQueueEntry."User ID");
        JObject.Add('no_of_attempts_to_run', JobQueueEntry."No. of Attempts to Run");
        JObject.Add('earliest_start_datetime', JobQueueEntry."Earliest Start Date/Time");
        JObject.Add('earliest_start_datetime_formatted', Format(JobQueueEntry."Earliest Start Date/Time"));

        exit(JObject);
    end;

    procedure GenerateContentExample(): JsonObject
    var
        JObject: JsonObject;
        ExampleStartDateTime: DateTime;
    begin
        ExampleStartDateTime := CreateDateTime(20250115D, 083000T);

        JObject.Add('company_name', 'CRONUS International Ltd.');
        JObject.Add('job_queue_entry_id', 'd3c6a463-5a13-4f90-9887-99ac8ea4e394');
        JObject.Add('description', 'Import ecommerce orders');
        JObject.Add('object_type_to_run', 'Codeunit');
        JObject.Add('object_id_to_run', 6014405);
        JObject.Add('object_caption_to_run', 'Import Worksheet Management');
        JObject.Add('parameter_string', '');
        JObject.Add('job_queue_category_code', 'NPR');
        JObject.Add('status', 'Error');
        JObject.Add('error_message', 'An error occurred while running the job.');
        JObject.Add('user_id', 'ADMIN');
        JObject.Add('no_of_attempts_to_run', 3);
        JObject.Add('earliest_start_datetime', ExampleStartDateTime);
        JObject.Add('earliest_start_datetime_formatted', Format(ExampleStartDateTime));

        exit(JObject);
    end;

    procedure AddAttachments(var EmailItem: Record "Email Item"; RecRef: RecordRef)
    begin
    end;
}

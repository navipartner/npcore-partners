codeunit 6184771 "NPR AF Rec. API Request"
{
    Access = Public;

    procedure PostReportReady(statusCode: Text; statusDescription: Text; headersCollection: Text; content: Text; webhookReference: Text): Text
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        ReportOutStream: OutStream;
        RequestOutStream: OutStream;
        ReportURL: Text;
        ResponseText: Text;
        JsonToken: JsonToken;
        JsonObjectToken: JsonToken;
        JsonValueToken: JsonToken;
        JsonObject: JsonObject;
        JsonArrayCounter: Integer;
        ReconciliationWebhook: Record "NPR AF Rec. Webhook Request";
        AdyenSetup: Record "NPR Adyen Setup";
        AdyenManagement: Codeunit "NPR Adyen Management";
        LogType: Enum "NPR Adyen Rec. Log Type";
        SetupNotConfiguredError: Label 'Adyen Generic Setup is not configured!';
        ReportLoggedSuccess: Label 'Successfully logged %1 reports!';
        ReportLoggedError: Label 'No reports were logged!';
        TaskSchedulerSuccess: Label 'Reconciliation Task has successfully been created!';
        TaskSchedulerError: Label 'Reconciliation Task creation failed!';
    begin
        if content <> '' then begin
            if (JsonToken.ReadFrom(content)) then begin
                JsonObject := JsonToken.AsObject();
                if (JsonObject.Get('live', JsonToken)) then begin
                    ReconciliationWebhook.Init();
                    ReconciliationWebhook.ID := 0;
                    ReconciliationWebhook."Creation Date" := CurrentDateTime();
                    ReconciliationWebhook."Webhook Reference" := CopyStr(webhookReference, 1, MaxStrLen(ReconciliationWebhook."Webhook Reference"));
                    if Evaluate(ReconciliationWebhook."Status Code", statusCode) then;
                    ReconciliationWebhook."Status Description" := CopyStr(statusDescription, 1, MaxStrLen(ReconciliationWebhook."Status Description"));
                    ReconciliationWebhook.Live := JsonToken.AsValue().AsBoolean();
                    ReconciliationWebhook."Request Data".CreateOutStream(RequestOutStream, TextEncoding::UTF8);
                    RequestOutStream.WriteText(content);
                    ReconciliationWebhook.Insert();
                    if (JsonObject.Get('notificationItems', JsonToken)) then begin
                        if JsonToken.IsArray() then
                            foreach JsonObjectToken in JsonToken.AsArray() do begin
                                if JsonObjectToken.IsObject() then begin
                                    if JsonObjectToken.AsObject().Get('NotificationRequestItem', JsonObjectToken) then begin
                                        if JsonObjectToken.IsObject() then begin
                                            if (JsonObjectToken.AsObject().Get('reason', JsonValueToken)) then begin
                                                ReportURL := JsonValueToken.AsValue().AsText();
                                                if not AdyenSetup.Get() then
                                                    exit(SetupNotConfiguredError);

                                                ReconciliationWebhook."Report Download URL" := CopyStr(ReportURL, 1, MaxStrLen(ReconciliationWebhook."Report Download URL"));
                                                ReconciliationWebhook."Report Name" := CopyStr(ReportURL.Split('/').Get(ReportURL.Split('/').Count()), 1, MaxStrLen(ReconciliationWebhook."Report Name"));
                                                HttpClient.DefaultRequestHeaders().Add('x-api-key', AdyenSetup."Download Report API Key");
                                                HttpClient.Get(ReportURL, HttpResponseMessage);

                                                if (HttpResponseMessage.IsSuccessStatusCode()) then begin
                                                    // Downloading CSV Report
                                                    HttpResponseMessage.Content().ReadAs(ResponseText);
                                                    ReconciliationWebhook."Report Data".CreateOutStream(ReportOutStream, TextEncoding::UTF8);
                                                    ReportOutStream.WriteText(ResponseText);
                                                end;
                                                ReconciliationWebhook.Modify();
                                                Commit();

                                                // Run in another Session
                                                if TaskScheduler.CanCreateTask() then begin
                                                    TaskScheduler.CreateTask(Codeunit::"NPR Adyen Tr. Matching Session", 0, true, CompanyName(), 0DT, ReconciliationWebhook.RecordId());
                                                    AdyenManagement.CreateLog(LogType::"Background Session", true, TaskSchedulerSuccess, ReconciliationWebhook.ID);
                                                end else
                                                    AdyenManagement.CreateLog(LogType::"Background Session", false, TaskSchedulerError, ReconciliationWebhook.ID);
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                    end;
                end;
            end;
        end else begin
            // Create "empty content" webhook log 
            ReconciliationWebhook.Init();
            ReconciliationWebhook.ID := 0;
            ReconciliationWebhook."Creation Date" := CurrentDateTime();
            if Evaluate(ReconciliationWebhook."Status Code", statusCode) then;
            ReconciliationWebhook."Status Description" := CopyStr(statusDescription, 1, MaxStrLen(ReconciliationWebhook."Status Description"));
            ReconciliationWebhook.Insert();
        end;

        if (JsonArrayCounter > 0) then
            exit(StrSubstNo(ReportLoggedSuccess, format(JsonArrayCounter)))
        else
            exit(ReportLoggedError);
    end;
}

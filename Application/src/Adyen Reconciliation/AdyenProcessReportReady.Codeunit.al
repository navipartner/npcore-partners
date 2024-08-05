codeunit 6184920 "NPR Adyen Process Report Ready"
{
    Access = Internal;

    procedure ProcessReportReadyWebhook(AdyenWebhook: Record "NPR Adyen Webhook")
    var
        WebhookInStream: InStream;
        ReportURL: Text;
        JsonToken: JsonToken;
        JsonObjectToken: JsonToken;
        JsonValueToken: JsonToken;
        JsonObject: JsonObject;
        Live: Boolean;
        ReconciliationWebhook: Record "NPR AF Rec. Webhook Request";
        AdyenManagement: Codeunit "NPR Adyen Management";
        LogType: Enum "NPR Adyen Webhook Log Type";
        RecLogType: Enum "NPR Adyen Rec. Log Type";
        SuccessImportLbl: Label 'NP Pay Reconciliation Webhook Request was successfully imported.';
        WebhookNoDataLbl: Label 'NP Pay Webhook %1 has no data.';
    begin
        AdyenWebhook.LockTable();
        AdyenWebhook.Get(AdyenWebhook."Entry No.");

        if not (AdyenWebhook.Status in [AdyenWebhook.Status::New, AdyenWebhook.Status::Error]) then
            exit;

        if not AdyenWebhook."Webhook Data".HasValue() then
            Error(WebhookNoDataLbl, Format(AdyenWebhook."Entry No."));

        AdyenWebhook.CalcFields("Webhook Data");
        AdyenWebhook."Webhook Data".CreateInStream(WebhookInStream, TextEncoding::UTF8);

        if (JsonToken.ReadFrom(WebhookInStream)) then begin
            JsonObject := JsonToken.AsObject();
            if (JsonObject.Get('live', JsonToken)) then begin
                Live := JsonToken.AsValue().AsBoolean();
                if (JsonObject.Get('notificationItems', JsonToken)) then begin
                    if JsonToken.IsArray() then
                        foreach JsonObjectToken in JsonToken.AsArray() do begin
                            if JsonObjectToken.IsObject() then begin
                                if JsonObjectToken.AsObject().Get('NotificationRequestItem', JsonObjectToken) then begin
                                    if JsonObjectToken.IsObject() then begin
                                        if (JsonObjectToken.AsObject().Get('reason', JsonValueToken)) then begin
                                            ReconciliationWebhook.Init();
                                            ReconciliationWebhook.ID := 0;
                                            ReconciliationWebhook."Adyen Webhook Entry No." := AdyenWebhook."Entry No.";
                                            ReconciliationWebhook."Webhook Reference" := CopyStr(AdyenWebhook."Webhook Reference", 1, MaxStrLen(ReconciliationWebhook."Webhook Reference"));
                                            ReconciliationWebhook.Live := Live;
                                            ReconciliationWebhook.Insert();
                                            ReportURL := JsonValueToken.AsValue().AsText();
                                            if JsonObjectToken.AsObject().Get('pspReference', JsonValueToken) then
                                                ReconciliationWebhook."PSP Reference" := CopyStr(JsonValueToken.AsValue().AsText(), 1, MaxStrLen(ReconciliationWebhook."PSP Reference"));
                                            ReconciliationWebhook."Report Download URL" := CopyStr(ReportURL, 1, MaxStrLen(ReconciliationWebhook."Report Download URL"));
                                            ReconciliationWebhook.Validate("Report Name", CopyStr(ReportURL.Split('/').Get(ReportURL.Split('/').Count()), 1, MaxStrLen(ReconciliationWebhook."Report Name")));
                                            ReconciliationWebhook.Modify();
                                            AdyenWebhook.Status := AdyenWebhook.Status::Processed;
                                            AdyenWebhook."Processed Date" := CurrentDateTime();
                                            AdyenWebhook.Modify();
                                            AdyenManagement.CreateGeneralLog(LogType::Process, true, SuccessImportLbl, AdyenWebhook."Entry No.");
                                            AdyenManagement.CreateReconciliationLog(RecLogType::"Background Session", true, SuccessImportLbl, ReconciliationWebhook.ID);
                                        end;
                                    end;
                                end;
                            end;
                        end;
                end;
            end;
        end;
    end;
}

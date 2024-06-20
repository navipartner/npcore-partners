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
        ReconciliationWebhook: Record "NPR AF Rec. Webhook Request";
        AdyenManagement: Codeunit "NPR Adyen Management";
        LogType: Enum "NPR Adyen Webhook Log Type";
        RecLogType: Enum "NPR Adyen Rec. Log Type";
        SuccessImportLbl: Label 'Adyen Reconciliation Webhook Request was successfully imported.';
    begin
        if AdyenWebhook."Webhook Data".HasValue() then begin
            AdyenWebhook.CalcFields("Webhook Data");
            AdyenWebhook."Webhook Data".CreateInStream(WebhookInStream, TextEncoding::UTF8);

            if (JsonToken.ReadFrom(WebhookInStream)) then begin
                JsonObject := JsonToken.AsObject();
                if (JsonObject.Get('live', JsonToken)) then begin
                    ReconciliationWebhook.Init();
                    ReconciliationWebhook.ID := 0;
                    ReconciliationWebhook."Adyen Webhook Entry No." := AdyenWebhook."Entry No.";
                    ReconciliationWebhook."Creation Date" := CurrentDateTime();
                    ReconciliationWebhook."Webhook Reference" := CopyStr(AdyenWebhook."Webhook Reference", 1, MaxStrLen(ReconciliationWebhook."Webhook Reference"));
                    ReconciliationWebhook.Live := JsonToken.AsValue().AsBoolean();
                    ReconciliationWebhook."Request Data" := AdyenWebhook."Webhook Data";
                    ReconciliationWebhook.Insert();
                    AdyenManagement.CreateGeneralLog(LogType::Process, true, SuccessImportLbl, AdyenWebhook."Entry No.");
                    AdyenManagement.CreateLog(RecLogType::"Background Session", true, SuccessImportLbl, ReconciliationWebhook.ID);
                    Commit();
                    if (JsonObject.Get('notificationItems', JsonToken)) then begin
                        if JsonToken.IsArray() then
                            foreach JsonObjectToken in JsonToken.AsArray() do begin
                                if JsonObjectToken.IsObject() then begin
                                    if JsonObjectToken.AsObject().Get('NotificationRequestItem', JsonObjectToken) then begin
                                        if JsonObjectToken.IsObject() then begin
                                            if (JsonObjectToken.AsObject().Get('reason', JsonValueToken)) then begin
                                                ReportURL := JsonValueToken.AsValue().AsText();
                                                if JsonObjectToken.AsObject().Get('pspReference', JsonValueToken) then
                                                    ReconciliationWebhook.Validate("PSP Reference", JsonValueToken.AsValue().AsText());
                                                ReconciliationWebhook."Report Download URL" := CopyStr(ReportURL, 1, MaxStrLen(ReconciliationWebhook."Report Download URL"));
                                                ReconciliationWebhook."Report Name" := CopyStr(ReportURL.Split('/').Get(ReportURL.Split('/').Count()), 1, MaxStrLen(ReconciliationWebhook."Report Name"));
                                                ReconciliationWebhook.Modify();
                                            end;
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

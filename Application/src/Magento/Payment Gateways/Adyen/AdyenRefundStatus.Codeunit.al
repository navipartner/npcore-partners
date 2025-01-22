codeunit 6248224 "NPR Adyen Refund Status"
{
    Access = Internal;
    TableNo = "NPR Adyen Webhook";

    trigger OnRun()
    var
        WebhookInStream: InStream;
        JsonToken: JsonToken;
        JsonObjectToken: JsonToken;
        JsonObject: JsonObject;
        WebhookNoDataLbl: Label 'Adyen Webhook %1 has no data.';
        ProcessErrorLbl: Label 'Could not process Webhook Reference because %1.';
        AdyenManagement: Codeunit "NPR Adyen Management";
        AdyenWebhookLogType: Enum "NPR Adyen Webhook Log Type";
    begin
        if not Rec."Webhook Data".HasValue() then
            Error(WebhookNoDataLbl, Format(Rec."Entry No."));

        Rec.CalcFields("Webhook Data");
        Rec."Webhook Data".CreateInStream(WebhookInStream);

        if (JsonToken.ReadFrom(WebhookInStream)) then begin
            JsonObject := JsonToken.AsObject();
            if (JsonObject.Get('live', JsonToken)) then begin
                if (JsonObject.Get('notificationItems', JsonToken)) then begin
                    if JsonToken.IsArray() then
                        foreach JsonObjectToken in JsonToken.AsArray() do
                            if not ProcessNotificationItem(JsonObjectToken, Rec) then begin
                                AdyenManagement.CreateGeneralLog(AdyenWebhookLogType::Error, false, StrSubstNo(ProcessErrorLbl, GetLastErrorText()), Rec."Entry No.");
                                Rec.Status := Rec.Status::Error;
                                Rec."Processed Date" := CurrentDateTime();
                                Rec.Modify();
                            end;
                end;
            end;
        end;
    end;

    [TryFunction]
    local procedure ProcessNotificationItem(JsonObjectToken: JsonToken; var AdyenWebhook: Record "NPR Adyen Webhook")
    var
        JsonValueToken: JsonToken;
        pspReference: Text;
        MMSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        Success: Text;
        AdyenManagement: Codeunit "NPR Adyen Management";
        AdyenWebhookLogType: Enum "NPR Adyen Webhook Log Type";
        SuccessProcessedLbl: Label 'Adyen Webhook Request was successfully processed.';
    begin
        if JsonObjectToken.IsObject() then begin
            JsonObjectToken.AsObject().Get('NotificationRequestItem', JsonObjectToken);
            if JsonObjectToken.IsObject() then begin
                JsonObjectToken.AsObject().Get('pspReference', JsonValueToken);
                pspReference := CopyStr(JsonValueToken.AsValue().AsText(), 1, MaxStrLen(MMSubscrPaymentRequest."PSP Reference"));
                MMSubscrPaymentRequest.SetRange("PSP Reference", pspReference);
                if MMSubscrPaymentRequest.FindFirst() then begin
                    JsonObjectToken.AsObject().Get('success', JsonValueToken);
                    Success := JsonValueToken.AsValue().AsText();
                    ModifySubscrPmtRequest(JsonObjectToken, MMSubscrPaymentRequest, Success);
                    AdyenWebhook.Status := AdyenWebhook.Status::Processed;
                    AdyenWebhook."Processed Date" := CurrentDateTime();
                    AdyenWebhook.Modify();
                    AdyenManagement.CreateGeneralLog(AdyenWebhookLogType::Process, true, SuccessProcessedLbl, AdyenWebhook."Entry No.");
                end;
            end;
        end;
    end;

    local procedure ModifySubscrPmtRequest(var JsonObjectToken: JsonToken; var MMSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; Success: Text)
    var
        Reason: Text;
        JsonValueToken: JsonToken;
        SuccessTrue: Label 'true', Locked = true;
        SuccessFalse: Label 'false', Locked = true;
    begin
        case Success of
            SuccessTrue:
                MMSubscrPaymentRequest.Validate(Status, MMSubscrPaymentRequest.Status::Captured);
            SuccessFalse:
                MMSubscrPaymentRequest.Validate(Status, MMSubscrPaymentRequest.Status::Error);
        end;
        JsonObjectToken.AsObject().Get('reason', JsonValueToken);
        Reason := JsonValueToken.AsValue().AsText();
        If Reason <> MMSubscrPaymentRequest."Rejected Reason Description" then
            MMSubscrPaymentRequest.Validate("Rejected Reason Description", Reason);
        MMSubscrPaymentRequest.Modify(true);
    end;
}
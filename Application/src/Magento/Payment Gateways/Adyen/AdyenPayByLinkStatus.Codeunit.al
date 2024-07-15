codeunit 6184921 "NPR Adyen PayByLink Status"
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
        PaymentLinkID: Text;
        MagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        if JsonObjectToken.IsObject() then begin
            JsonObjectToken.AsObject().Get('NotificationRequestItem', JsonObjectToken);
            if JsonObjectToken.IsObject() then begin
                JsonObjectToken.AsObject().Get('additionalData', JsonValueToken);
                JsonValueToken.AsObject().Get('paymentLinkId', JsonValueToken);
                PaymentLinkID := CopyStr(JsonValueToken.AsValue().AsText(), 1, MaxStrLen(MagentoPaymentLine."Payment ID"));
                MagentoPaymentLine.SetRange("Payment ID", PaymentLinkID);

                MagentoPaymentLine.FindFirst();
                ModifyMagentoPaymentLine(JsonObjectToken, AdyenWebhook, JsonValueToken, MagentoPaymentLine);
            end;
        end;
    end;

    local procedure ModifyMagentoPaymentLine(var JsonObjectToken: JsonToken; var AdyenWebhook: Record "NPR Adyen Webhook"; var JsonValueToken: JsonToken; var MagentoPaymentLine: Record "NPR Magento Payment Line")
    var
        AmountTxt: Text;
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Adyen Mgt.";
        AdyenManagement: Codeunit "NPR Adyen Management";
        AdyenWebhookLogType: Enum "NPR Adyen Webhook Log Type";
        SuccessProcessedLbl: Label 'Adyen Webhook Request was successfully processed.';
    begin
        if JsonObjectToken.AsObject().Get('pspReference', JsonValueToken) then
            MagentoPaymentLine.Validate("Transaction ID", JsonValueToken.AsValue().AsText());
        if JsonObjectToken.AsObject().Get('amount', JsonObjectToken) then
            if JsonObjectToken.IsObject() then
                if JsonObjectToken.AsObject().Get('value', JsonValueToken) then begin
                    AmountTxt := JsonValueToken.AsValue().AsText();
                    if MagentoPmtMgt.ConvertFromAdyenPayAmount(AmountTxt) = MagentoPaymentLine."Requested Amount" then begin
                        MagentoPaymentLine.Amount := MagentoPaymentLine."Requested Amount";
                        MagentoPaymentLine."Date Authorized" := Today;
                        MagentoPaymentLine.Modify();
                        AdyenWebhook.Status := AdyenWebhook.Status::Processed;
                        AdyenWebhook."Processed Date" := CurrentDateTime();
                        AdyenWebhook.Modify();
                        AdyenManagement.CreateGeneralLog(AdyenWebhookLogType::Process, true, SuccessProcessedLbl, AdyenWebhook."Entry No.");
                    end;
                end;
    end;
}
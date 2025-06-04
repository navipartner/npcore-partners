codeunit 6248332 "NPR Adyen Try Webhook Process"
{
    Access = Internal;
    TableNo = "NPR Adyen Webhook";

    trigger OnRun()
    var
        ReportReady: Codeunit "NPR Adyen Process Report Ready";
    begin
        case Rec."Event Code" of
            "NPR Adyen Webhook Event Code"::REPORT_AVAILABLE:
                ReportReady.ProcessReportReadyWebhook(Rec);
            else
                ProcessWebhookStatus(Rec);
        end;
    end;

    local procedure ProcessWebhookStatus(var AdyenWebhook: Record "NPR Adyen Webhook")
    var
        WebhookInStream: InStream;
        RootJsonObject: JsonObject;
        RootJsonToken: JsonToken;
        NotificationItem: JsonToken;
    begin

        if not AdyenWebhook."Webhook Data".HasValue() then
            Error('Adyen Webhook %1 has no data.', Format(AdyenWebhook."Entry No."));

        AdyenWebhook.CalcFields("Webhook Data");
        AdyenWebhook."Webhook Data".CreateInStream(WebhookInStream);

        if not RootJsonToken.ReadFrom(WebhookInStream) then
            exit;

        RootJsonObject := RootJsonToken.AsObject();

        if not RootJsonObject.Get('live', RootJsonToken) then
            exit;

        if not RootJsonObject.Get('notificationItems', RootJsonToken) or not RootJsonToken.IsArray() then
            exit;

        foreach NotificationItem in RootJsonToken.AsArray() do begin
            case AdyenWebhook."Event Code" of
                AdyenWebhook."Event Code"::REFUND:
                    ProcessRefundNotification(NotificationItem, AdyenWebhook);
                AdyenWebhook."Event Code"::AUTHORISATION:
                    ProcessPaymentByLinkAuthorizationNotification(NotificationItem, AdyenWebhook);
                AdyenWebhook."Event Code"::RECURRING_CONTRACT:
                    ProcessPayByLinkRecurringContractNotification(NotificationItem, AdyenWebhook);
            end;
        end;
    end;

    local procedure ProcessRefundNotification(JsonObjectToken: JsonToken; var AdyenWebhook: Record "NPR Adyen Webhook") Processed: Boolean
    var
        MMSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        MMSubscrPmtAdyen: Codeunit "NPR MM Subscr.Pmt.: Adyen";
        NotifItem: JsonToken;
        pspReference: Text;
        Success: Text;
    begin
        if not ExtractNotificationItem(JsonObjectToken, NotifItem) then
            exit;

        if not NotifItem.AsObject().Get('pspReference', JsonObjectToken) then
            exit;

        pspReference := CopyStr(JsonObjectToken.AsValue().AsText(), 1, MaxStrLen(MMSubscrPaymentRequest."PSP Reference"));
        MMSubscrPaymentRequest.SetRange("PSP Reference", pspReference);
        if not MMSubscrPaymentRequest.FindFirst() then
            exit;

        if not NotifItem.AsObject().Get('success', JsonObjectToken) then
            exit;

        Success := JsonObjectToken.AsValue().AsText();
        Processed := MMSubscrPmtAdyen.ProcessRefundWebhook(NotifItem, MMSubscrPaymentRequest, Success, AdyenWebhook."Entry No.");
        if not Processed then
            exit;

        ExecuteUpdateWebhookStatusProcessed(AdyenWebhook);
    end;

    local procedure ProcessPaymentByLinkAuthorizationNotification(JsonObjectToken: JsonToken; var AdyenWebhook: Record "NPR Adyen Webhook") Processed: Boolean
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        MMSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        MMSubscrPmtAdyen: Codeunit "NPR MM Subscr.Pmt.: Adyen";
        NotificationItem: JsonToken;
        PaymentLinkID: Text;
    begin
        if not ExtractNotificationItem(JsonObjectToken, NotificationItem) then
            exit;

        if not ExtractPaymentLinkID(NotificationItem, PaymentLinkID) then
            exit;

        PaymentLinkID := CopyStr(PaymentLinkID, 1, MaxStrLen(MagentoPaymentLine."Payment ID"));

        MagentoPaymentLine.SetRange("Payment ID", PaymentLinkID);
        MMSubscrPaymentRequest.SetRange("Pay by Link ID", PaymentLinkID);

        case true of
            MagentoPaymentLine.FindFirst():
                Processed := AuthorizeMagentoPaymentLine(NotificationItem, MagentoPaymentLine);
            MMSubscrPaymentRequest.FindFirst():
                Processed := MMSubscrPmtAdyen.ProcessPayByLinkWebhook(NotificationItem, AdyenWebhook, MMSubscrPaymentRequest);
        end;

        if not Processed then
            exit;

        ExecuteUpdateWebhookStatusProcessed(AdyenWebhook);
    end;

    local procedure AuthorizeMagentoPaymentLine(JsonObjectToken: JsonToken; var MagentoPaymentLine: Record "NPR Magento Payment Line") Processed: Boolean;
    var
        JsonHelper: Codeunit "NPR Json Helper";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Adyen Mgt.";
        Amount: Decimal;
        AmountTxt: Text;
        TransactionId: Text;
        Success: Boolean;
        PaymentMethod: Text;
    begin
        TransactionId := JsonHelper.GetJText(JsonObjectToken, 'pspReference', false);
        if TransactionId = '' then
            exit;

        Success := JsonHelper.GetJBoolean(JsonObjectToken, 'success', false);
        if not Success then begin
            Processed := true;
            exit;
        end;

        AmountTxt := JsonHelper.GetJText(JsonObjectToken, 'amount.value', false);
        if AmountTxt = '' then
            exit;

        Amount := MagentoPmtMgt.ConvertFromAdyenPayAmount(AmountTxt);

        if Amount <> MagentoPaymentLine."Requested Amount" then
            exit;

        PaymentMethod := JsonHelper.GetJText(JsonObjectToken, 'paymentMethod', false);

        GetPaymentMethod(MagentoPaymentLine, PaymentMethod);

        MagentoPaymentLine.Validate("Transaction ID", TransactionId);
        MagentoPaymentLine."No." := CopyStr(MagentoPaymentLine."Transaction ID", 1, MaxStrLen(MagentoPaymentLine."No."));
        MagentoPaymentLine."Date Authorized" := Today;
        MagentoPaymentLine.Amount := MagentoPaymentLine."Requested Amount";
        MagentoPaymentLine.Brand := CopyStr(PaymentMethod, 1, MaxStrLen(MagentoPaymentLine.Brand));
        MagentoPaymentLine.Modify();

        Processed := true;
    end;

    local procedure ProcessPayByLinkRecurringContractNotification(JsonObjectToken: JsonToken; var AdyenWebhook: Record "NPR Adyen Webhook") Processed: Boolean
    var
        MMSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        MMSubscrPmtAdyen: Codeunit "NPR MM Subscr.Pmt.: Adyen";
        NotificationItem: JsonToken;
        PaymentLinkID: Text;
    begin
        if not ExtractNotificationItem(JsonObjectToken, NotificationItem) then
            exit;

        if not ExtractPaymentLinkID(NotificationItem, PaymentLinkID) then
            exit;

        PaymentLinkID := CopyStr(PaymentLinkID, 1, MaxStrLen(MMSubscrPaymentRequest."Pay by Link ID"));
        MMSubscrPaymentRequest.SetRange("Pay by Link ID", PaymentLinkID);
        if not MMSubscrPaymentRequest.FindFirst() then
            exit;

        Processed := true;
        if MMSubscrPaymentRequest.Status <> MMSubscrPaymentRequest.Status::Captured then
            Processed := MMSubscrPmtAdyen.ProcessPayByLinkWebhook(NotificationItem, AdyenWebhook, MMSubscrPaymentRequest);

        ExecuteUpdateWebhookStatusProcessed(AdyenWebhook);
    end;

    local procedure ExtractNotificationItem(JsonTokenIn: JsonToken; var NotificationItem: JsonToken) Found: Boolean
    begin
        if not JsonTokenIn.IsObject() then
            exit;
        if not JsonTokenIn.AsObject().Get('NotificationRequestItem', NotificationItem) or not NotificationItem.IsObject() then
            exit;
        Found := true;
    end;

    local procedure ExtractPaymentLinkID(NotificationItem: JsonToken; var PaymentLinkID: Text) Found: Boolean
    var
        JsonValueToken: JsonToken;
    begin
        if not NotificationItem.AsObject().Get('additionalData', JsonValueToken) then
            exit;
        if not JsonValueToken.AsObject().Get('paymentLinkId', JsonValueToken) then
            exit;
        PaymentLinkID := JsonValueToken.AsValue().AsText();
        Found := true;
    end;

    local procedure ExecuteUpdateWebhookStatusProcessed(var AdyenWebhook: Record "NPR Adyen Webhook")
    begin
        UpdateWebhookStatusProcessed(AdyenWebhook);
        LogWebhookSuccess(AdyenWebhook);
    end;

    local procedure UpdateWebhookStatusProcessed(var AdyenWebhook: Record "NPR Adyen Webhook")
    begin
        if (AdyenWebhook.Status = AdyenWebhook.Status::Processed) then
            exit;

        AdyenWebhook.Status := AdyenWebhook.Status::Processed;
        AdyenWebhook."Processed Date" := CurrentDateTime();
        AdyenWebhook.Modify();
    end;

    local procedure LogWebhookSuccess(AdyenWebhook: Record "NPR Adyen Webhook")
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        SuccessProcessedLbl: Label 'Adyen Webhook Request was successfully processed.';
    begin
        AdyenManagement.CreateGeneralLog(Enum::"NPR Adyen Webhook Log Type"::Process, true, SuccessProcessedLbl, AdyenWebhook."Entry No.")
    end;

    local procedure GetPaymentMethod(var MagentoPaymentLine: Record "NPR Magento Payment Line"; PaymentMethod: Text)
    var
        PaymentMapping: Record "NPR Magento Payment Mapping";
        PaymentMethodRec: Record "Payment Method";
        NpPaySetup: Record "NPR Adyen Setup";
    begin
        if PaymentMapping.Get('', PaymentMethod) then begin
            PaymentMethodRec.Get(PaymentMapping."Payment Method Code");
            MagentoPaymentLine."Account Type" := PaymentMethodRec."Bal. Account Type";
            MagentoPaymentLine."Account No." := PaymentMethodRec."Bal. Account No."
        end else begin
            NpPaySetup.Get();
            MagentoPaymentLine."Account Type" := NpPaySetup."Pay By Link Account Type";
            MagentoPaymentLine."Account No." := NpPaySetup."Pay By Link Account No.";
        end;
    end;
}
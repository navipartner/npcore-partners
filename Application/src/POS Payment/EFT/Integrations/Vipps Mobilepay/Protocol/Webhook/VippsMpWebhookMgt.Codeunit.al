codeunit 6184714 "NPR Vipps Mp Webhook Mgt."
{
    Access = Internal;

    var
        _LblErrorWebhook: Label 'An error was encountered in the parsing of the webhook message.';
        _LblNotVerifiedWebhook: Label 'A webhook message was found, but the message could not be verified.';

    #region Webhook Writer
    internal procedure WriteWebhookMessage(JsonTxt: Text)
    var
        JsonReq: JsonObject;
        VippsMpWebhookMsg: Record "NPR Vipps Mp Webhook Msg";
        OldVippsMpWebhookMsg: Record "NPR Vipps Mp Webhook Msg";
        Out: OutStream;
    begin
        VippsMpWebhookMsg.Init();
        VippsMpWebhookMsg.Message.CreateOutStream(Out, TextEncoding::UTF8);
        VippsMpWebhookMsg.ReceivedAt := CreateDateTime(Today(), Time());
        Out.WriteText(JsonTxt);
        JsonReq.ReadFrom(JsonTxt);
        if (not SetEventTypeAndId(JsonReq, VippsMpWebhookMsg)) then begin
            VippsMpWebhookMsg.Error := True;
            Out.WriteText();
            Out.WriteText(GetLastErrorText());
        end;
        if (not VerifyMessage(JsonReq, VippsMpWebhookMsg)) then begin
            VippsMpWebhookMsg.Error := True;
            Out.WriteText();
            Out.WriteText(GetLastErrorText());
        end;
        // Delete already existing keys.
        if (OldVippsMpWebhookMsg.Get(VippsMpWebhookMsg."Webhook Reference", VippsMpWebhookMsg."Operation Reference", VippsMpWebhookMsg."Event Type")) then
            OldVippsMpWebhookMsg.Delete();
        VippsMpWebhookMsg.Insert();
        //Automatic cleanup
        DeleteOldWebhooks();
    end;

    local procedure VerifyMessage(JsonReq: JsonObject; var WebhookResponse: Record "NPR Vipps Mp Webhook Msg"): Boolean
    var
        VippsMpWebhook: Record "NPR Vipps Mp Webhook";
        VippsMpHmac: Codeunit "NPR Vipps Mp HMAC";
    begin
        VippsMpWebhook.Get(WebhookResponse."Webhook Reference");
        WebhookResponse.Verified := VippsMpHmac.VerifyHMAC(JsonReq, VippsMpWebhook."Webhook Secret");
        exit(WebhookResponse.Verified);
    end;

    local procedure DeleteOldWebhooks()
    var
        oldVippsMpWebhookMsg: Record "NPR Vipps Mp Webhook Msg";
        DateTimeCutoff: DateTime;
    begin
        //Delete all older than 1 hour that are not errors.
        DateTimeCutoff := CreateDateTime(Today(), Time() - (1000 * 60 * 60));
        oldVippsMpWebhookMsg.SetFilter(ReceivedAt, '<%1', DateTimeCutoff);
        oldVippsMpWebhookMsg.SetFilter(Error, '=%1', False);
        oldVippsMpWebhookMsg.DeleteAll();
        oldVippsMpWebhookMsg.Reset();
        //Delete all older than 1 week (also errors).
        DateTimeCutoff := CreateDateTime(Today() - 7, Time());
        oldVippsMpWebhookMsg.SetFilter(ReceivedAt, '<%1', DateTimeCutoff);
        oldVippsMpWebhookMsg.DeleteAll();
    end;

    [TryFunction]
    local procedure SetEventTypeAndId(JsonRequest: JsonObject; var WebhookResponse: Record "NPR Vipps Mp Webhook Msg")
    var
        WebhookReference: Text;
        OperationReference: Text;
        WebhookEventType: Option "QrScan","ePayment";
        Token: JsonToken;
        JsonContent: JsonObject;
    begin
        JsonRequest.Get('WebhookReference', Token);
        WebhookReference := Token.AsValue().AsText();
        JsonRequest.Get('Content', Token);
        JsonContent.ReadFrom(Token.AsValue().AsText());
        //Is Qr Redirect
        if (JsonContent.Contains('customerToken') and
            JsonContent.Contains('merchantQrId') and
            JsonContent.Contains('msn') and
            JsonContent.Contains('initiatedAt')) then begin
            JsonContent.Get('merchantQrId', Token);
            OperationReference := Token.AsValue().AsText();
            WebhookEventType := WebhookResponse."Event Type"::QrScan;
        end;
        //Is ePayment
        if (JsonContent.Contains('msn') and
            JsonContent.Contains('reference') and
            JsonContent.Contains('pspReference') and
            JsonContent.Contains('name') and
            JsonContent.Contains('amount') and
            JsonContent.Contains('timestamp') and
            JsonContent.Contains('success')
        ) then begin
            WebhookEventType := WebhookResponse."Event Type"::ePayment;
            JsonContent.Get('reference', Token);
            OperationReference := Token.AsValue().AsText();
        end;

#pragma warning disable AA0139
        WebhookResponse."Webhook Reference" := WebhookReference;
        WebhookResponse."Event Type" := WebhookEventType;
        WebhookResponse."Operation Reference" := OperationReference;
#pragma warning restore AA0139
    end;
    #endregion

    #region Webhook Reader

    [TryFunction]
    internal procedure GetLastUserCheckin(UConfig: Record "NPR Vipps Mp Unit Setup"; var HasResult: Boolean; var UserToken: Text; var VippsMpWebhookMsg: Record "NPR Vipps Mp Webhook Msg")
    var
        VippsMpStore: Record "NPR Vipps Mp Store";
        InS: InStream;
        RequestMessageTxt: Text;
        RequestMessage: JsonObject;
        Token: JsonToken;
    begin
        VippsMpStore.Get(UConfig."Merchant Serial Number");
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        VippsMpWebhookMsg.LockTable();
#ELSE
        VippsMpWebhookMsg.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
        VippsMpWebhookMsg.SetAutoCalcFields(Message);
        if (VippsMpWebhookMsg.Get(VippsMpStore."Webhook Reference", UConfig."Merchant Qr Id", VippsMpWebhookMsg."Event Type"::QrScan)) then begin
            if (not VippsMpWebhookMsg.Verified) then
                Error(_LblNotVerifiedWebhook);
            if (VippsMpWebhookMsg.Error) then
                Error(_LblErrorWebhook);
            VippsMpWebhookMsg.Message.CreateInStream(InS);
            InS.ReadText(RequestMessageTxt);
            RequestMessage.ReadFrom(RequestMessageTxt);
            RequestMessage.Get('Content', Token);
            RequestMessage.ReadFrom(Token.AsValue().AsText());
            RequestMessage.Get('customerToken', Token);
            UserToken := Token.AsValue().AsText();
            HasResult := True;
        end;
    end;

    [TryFunction]
    internal procedure GetNextPaymentWebhook(UConfig: Record "NPR Vipps Mp Unit Setup"; PaymentReference: Text; var HasResult: Boolean; var Content: JsonObject; var VippsMpWebhookMsg: Record "NPR Vipps Mp Webhook Msg")
    var
        VippsMpStore: Record "NPR Vipps Mp Store";
        InS: InStream;
        RequestMessageTxt: Text;
        RequestMessage: JsonObject;
        Token: JsonToken;
    begin
        VippsMpStore.Get(UConfig."Merchant Serial Number");
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        VippsMpWebhookMsg.LockTable();
#ELSE
        VippsMpWebhookMsg.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
        VippsMpWebhookMsg.SetAutoCalcFields(Message);
        if (VippsMpWebhookMsg.Get(VippsMpStore."Webhook Reference", PaymentReference, VippsMpWebhookMsg."Event Type"::ePayment)) then begin
            if (not VippsMpWebhookMsg.Verified) then
                Error(_LblNotVerifiedWebhook);
            if (VippsMpWebhookMsg.Error) then
                Error(_LblErrorWebhook);
            VippsMpWebhookMsg.Message.CreateInStream(InS);
            InS.ReadText(RequestMessageTxt);
            RequestMessage.ReadFrom(RequestMessageTxt);
            RequestMessage.Get('Content', Token);
            Content.ReadFrom(Token.AsValue().AsText());
            HasResult := True;
        end;
    end;
    #endregion
}
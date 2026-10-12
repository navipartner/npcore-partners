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
                AdyenWebhook."Event Code"::CAPTURE:
                    ProcessCaptureNotification(NotificationItem, AdyenWebhook);
                AdyenWebhook."Event Code"::CAPTURE_FAILED:
                    ProcessCaptureFailedNotification(NotificationItem, AdyenWebhook);
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

#pragma warning disable AA0139
        MagentoPaymentLine.Validate("Transaction ID", TransactionId);
#pragma warning restore AA0139
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

    local procedure ProcessCaptureNotification(NotificationItem: JsonToken; var AdyenWebhook: Record "NPR Adyen Webhook")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineToUpdate: Record "NPR Magento Payment Line";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        NotifItem: JsonToken;
        IsUnmatched: Boolean;
        CaptureSucceeded: Boolean;
        FailReason: Text;
        SuccessTrueTok: Label 'true', Locked = true;
    begin
        if not TryGetPaymentLineFromNotification(NotificationItem, PaymentLine, NotifItem, IsUnmatched) then begin
            if IsUnmatched then
                CancelUnmatchedWebhookAfterGrace(AdyenWebhook);
            exit;
        end;

        CaptureSucceeded := ExtractWebhookSuccess(NotifItem) = SuccessTrueTok;
        FailReason := ExtractWebhookFailReason(NotifItem);
        // Posting copies the line with its Charge ID to the invoice, so one capture can cover several lines.
        // A line that is already captured is not in flight, so it stays untouched.
        repeat
            if IsCapturableDocument(PaymentLine) and MagentoPmtMgt.IsCaptureInFlight(PaymentLine) then begin
                PaymentLineToUpdate.GetBySystemId(PaymentLine.SystemId);
                if CaptureSucceeded then begin
                    MagentoPmtMgt.MarkPaymentLineCaptured(PaymentLineToUpdate);
                    CompleteInteractionLog(PaymentLineToUpdate.SystemId, true, '');
                end else
                    FailInFlightCapture(PaymentLineToUpdate, FailReason);
            end;
        until PaymentLine.Next() = 0;

        ExecuteUpdateWebhookStatusProcessed(AdyenWebhook);
    end;

    local procedure ProcessCaptureFailedNotification(NotificationItem: JsonToken; var AdyenWebhook: Record "NPR Adyen Webhook")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineToUpdate: Record "NPR Magento Payment Line";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        NotifItem: JsonToken;
        IsUnmatched: Boolean;
        FailReason: Text;
    begin
        if not TryGetPaymentLineFromNotification(NotificationItem, PaymentLine, NotifItem, IsUnmatched) then begin
            if IsUnmatched then
                CancelUnmatchedWebhookAfterGrace(AdyenWebhook);
            exit;
        end;

        FailReason := ExtractWebhookFailReason(NotifItem);
        // Posting copies the line with its Charge ID to the invoice, so one capture can cover several lines.
        // A line that is already captured, or no longer in flight after a duplicate notification, stays untouched.
        repeat
            if IsCapturableDocument(PaymentLine) and MagentoPmtMgt.IsCaptureInFlight(PaymentLine) then begin
                PaymentLineToUpdate.GetBySystemId(PaymentLine.SystemId);
                FailInFlightCapture(PaymentLineToUpdate, FailReason);
            end;
        until PaymentLine.Next() = 0;

        ExecuteUpdateWebhookStatusProcessed(AdyenWebhook);
    end;

    local procedure FailInFlightCapture(var PaymentLine: Record "NPR Magento Payment Line"; FailReason: Text)
    begin
        PaymentLine."Charge ID" := '';
        PaymentLine."Capture Requested" := false;
        PaymentLine.Modify();

        CompleteInteractionLog(PaymentLine.SystemId, false, FailReason);
    end;

    internal procedure IsCaptureResetAllowed(PaymentLine: Record "NPR Magento Payment Line"; ReferenceDateTime: DateTime): Boolean
    var
        ResetAllowedAfter: DateTime;
    begin
        if not GetCaptureResetAllowedAfter(PaymentLine, ResetAllowedAfter) then
            exit(false);
        exit(ResetAllowedAfter < ReferenceDateTime);
    end;

    internal procedure GetCaptureResetAllowedAfter(PaymentLine: Record "NPR Magento Payment Line"; var ResetAllowedAfter: DateTime): Boolean
    var
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        OpenSince: DateTime;
    begin
        ResetAllowedAfter := 0DT;
        if not MagentoPmtMgt.IsCaptureInFlight(PaymentLine) then
            exit(false);
        if not IsCapturableDocument(PaymentLine) then
            exit(false);
        if not FindOpenCaptureSince(PaymentLine, OpenSince) then
            exit(false);
        ResetAllowedAfter := OpenSince + CaptureResetMinAge();
        exit(true);
    end;

    internal procedure RunResetCaptureRequest(var PaymentLine: Record "NPR Magento Payment Line"; ReferenceDateTime: DateTime)
    var
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        ResetAllowedAfter: DateTime;
        AdyenCaptured: Boolean;
        ResetCaptureOptionsLbl: Label 'Captured,Not captured', Comment = 'Comma-separated options. Keep the order: 1 = the Adyen Customer Area shows the capture, 2 = it shows no capture.';
        ResetCaptureInstructionLbl: Label 'What does the Adyen Customer Area show for this capture (PSP reference %1)?', Comment = '%1 = PSP reference of the capture request';
        ReleaseCaptureRequestQst: Label 'The capture request will be released and the payment line can be captured again. If Adyen did capture this payment, capturing it again can charge the customer twice. Continue only if the Adyen Customer Area shows no capture for PSP reference %1.', Comment = '%1 = PSP reference of the capture request';
        NoCaptureRequestMsg: Label 'There is no capture request in progress for this payment line.', Comment = 'Shown when the Reset Capture Request action finds nothing that can be reset on the selected payment line.';
        CaptureResetTooEarlyMsg: Label 'The capture request was sent less than 24 hours ago. Wait for the payment provider to confirm or reject it, or try again after %1.', Comment = '%1 = date and time after which the capture request can be reset';
        CaptureRequestChangedMsg: Label 'The capture request was completed or changed in the meantime. Nothing was reset.', Comment = 'Shown when the capture request changed between the user''s choice and the reset, so nothing was written.';
    begin
        if not MagentoPmtMgt.IsCaptureInFlight(PaymentLine) then begin
            Message(NoCaptureRequestMsg);
            exit;
        end;
        if not IsCaptureResetAllowed(PaymentLine, ReferenceDateTime) then begin
            if GetCaptureResetAllowedAfter(PaymentLine, ResetAllowedAfter) then
                Message(CaptureResetTooEarlyMsg, ResetAllowedAfter)
            else
                Message(NoCaptureRequestMsg);
            exit;
        end;
        case StrMenu(ResetCaptureOptionsLbl, 0, StrSubstNo(ResetCaptureInstructionLbl, PaymentLine."Charge ID")) of
            1:
                AdyenCaptured := true;
            2:
                begin
                    if not Confirm(StrSubstNo(ReleaseCaptureRequestQst, PaymentLine."Charge ID"), false) then
                        exit;
                    AdyenCaptured := false;
                end;
            else
                exit;
        end;
        if not ResetCaptureRequest(PaymentLine, AdyenCaptured, ReferenceDateTime) then
            Message(CaptureRequestChangedMsg);
    end;

    // Used when the CAPTURE or CAPTURE_FAILED webhook never arrives. Updates the same lines the webhook would.
    internal procedure ResetCaptureRequest(PaymentLineParam: Record "NPR Magento Payment Line"; AdyenCaptured: Boolean; ReferenceDateTime: DateTime): Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
        ScopeLine: Record "NPR Magento Payment Line";
        PaymentLineToUpdate: Record "NPR Magento Payment Line";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        ResetByUserLbl: Label 'Reset by user.', Comment = 'Stored as the error message of the capture interaction log entry when a user releases a capture request that Adyen never confirmed.';
    begin
        if not SetResetScope(PaymentLineParam, true, ScopeLine) then
            exit(false);
        if not PaymentLine.GetBySystemId(PaymentLineParam.SystemId) then
            exit(false);
        if PaymentLine."Charge ID" <> PaymentLineParam."Charge ID" then
            exit(false);
        if not IsCaptureResetAllowed(PaymentLine, ReferenceDateTime) then
            exit(false);

        repeat
            if IsCapturableDocument(ScopeLine) and MagentoPmtMgt.IsCaptureInFlight(ScopeLine) then begin
                PaymentLineToUpdate.GetBySystemId(ScopeLine.SystemId);
                if AdyenCaptured then begin
                    MagentoPmtMgt.MarkPaymentLineCaptured(PaymentLineToUpdate);
                    CompleteInteractionLog(PaymentLineToUpdate.SystemId, true, '');
                end else
                    FailInFlightCapture(PaymentLineToUpdate, ResetByUserLbl);
            end;
        until ScopeLine.Next() = 0;

        exit(true);
    end;

    local procedure FindOpenCaptureSince(PaymentLine: Record "NPR Magento Payment Line"; var OpenSince: DateTime): Boolean
    var
        ScopeLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        OpenSince := 0DT;
        if not SetResetScope(PaymentLine, false, ScopeLine) then
            exit(false);

        InteractionLog.SetRange("Interaction Type", InteractionLog."Interaction Type"::Capture);
        InteractionLog.SetRange("In Progress", true);
        repeat
            if IsCapturableDocument(ScopeLine) and MagentoPmtMgt.IsCaptureInFlight(ScopeLine) then begin
                InteractionLog.SetRange("Payment Line System Id", ScopeLine.SystemId);
                if InteractionLog.FindLast() then
                    if InteractionLog.SystemCreatedAt > OpenSince then
                        OpenSince := InteractionLog.SystemCreatedAt;
            end;
        until ScopeLine.Next() = 0;

        exit(OpenSince <> 0DT);
    end;

    local procedure SetResetScope(PaymentLineParam: Record "NPR Magento Payment Line"; LockLines: Boolean; var PaymentLine: Record "NPR Magento Payment Line"): Boolean
    begin
        if PaymentLineParam."Charge ID" <> '' then begin
            if LockLines then
                exit(FindPaymentLineByChargeId(PaymentLineParam."Charge ID", PaymentLine));
            PaymentLine.SetCurrentKey("Charge Id");
            PaymentLine.SetRange("Charge Id", PaymentLineParam."Charge ID");
            exit(PaymentLine.FindSet());
        end;

        if LockLines then
            PaymentLine.ReadIsolation := IsolationLevel::UpdLock;
        PaymentLine.SetRange(SystemId, PaymentLineParam.SystemId);
        exit(PaymentLine.FindSet());
    end;

    local procedure CaptureResetMinAge(): Duration
    begin
        exit(24 * 60 * 60 * 1000); // 24h
    end;

    local procedure CancelUnmatchedWebhookAfterGrace(var AdyenWebhook: Record "NPR Adyen Webhook")
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenAsyncPayProcessJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
        AdyenManagement: Codeunit "NPR Adyen Management";
        NoMatchingPaymentLineLbl: Label 'No %1 with %2 %3 was found. The webhook request was canceled.', Comment = '%1 = Payment Line table caption, %2 = Charge ID field caption, %3 = PSP reference of the webhook';
    begin
        if AdyenWebhook.Status = AdyenWebhook.Status::Processed then
            exit;

        if not AdyenAsyncPayProcessJQ.IsUnmatchedGraceExpired(AdyenWebhook."Event Date", CurrentDateTime()) then begin
            // The job uses this stamp to wait before it checks the webhook again.
            AdyenWebhook."Processed Date" := CurrentDateTime();
            AdyenWebhook.Modify();
            exit;
        end;

        AdyenWebhook.Status := AdyenWebhook.Status::Canceled;
        AdyenWebhook."Processed Date" := CurrentDateTime();
        AdyenWebhook.Modify();

        AdyenManagement.CreateGeneralLog(Enum::"NPR Adyen Webhook Log Type"::Process, false, StrSubstNo(NoMatchingPaymentLineLbl, PaymentLine.TableCaption, PaymentLine.FieldCaption("Charge ID"), AdyenWebhook."PSP Reference"), AdyenWebhook."Entry No.");
    end;

    local procedure TryGetPaymentLineFromNotification(NotificationItem: JsonToken; var PaymentLine: Record "NPR Magento Payment Line"; var NotifItem: JsonToken; var IsUnmatched: Boolean): Boolean
    var
        AdyenAsyncPayProcessFeature: Codeunit "NPR AdyenAsyncPmtProcesFeature";
        PspReference: Text;
    begin
        IsUnmatched := false;

        if not AdyenAsyncPayProcessFeature.IsFeatureEnabled() then
            exit(false);

        if not ExtractNotificationItem(NotificationItem, NotifItem) then begin
            IsUnmatched := true;
            exit(false);
        end;

        PspReference := ExtractPspReference(NotifItem);
        if PspReference = '' then begin
            IsUnmatched := true;
            exit(false);
        end;

        if FindPaymentLineByChargeId(PspReference, PaymentLine) then
            exit(true);

        IsUnmatched := true;
        exit(false);
    end;

    // Leaves PaymentLine filtered on the Charge ID and positioned on the first capturable line; the handlers continue with Next().
    local procedure FindPaymentLineByChargeId(PspReference: Text; var PaymentLine: Record "NPR Magento Payment Line"): Boolean
    begin
        PaymentLine.ReadIsolation := IsolationLevel::UpdLock;
        PaymentLine.SetCurrentKey("Charge Id");
        PaymentLine.SetRange("Charge Id", CopyStr(PspReference, 1, MaxStrLen(PaymentLine."Charge Id")));
        if not PaymentLine.FindSet() then
            exit(false);
        repeat
            if IsCapturableDocument(PaymentLine) then
                exit(true);
        until PaymentLine.Next() = 0;
        exit(false);
    end;

    // Keep the document rule in sync with AsyncEligible in CaptureInternal of "NPR Magento Pmt. Adyen Mgt.". Ecommerce lines from either intake version stay synchronous there and never get a Charge ID, so they are never matched here.
    local procedure IsCapturableDocument(PaymentLine: Record "NPR Magento Payment Line"): Boolean
    begin
        case PaymentLine."Document Table No." of
            Database::"Sales Invoice Header":
                exit(true);
            Database::"Sales Header":
                exit(PaymentLine."Document Type" in [PaymentLine."Document Type"::Order, PaymentLine."Document Type"::Invoice]);
        end;
        exit(false);
    end;

    local procedure ExtractPspReference(NotifItem: JsonToken) Value: Text
    var
        JsonT: JsonToken;
    begin
        if NotifItem.AsObject().Get('pspReference', JsonT) then
            Value := JsonT.AsValue().AsText();
    end;

    local procedure ExtractWebhookFailReason(NotifItem: JsonToken): Text
    var
        JsonT: JsonToken;
    begin
        if NotifItem.AsObject().Get('reason', JsonT) then
            exit(JsonT.AsValue().AsText());
        exit('');
    end;

    local procedure ExtractWebhookSuccess(NotifItem: JsonToken): Text
    var
        JsonT: JsonToken;
    begin
        if NotifItem.AsObject().Get('success', JsonT) then
            exit(JsonT.AsValue().AsText());
        exit('');
    end;

    local procedure CompleteInteractionLog(PaymentLineSystemId: Guid; Result: Boolean; ErrorText: Text)
    var
        InteractionLog: Record "NPR PG Interaction Log Entry";
        LogMgt: Codeunit "NPR PG Interactions Log Mgt.";
    begin
        InteractionLog.SetRange("Payment Line System Id", PaymentLineSystemId);
        InteractionLog.SetRange("Interaction Type", InteractionLog."Interaction Type"::Capture);
        InteractionLog.SetRange("In Progress", true);
        if not InteractionLog.FindLast() then
            exit;

        LogMgt.CompleteAsyncOperation(InteractionLog, Result, ErrorText);
    end;
}
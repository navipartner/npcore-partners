codeunit 6184783 "NPR NPRE Send Notification"
{
    Access = Internal;
    TableNo = "NPR NPRE Notification Entry";

    trigger OnRun()
    begin
        ResetStatus(Rec);
        ProcessNotification(Rec);
    end;

    var
        NotificationHandler: Codeunit "NPR NPRE Notification Handler";
        _InvalidValueTxt: Label 'Invalid %1', Comment = '%1 - field caption';

    local procedure ResetStatus(var NotificationEntry: Record "NPR NPRE Notification Entry")
    var
        InProgressTxt: Label 'Notification is being processed...', MaxLength = 250;
    begin
        NotificationEntry."Notification Send Status" := NotificationEntry."Notification Send Status"::NOT_SENT;
        NotificationEntry."Sending Result Message" := InProgressTxt;
        Clear(NotificationEntry."Sending Result Details");
        NotificationEntry."Sent at" := 0DT;
        NotificationEntry."Sent By" := '';
        NotificationEntry.Modify();
        Commit();
    end;

    local procedure ProcessNotification(var NotificationEntry: Record "NPR NPRE Notification Entry")
    begin
        if IsExpired(NotificationEntry) then
            exit;
        if not IsValidNotifMethod(NotificationEntry) then
            exit;
        if not IsValidTemplate(NotificationEntry) then
            exit;
        case NotificationEntry."Notification Method" of
            NotificationEntry."Notification Method"::EMAIL:
                SendEmailNotification(NotificationEntry);
            NotificationEntry."Notification Method"::SMS:
                SendSmsNotification(NotificationEntry);
        end;
    end;

    local procedure IsExpired(var NotificationEntry: Record "NPR NPRE Notification Entry"): Boolean
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        Expired: Boolean;
        NotifExpiredTxt: Label 'Notification has expired and won’t be sent.', MaxLength = 250;
    begin
        Expired := (NotificationEntry."Expires at Date-Time" < CurrentDateTime()) and (NotificationEntry."Expires at Date-Time" <> 0DT);
        if not Expired then
            case NotificationEntry."Notification Trigger" of
                NotificationEntry."Notification Trigger"::KDS_ORDER_DELAYED_1,
                NotificationEntry."Notification Trigger"::KDS_ORDER_DELAYED_2:
                    Expired :=
                        not KitchenOrder.Get(NotificationEntry."Kitchen Order ID") or (KitchenOrder."On Hold") or
                        not (KitchenOrder."Order Status" in [KitchenOrder."Order Status"::"In-Production", KitchenOrder."Order Status"::Released, KitchenOrder."Order Status"::Planned]);
                NotificationEntry."Notification Trigger"::KDS_ORDER_READY_FOR_SERVING:
                    Expired :=
                        not KitchenOrder.Get(NotificationEntry."Kitchen Order ID") or
                        (KitchenOrder."Order Status" in [KitchenOrder."Order Status"::Finished, KitchenOrder."Order Status"::Cancelled]);
            end;

        if Expired then begin
            NotificationEntry."Notification Send Status" := NotificationEntry."Notification Send Status"::CANCELED;
            NotificationEntry."Sending Result Message" := NotifExpiredTxt;
            NotificationEntry.Modify();
        end;
        exit(Expired);
    end;

    local procedure IsValidNotifMethod(var NotificationEntry: Record "NPR NPRE Notification Entry"): Boolean
    begin
        if NotificationEntry."Notification Method" in [NotificationEntry."Notification Method"::EMAIL, NotificationEntry."Notification Method"::SMS] then
            exit(true);
        NotificationHandler.SetNotSent(NotificationEntry, StrSubstNo(_InvalidValueTxt, NotificationEntry.FieldCaption("Notification Method")));
        exit(false);
    end;

    local procedure IsValidTemplate(var NotificationEntry: Record "NPR NPRE Notification Entry"): Boolean
    begin
        if NotificationEntry."Notification Template" <> '' then
            exit(true);
        NotificationHandler.SetNotSent(NotificationEntry, StrSubstNo(_InvalidValueTxt, NotificationEntry.FieldCaption("Notification Template")));
        exit(false);
    end;

    local procedure SendEmailNotification(var NotificationEntry: Record "NPR NPRE Notification Entry")
    var
        EmailTemplateHdr: Record "NPR E-mail Template Header";
        EmailMgt: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
        ErrorMessage: Text;
    begin
        RecRef.GetTable(NotificationEntry);
        if NotificationEntry."Notification Template" <> '' then begin
            EmailTemplateHdr.Get(NotificationEntry."Notification Template");
            EmailTemplateHdr.SetRecFilter();
        end;
        EmailMgt.SetupEmailTemplate(RecRef, NotificationEntry."Notification Address", false, EmailTemplateHdr);
        if EmailTemplateHdr."Default Recipient Address" = '' then
            NotificationHandler.SetNotSent(NotificationEntry, StrSubstNo(_InvalidValueTxt, NotificationEntry.FieldCaption("Notification Address")))
        else begin
            if NotificationEntry."Notification Template" = '' then
                NotificationEntry."Notification Template" := EmailTemplateHdr.Code;
            ErrorMessage := EmailMgt.SendEmailTemplate(RecRef, EmailTemplateHdr, EmailTemplateHdr."Default Recipient Address", true);
            if ErrorMessage <> '' then
                Error(ErrorMessage);
            NotificationHandler.SetSent(NotificationEntry);
        end;
    end;

    local procedure SendSmsNotification(var NotificationEntry: Record "NPR NPRE Notification Entry")
    var
        SmsMessageLog: Record "NPR SMS Log";
        SmsTemplateHdr: Record "NPR SMS Template Header";
        SmsMgt: Codeunit "NPR SMS Implementation";
        TypeHelper: Codeunit "Type Helper";
        SendingError: TextBuilder;
        Recipients: List of [Text];
        Recipient: Text;
        Sender: Text;
        SmsMessage: Text;
        FailedTxt: Label 'Failed to send SMS to one or more recipients.';
        QueuedTxt: Label 'Notification has been queued for processing by the dedicated SMS handler job.', MaxLength = 250;
    begin
        SMSTemplateHdr.Get(NotificationEntry."Notification Template");
        if not GetSmsRecipients(NotificationEntry, SMSTemplateHdr, Recipients) then
            exit;
        SmsMessage := SmsMgt.MakeMessage(SmsTemplateHdr, NotificationEntry);
        Sender := SmsTemplateHdr."Alt. Sender";
        if Sender = '' then
            Sender := SmsTemplateHdr.Description;
        NotificationEntry."From Message Log Entry No." := 0;

        foreach Recipient in Recipients do begin
            SmsMgt.InsertMessageLog(Recipient, Sender, SmsMessage, 0DT, SmsMessageLog.Status::Error, SmsMessageLog);
            Commit();
            if not SmsMgt.DiscardOldMessages(SmsMessageLog) then
                SmsMgt.SendQueuedSMS(SmsMessageLog);

            SmsMessageLog.Find();
            if NotificationEntry."From Message Log Entry No." = 0 then
                NotificationEntry."From Message Log Entry No." := SmsMessageLog."Entry No.";
            NotificationEntry."To Message Log Entry No." := SmsMessageLog."Entry No.";
            case SmsMessageLog.Status of
                SmsMessageLog.Status::Pending:
                    if NotificationEntry."Notification Send Status" = NotificationEntry."Notification Send Status"::NOT_SENT then
                        NotificationEntry."Notification Send Status" := NotificationEntry."Notification Send Status"::QUEUED;
                SmsMessageLog.Status::Error:
                    begin
                        NotificationEntry."Notification Send Status" := NotificationEntry."Notification Send Status"::FAILED;
                        SendingError.AppendLine(StrSubstNo('%1: %2', Recipient, GetLastErrorText()));
                    end;
            end;
        end;

        case NotificationEntry."Notification Send Status" of
            NotificationEntry."Notification Send Status"::FAILED:
                NotificationHandler.SetFailed(NotificationEntry, StrSubstNo('%1%2%3', FailedTxt, TypeHelper.CRLFSeparator(), SendingError.ToText()), false);
            NotificationEntry."Notification Send Status"::NOT_SENT:
                NotificationHandler.SetSent(NotificationEntry);
            NotificationEntry."Notification Send Status"::QUEUED:
                begin
                    NotificationEntry."Sending Result Message" := QueuedTxt;
                    NotificationEntry.Modify();
                end;
        end;
    end;

    local procedure GetSmsRecipients(var NotificationEntry: Record "NPR NPRE Notification Entry"; SMSTemplateHdr: Record "NPR SMS Template Header"; var Recipients: List of [Text]): Boolean
    var
        NpRegex: Codeunit "NPR RegEx";
        SmsMgt: Codeunit "NPR SMS Implementation";
        RecRef: RecordRef;
        SendTo: Text;
    begin
        Clear(Recipients);
        if NotificationEntry.Recipient <> NotificationEntry.Recipient::TEMPLATE then
            if NotificationEntry."Notification Address" <> '' then begin
                Recipients.Add(NotificationEntry."Notification Address");
                exit(true);
            end;

        if SMSTemplateHdr."Recipient Type" = SMSTemplateHdr."Recipient Type"::Field then begin
            RecRef.GetTable(NotificationEntry);
            SendTo := NpRegex.MergeDataFields(SMSTemplateHdr.Recipient, RecRef, 0, SmsMgt.AFReportLinkTag());
        end;
        SmsMgt.PopulateSendList(Recipients, SMSTemplateHdr."Recipient Type", SMSTemplateHdr."Recipient Group", SendTo);

        if Recipients.Count() > 0 then
            exit(true);

        NotificationHandler.SetNotSent(NotificationEntry, StrSubstNo(_InvalidValueTxt, NotificationEntry.FieldCaption("Notification Address")));
        exit(false);
    end;
}
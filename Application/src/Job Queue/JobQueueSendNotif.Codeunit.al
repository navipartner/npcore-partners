codeunit 6014624 "NPR Job Queue - Send Notif."
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry := Rec;
        if SendEmal then
            TrySendEmalNotification(JobQueueEntry);
        if SendSms then
            TrySendSmsNotification(JobQueueEntry);
    end;

    var
        SendEmal: Boolean;
        SendSms: Boolean;

    procedure SendNotifications(JobQueueEntry: Record "Job Queue Entry"; Self: Codeunit "NPR Job Queue - Send Notif.")
    begin
        if JobQueueEntry."NPR Notif. Profile on Error" = '' then
            exit;

        SendEmal := true;
        SendSms := false;
        if Self.Run(JobQueueEntry) then;

        SendEmal := false;
        SendSms := true;
        if Self.Run(JobQueueEntry) then;
    end;

    local procedure TrySendEmalNotification(JobQueueEntry: Record "Job Queue Entry")
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        JQNotifProfile: Record "NPR Job Queue Notif. Profile";
        EmailManagement: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
    begin
        if not (JQNotifProfile.Get(JobQueueEntry."NPR Notif. Profile on Error") and JQNotifProfile."Send E-mail") then
            exit;

        JQNotifProfile.TestField("E-mail Template Code");
        if EmailTemplateHeader.Get(JQNotifProfile."E-mail Template Code") then
            EmailTemplateHeader.SetRecFilter();

        RecRef.GetTable(JobQueueEntry);
        RecRef.SetRecFilter();
        if EmailTemplateHeader."Report ID" > 0 then
            EmailManagement.SendReportTemplate(EmailTemplateHeader."Report ID", RecRef, EmailTemplateHeader, JQNotifProfile."E-mail", true)
        else
            EmailManagement.SendEmailTemplate(RecRef, EmailTemplateHeader, JQNotifProfile."E-mail", true);

        if (JQNotifProfile."E-mail Template Code" <> EmailTemplateHeader.Code) and (EmailTemplateHeader.Code <> '') then begin
            JQNotifProfile."E-mail Template Code" := EmailTemplateHeader.Code;
            JQNotifProfile.Modify();
        end;
    end;

    local procedure TrySendSmsNotification(JobQueueEntry: Record "Job Queue Entry")
    var
        JQNotifProfile: Record "NPR Job Queue Notif. Profile";
        SMSTemplateHeader: Record "NPR SMS Template Header";
        SMSManagement: Codeunit "NPR SMS Management";
        TypeHelper: Codeunit "Type Helper";
        SMSMessage: Text;
    begin
        if not (JQNotifProfile.Get(JobQueueEntry."NPR Notif. Profile on Error") and JQNotifProfile."Send Sms") then
            exit;
        if not ((JQNotifProfile."Phone No." <> '') and TypeHelper.IsPhoneNumber(JQNotifProfile."Phone No.")) then
            exit;

        if (JQNotifProfile."SMS Template Code" = '') or (not SMSTemplateHeader.Get(JQNotifProfile."SMS Template Code")) then begin
            if not SMSManagement.FindTemplate(JQNotifProfile, SMSTemplateHeader) then
                exit;
            JQNotifProfile."SMS Template Code" := SMSTemplateHeader.Code;
            JQNotifProfile.Modify();
        end;

        SMSMessage := SMSManagement.MakeMessage(SMSTemplateHeader, JQNotifProfile);
        if SMSMessage <> '' then
            SMSManagement.SendSMS(JQNotifProfile."Phone No.", SMSTemplateHeader."Alt. Sender", SMSMessage);
    end;
}
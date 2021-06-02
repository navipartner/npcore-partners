codeunit 6059820 "NPR Transactional Email Mgt."
{
    procedure CheckConnection(TransactionalEmailSetup: Record "NPR Trx Email Setup")
    var
        CampaignMonitorMgt: Codeunit "NPR CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "NPR Mandrill Trans. Email Mgt";
    begin
        case TransactionalEmailSetup.Provider of
            TransactionalEmailSetup.Provider::"Campaign Monitor":
                CampaignMonitorMgt.CheckConnection();
            TransactionalEmailSetup.Provider::Mailchimp:
                MandrillTransEmailMgt.TestConnection();
        end;
    end;

    procedure GetSmartEmailList(var TransactionalJSONResult: Record "NPR Trx JSON Result" temporary)
    var
        CampaignMonitorMgt: Codeunit "NPR CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "NPR Mandrill Trans. Email Mgt";
    begin
        case TransactionalJSONResult.Provider of
            TransactionalJSONResult.Provider::"Campaign Monitor":
                CampaignMonitorMgt.GetSmartEmailList(TransactionalJSONResult);
            TransactionalJSONResult.Provider::Mailchimp:
                MandrillTransEmailMgt.GetSmartEmailList(TransactionalJSONResult);
        end;
    end;

    procedure GetSmartEmailDetails(var SmartEmail: Record "NPR Smart Email")
    var
        CampaignMonitorMgt: Codeunit "NPR CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "NPR Mandrill Trans. Email Mgt";
    begin
        case SmartEmail.Provider of
            SmartEmail.Provider::"Campaign Monitor":
                CampaignMonitorMgt.GetSmartEmailDetails(SmartEmail);
            SmartEmail.Provider::Mailchimp:
                MandrillTransEmailMgt.GetSmartEmailDetails(SmartEmail);
        end;
    end;

    procedure GetMessageDetails(EmailLog: Record "NPR Trx Email Log")
    var
        CampaignMonitorMgt: Codeunit "NPR CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "NPR Mandrill Trans. Email Mgt";
    begin
        case EmailLog.Provider of
            EmailLog.Provider::"Campaign Monitor":
                CampaignMonitorMgt.GetMessageDetails(EmailLog);
            EmailLog.Provider::Mailchimp:
                MandrillTransEmailMgt.GetMessageDetails(EmailLog);
        end;
    end;

    procedure SendSmartEmail(TransactionalEmail: Record "NPR Smart Email"; Recipient: Text; Cc: Text; Bcc: Text; RecRef: RecordRef; Silent: Boolean) ErrorMessage: Text
    var
        CampaignMonitorMgt: Codeunit "NPR CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "NPR Mandrill Trans. Email Mgt";
    begin
        case TransactionalEmail.Provider of
            TransactionalEmail.Provider::"Campaign Monitor":
                exit(CampaignMonitorMgt.SendSmartEmail(TransactionalEmail, Recipient, Cc, Bcc, RecRef, Silent));
            TransactionalEmail.Provider::Mailchimp:
                exit(MandrillTransEmailMgt.SendSmartEmail(TransactionalEmail, Recipient, Cc, Bcc, RecRef, Silent));
        end;
    end;

    procedure SendSmartEmailWAttachment(TransactionalEmail: Record "NPR Smart Email"; Recipient: Text; Cc: Text; Bcc: Text; RecRef: RecordRef; var Attachment: Record "NPR E-mail Attachment"; Silent: Boolean) ErrorMessage: Text
    var
        CampaignMonitorMgt: Codeunit "NPR CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "NPR Mandrill Trans. Email Mgt";
    begin
        case TransactionalEmail.Provider of
            TransactionalEmail.Provider::"Campaign Monitor":
                exit(CampaignMonitorMgt.SendSmartEmailWAttachment(TransactionalEmail, Recipient, Cc, Bcc, RecRef, Attachment, Silent));
            TransactionalEmail.Provider::Mailchimp:
                exit(MandrillTransEmailMgt.SendSmartEmailWAttachment(TransactionalEmail, Recipient, Cc, Bcc, RecRef, Attachment, Silent));
        end;
    end;

    procedure SendClassicMail(Recipient: Text; Cc: Text; Bcc: Text; Subject: Text; BodyHtml: Text; BodyText: Text; FromEmail: Text; FromName: Text; ReplyTo: Text; TrackOpen: Boolean; TrackClick: Boolean; Group: Text; AddRecipientsToListID: Text; var Attachment: Record "NPR E-mail Attachment"; Silent: Boolean): Text
    var
        TransactionalEmailSetup: Record "NPR Trx Email Setup";
        CampaignMonitorMgt: Codeunit "NPR CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "NPR Mandrill Trans. Email Mgt";
        EmailLbl: Label '%1 %2', Locked = true;
    begin
        TransactionalEmailSetup.SetRange(Default, true);
        if not TransactionalEmailSetup.FindFirst() then begin
            TransactionalEmailSetup.SetRange(Default);
            TransactionalEmailSetup.FindFirst();
        end;
        case TransactionalEmailSetup.Provider of
            TransactionalEmailSetup.Provider::"Campaign Monitor":
                begin
                    if (FromName <> '') and (FromName <> FromEmail) then
                        FromEmail := StrSubstNo(EmailLbl, FromName, FromEmail);
                    CampaignMonitorMgt.SendClasicMail(
                        Recipient, Cc, Bcc, Subject, BodyHtml, BodyText,
                        FromEmail, ReplyTo, TrackOpen, TrackClick, Group,
                        AddRecipientsToListID, Attachment, Silent);
                end;
            TransactionalEmailSetup.Provider::Mailchimp:
                MandrillTransEmailMgt.SendClassicMail(
                    Recipient, Cc, Bcc, Subject, BodyHtml, BodyText,
                    FromEmail, FromName, ReplyTo, TrackOpen, TrackClick, Group,
                    AddRecipientsToListID, Attachment, Silent);
        end;
    end;

    procedure PreviewSmartEmail(SmartEmail: Record "NPR Smart Email")
    var
        CampaignMonitorMgt: Codeunit "NPR CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "NPR Mandrill Trans. Email Mgt";
    begin
        case SmartEmail.Provider of
            SmartEmail.Provider::"Campaign Monitor":
                CampaignMonitorMgt.PreviewSmartEmail(SmartEmail);
            SmartEmail.Provider::Mailchimp:
                MandrillTransEmailMgt.PreviewSmartEmail(SmartEmail);
        end;
    end;
}


codeunit 6059820 "Transactional Email Mgt."
{
    // NPR5.55/THRO/20200511 CASE 343266 Object created


    trigger OnRun()
    begin
    end;

    procedure CheckConnection(TransactionalEmailSetup: Record "Transactional Email Setup")
    var
        CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "Mandrill Trans. Email Mgt";
    begin
        case TransactionalEmailSetup.Provider of
          TransactionalEmailSetup.Provider::"Campaign Monitor":
            CampaignMonitorMgt.CheckConnection();
          TransactionalEmailSetup.Provider::Mailchimp:
            MandrillTransEmailMgt.TestConnection();
        end;
    end;

    procedure GetSmartEmailList(var TransactionalJSONResult: Record "Transactional JSON Result" temporary)
    var
        CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "Mandrill Trans. Email Mgt";
    begin
        case TransactionalJSONResult.Provider of
          TransactionalJSONResult.Provider::"Campaign Monitor":
            CampaignMonitorMgt.GetSmartEmailList(TransactionalJSONResult);
          TransactionalJSONResult.Provider::Mailchimp:
            MandrillTransEmailMgt.GetSmartEmailList(TransactionalJSONResult);
        end;
    end;

    procedure GetSmartEmailDetails(var SmartEmail: Record "Smart Email")
    var
        CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "Mandrill Trans. Email Mgt";
    begin
        case SmartEmail.Provider of
          SmartEmail.Provider::"Campaign Monitor":
            CampaignMonitorMgt.GetSmartEmailDetails(SmartEmail);
          SmartEmail.Provider::Mailchimp:
            MandrillTransEmailMgt.GetSmartEmailDetails(SmartEmail);
        end;
    end;

    procedure GetMessageDetails(EmailLog: Record "Transactional Email Log")
    var
        CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "Mandrill Trans. Email Mgt";
    begin
        case EmailLog.Provider of
          EmailLog.Provider::"Campaign Monitor":
            CampaignMonitorMgt.GetMessageDetails(EmailLog);
          EmailLog.Provider::Mailchimp:
            MandrillTransEmailMgt.GetMessageDetails(EmailLog);
        end;
    end;

    procedure SendSmartEmail(TransactionalEmail: Record "Smart Email";Recipient: Text;Cc: Text;Bcc: Text;RecRef: RecordRef;Silent: Boolean) ErrorMessage: Text
    var
        CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "Mandrill Trans. Email Mgt";
    begin
        case TransactionalEmail.Provider of
          TransactionalEmail.Provider::"Campaign Monitor":
            exit(CampaignMonitorMgt.SendSmartEmail(TransactionalEmail, Recipient, Cc, Bcc, RecRef, Silent));
          TransactionalEmail.Provider::Mailchimp:
            exit(MandrillTransEmailMgt.SendSmartEmail(TransactionalEmail, Recipient, Cc, Bcc, RecRef,Silent));
        end;
    end;

    procedure SendSmartEmailWAttachment(TransactionalEmail: Record "Smart Email";Recipient: Text;Cc: Text;Bcc: Text;RecRef: RecordRef;var Attachment: Record "E-mail Attachment";Silent: Boolean) ErrorMessage: Text
    var
        CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "Mandrill Trans. Email Mgt";
    begin
        case TransactionalEmail.Provider of
          TransactionalEmail.Provider::"Campaign Monitor":
            exit(CampaignMonitorMgt.SendSmartEmailWAttachment(TransactionalEmail, Recipient, Cc, Bcc, RecRef, Attachment,Silent));
          TransactionalEmail.Provider::Mailchimp:
            exit(MandrillTransEmailMgt.SendSmartEmailWAttachment(TransactionalEmail, Recipient, Cc, Bcc, RecRef, Attachment,Silent));
        end;
    end;

    procedure SendClassicMail(Recipient: Text;Cc: Text;Bcc: Text;Subject: Text;BodyHtml: Text;BodyText: Text;FromEmail: Text;FromName: Text;ReplyTo: Text;TrackOpen: Boolean;TrackClick: Boolean;Group: Text;AddRecipientsToListID: Text;var Attachment: Record "E-mail Attachment";Silent: Boolean): Text
    var
        TransactionalEmailSetup: Record "Transactional Email Setup";
        CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "Mandrill Trans. Email Mgt";
    begin
        TransactionalEmailSetup.SetRange(Default, true);
        if not TransactionalEmailSetup.FindFirst then begin
          TransactionalEmailSetup.SetRange(Default);
          TransactionalEmailSetup.FindFirst;
        end;
        case TransactionalEmailSetup.Provider of
          TransactionalEmailSetup.Provider::"Campaign Monitor":
            begin
              if (FromName <> '') and (FromName <> FromEmail) then
                FromEmail := StrSubstNo('%1 %2',FromName,FromEmail);
              CampaignMonitorMgt.SendClasicMail(Recipient, Cc, Bcc, Subject, BodyHtml, BodyText, FromEmail, ReplyTo, TrackOpen, TrackClick, Group, AddRecipientsToListID, Attachment, Silent);
            end;
          TransactionalEmailSetup.Provider::Mailchimp:
            MandrillTransEmailMgt.SendClassicMail(Recipient, Cc, Bcc, Subject, BodyHtml, BodyText, FromEmail, FromName, ReplyTo, TrackOpen, TrackClick, Group, AddRecipientsToListID, Attachment, Silent);
        end;
    end;

    procedure PreviewSmartEmail(SmartEmail: Record "Smart Email")
    var
        CampaignMonitorMgt: Codeunit "CampaignMonitor Mgt.";
        MandrillTransEmailMgt: Codeunit "Mandrill Trans. Email Mgt";
    begin
        case SmartEmail.Provider of
          SmartEmail.Provider::"Campaign Monitor":
            CampaignMonitorMgt.PreviewSmartEmail(SmartEmail);
          SmartEmail.Provider::Mailchimp:
            MandrillTransEmailMgt.PreviewSmartEmail(SmartEmail);
        end;
    end;
}


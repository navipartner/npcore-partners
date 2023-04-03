codeunit 6059940 "NPR SMS Management"
{
    Access = Public;

    var
        UserNotified: Boolean;

    #region SMS functions
    procedure SendSMS(PhoneNo: Text; SenderNo: Text; Message: Text)
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.SendSMS(PhoneNo, SenderNo, Message, UserNotified);
    end;

    procedure SendSMS(PhoneNo: Text; SenderNo: Text; Message: Text; DelayUntil: DateTime)
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.SendSMS(PhoneNo, SenderNo, Message, DelayUntil);
    end;


    procedure QueueMessages(PhoneNo: List of [Text]; SenderNo: Text; Message: Text; DelayUntil: DateTime)
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.QueueMessages(PhoneNo, SenderNo, Message, DelayUntil);
    end;

    procedure SendTestSMS(var Template: Record "NPR SMS Template Header")
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.SendTestSMS(Template);
    end;

    procedure SendBatchSMS(SMSTemplateHeader: Record "NPR SMS Template Header")
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.SendBatchSMS(SMSTemplateHeader);
    end;

    procedure EditAndSendSMS(RecordToSendVariant: Variant)
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.EditAndSendSMS(RecordToSendVariant);
    end;
    #endregion
    #region Message Log
    procedure InsertMessageLog(PhoneNo: Text; SenderNo: Text; Message: Text; SendDT: DateTime)
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.InsertMessageLog(PhoneNo, SenderNo, Message, SendDT);
    end;

    #endregion
    #region Notification
    procedure QueuedNotification()
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.QueuedNotification();
    end;

    procedure OpenErrorMessages(SMSSentNotification: Notification)
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.OpenErrorMessages(SMSSentNotification);
    end;

    procedure OpenMessageSetup(SMSSentNotification: Notification)
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.OpenMessageSetup(SMSSentNotification);
    end;

    #endregion
    #region Template handling
    procedure FindTemplate(RecordVariant: Variant; var Template: Record "NPR SMS Template Header"): Boolean
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
        IsHandled: Boolean;
        TemplateFound: Boolean;
    begin
        OnBeforeFindTemplate(IsHandled, RecordVariant, Template);
        TemplateFound := SMSImplementation.FindTemplate(RecordVariant, Template, IsHandled);
        OnAfterFindTemplate(RecordVariant, Template, TemplateFound);
        exit(TemplateFound);
    end;

    [IntegrationEvent(false, FALSE)]
    local procedure OnBeforeFindTemplate(var IsHandled: Boolean; RecordVariant: Variant; var Template: Record "NPR SMS Template Header")
    begin
    end;

    [IntegrationEvent(false, FALSE)]
    local procedure OnAfterFindTemplate(RecordVariant: Variant; var Template: Record "NPR SMS Template Header"; var TemplateFound: Boolean)
    begin
    end;

    procedure MakeMessage(Template: Record "NPR SMS Template Header"; RecordVariant: Variant) SMSMessage: Text
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSMessage := SMSImplementation.MakeMessage(Template, RecordVariant);
    end;
    #endregion
    #region Job functions
    procedure CreateMessageJob(JobCategory: Code[10])
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.CreateMessageJob(JobCategory);
    end;

    procedure DeleteMessageJob(JobCategory: Code[10])
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        SMSImplementation.DeleteMessageJob(JobCategory);
    end;

    procedure GetJobQueueCategoryCode(): Code[10]
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        exit(SMSImplementation.GetJobQueueCategoryCode());
    end;
    #endregion
    #region Report Links Azure Functions
    procedure AFReportLink(ReportId: Integer): Text
    var
        SMSImplementation: Codeunit "NPR SMS Implementation";
    begin
        exit(SMSImplementation.AFReportLink(ReportId));
    end;
    #endregion Report Links Azure Functions 
}

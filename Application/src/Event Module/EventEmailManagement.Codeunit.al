codeunit 6060153 "NPR Event Email Management"
{
    var
        EventMgt: Codeunit "NPR Event Management";
        EventEWSMgt: Codeunit "NPR Event EWS Management";
        JobsSetup: Record "Jobs Setup";
        ConfirmSendMail: Label 'You''re about to send e-mail(s). Do you want to continue?';
        NoReportLayout: Label 'There is no report layout. Please create one either from Words Layout page or Report Layout Selection and set it as a default.';
        UseTemplate: Boolean;
        EventExchIntTemplate: Record "NPR Event Exch. Int. Template";
        NoEmailTemplate: Label 'No email template was found/selected. Email will be sent without one. Do you want to continue?';
        EmailCounter: Integer;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobOnAfterInsert(var Rec: Record Job; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        if not EventMgt.IsEventJob(Rec) then
            exit;

        Rec."NPR Mail Item Status" := Rec."NPR Mail Item Status"::" ";
        Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'Bill-to Customer No.', false, false)]
    local procedure JobBilltoCustomerNoOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    var
        Cust: Record Customer;
    begin
        if not EventMgt.IsEventJob(Rec) then
            exit;

        if Rec."Bill-to Customer No." <> '' then begin
            Cust.Get(Rec."Bill-to Customer No.");
            Rec."NPR Bill-to E-Mail" := Cust."E-Mail";
        end else
            Rec."NPR Bill-to E-Mail" := '';
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobPlanningLineOnAfterInsert(var Rec: Record "Job Planning Line"; RunTrigger: Boolean)
    var
        Job: Record Job;
    begin
        if not RunTrigger then
            exit;

        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
            exit;

        Rec."NPR Mail Item Status" := Rec."NPR Mail Item Status"::" ";
        Rec.Modify;
    end;

    procedure SendEMail(var Job: Record Job; MailFor: Option Customer,Team; CalledFromFieldNo: Integer)
    var
        StatusWarning: Label 'Event is in status %1. Do you still want to send e-mail?';
        RecRef: RecordRef;
        Processed: Boolean;
    begin
        if EmailCounter = 0 then
            if not Confirm(ConfirmSendMail) then
                exit;

        EventEWSMgt.SetSkipLookup(CalledFromFieldNo <> 0);
        if CalledFromFieldNo = 0 then
            if not EventEWSMgt.CheckStatus(Job, false) then
                if not Confirm(StrSubstNo(StatusWarning, Format(Job."NPR Event Status"))) then
                    exit;

        if MailFor = MailFor::Customer then
            Job.TestField("NPR Bill-to E-Mail");

        if not UseTemplate then
            UseTemplate := EventEWSMgt.UseTemplate(Job, MailFor, 0, EventExchIntTemplate);

        if not UseTemplate then
            if not Confirm(NoEmailTemplate) then
                exit;

        JobsSetup.Get();
        EventEWSMgt.OrganizerAccountSet(Job, true, true);

        if not EventEWSMgt.IncludeAttachmentCheck(Job, MailFor) then
            Error(NoReportLayout);

        RecRef.GetTable(Job);
        Processed := ProcessMailItemWithLog(RecRef, MailFor);
        RecRef.SetTable(Job);
        if Processed then
            Job."NPR Mail Item Status" := Job."NPR Mail Item Status"::Sent
        else
            Job."NPR Mail Item Status" := Job."NPR Mail Item Status"::Error;

        if CalledFromFieldNo = 0 then
            Job.Modify;
    end;

    procedure SendEmailFromLine(var JobPlanningLine: Record "Job Planning Line")
    var
        RecRef: RecordRef;
        Job: Record Job;
        IncludeAttachment: Boolean;
    begin
        if not Confirm(ConfirmSendMail) then
            exit;

        JobPlanningLine.TestField("NPR Resource E-Mail");

        JobsSetup.Get();
        Job.Get(JobPlanningLine."Job No.");

        UseTemplate := EventEWSMgt.UseTemplate(Job, 1, 0, EventExchIntTemplate);
        EventEWSMgt.OrganizerAccountSet(Job, true, true);

        if not EventEWSMgt.IncludeAttachmentCheck(Job, 1) then
            Error(NoReportLayout);

        RecRef.GetTable(JobPlanningLine);

        if ProcessMailItemWithLog(RecRef, 1) then
            JobPlanningLine."NPR Mail Item Status" := JobPlanningLine."NPR Mail Item Status"::Sent
        else
            JobPlanningLine."NPR Mail Item Status" := JobPlanningLine."NPR Mail Item Status"::Error;

        JobPlanningLine.Modify;
    end;

    procedure ProcessMailItemWithLog(var RecRef: RecordRef; MailFor: Option Customer,Team): Boolean
    var
        ActivityLog: Record "Activity Log";
        ActivityDescription: Label 'Processing Mail Item...';
        SuccessfulMailItem: Label 'Successfully sent an e-mail.';
    begin
        if not ProcessMailItem(RecRef, MailFor) then begin
            ActivityLog.LogActivity(RecRef.RecordId, 1, '', ActivityDescription, CopyStr(GetLastErrorText, 1, MaxStrLen(ActivityLog."Activity Message")));
            exit(false);
        end;
        ActivityLog.LogActivity(RecRef.RecordId, 0, '', ActivityDescription, SuccessfulMailItem);
        exit(true);
    end;

    procedure ProcessMailItem(var RecRef: RecordRef; MailFor: Option Customer,Team): Boolean
    var
        ExchService: DotNet NPRNetExchangeService;
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
        EmailMessage: DotNet NPRNetEmailMessage;
        EMailTemplateLine: Record "NPR E-mail Templ. Line";
        RecRef2: RecordRef;
        BodyText: Text;
        MessageBody: DotNet NPRNetMessageBody;
        BodyType: DotNet NPRNetBodyType;
        MailSubjectText: Label '%1 for event %2';
        FileName: Text;
        MailBodyAddText: Label 'Attached you can find more details about the event.';
        ResourceGroup: Record "Resource Group";
        FileMgt: Codeunit "File Management";
        EMailTemplateHeader: Record "NPR E-mail Template Header";
        ParsedLine: Text;
        ParsedSuffix: Text;
        JobPlanningLineTickets: Record "Job Planning Line";
        EventTicketMgt: Codeunit "NPR Event Ticket Mgt.";
        CollectedURLs: Text;
    begin
        case RecRef.Number of
            DATABASE::Job:
                begin
                    RecRef.SetTable(Job);
                    EventEWSMgt.SetJobPlanLineFilter(Job, JobPlanningLine);
                end;
            DATABASE::"Job Planning Line":
                begin
                    RecRef.SetTable(JobPlanningLine);
                    JobPlanningLine.SetRecFilter;
                    Job.Get(JobPlanningLine."Job No.");
                end;
        end;

        if not EventEWSMgt.InitializeExchService(RecRef.RecordId, Job, ExchService, 0) then
            exit(false);
        EmailMessage := EmailMessage.EmailMessage(ExchService);

        case MailFor of
            MailFor::Customer:
                AddEMailRecipient(EmailMessage, 0, Job."NPR Bill-to E-Mail");
            MailFor::Team:
                if JobPlanningLine.FindSet then
                    repeat
                        AddEMailRecipient(EmailMessage, 0, JobPlanningLine."NPR Resource E-Mail");
                        if JobPlanningLine."Resource Group No." <> '' then begin
                            ResourceGroup.Get(JobPlanningLine."Resource Group No.");
                            if ResourceGroup."NPR E-Mail" <> '' then
                                AddEMailRecipient(EmailMessage, 1, ResourceGroup."NPR E-Mail");
                        end;
                    until JobPlanningLine.Next = 0;
        end;

        if UseTemplate and (EMailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code")) then begin
            RecRef2.GetTable(Job);
            EmailMessage.Subject := EventEWSMgt.ParseEmailTemplateText(RecRef2, EMailTemplateHeader.Subject);
            EMailTemplateLine.SetRange("E-mail Template Code", EMailTemplateHeader.Code);
            if EMailTemplateLine.FindSet then begin
                BodyText := '<font face="Calibri">';
                repeat
                    JobPlanningLineTickets.SetRange("Job No.", Job."No.");
                    JobPlanningLineTickets.SetRange("NPR Ticket Collect Status", JobPlanningLineTickets."NPR Ticket Collect Status"::Collected);
                    ParsedLine := EventEWSMgt.ParseEmailTemplateText(RecRef2, EMailTemplateLine."Mail Body Line") + '</br>';
                    if (EventExchIntTemplate."Ticket URL Placeholder(E-Mail)" <> '') and
                      (StrPos(ParsedLine, EventExchIntTemplate."Ticket URL Placeholder(E-Mail)") > 0) and
                      not JobPlanningLineTickets.IsEmpty then begin
                        ParsedSuffix := CopyStr(ParsedLine, StrPos(ParsedLine, EventExchIntTemplate."Ticket URL Placeholder(E-Mail)") + StrLen(EventExchIntTemplate."Ticket URL Placeholder(E-Mail)"));
                        ParsedLine := CopyStr(ParsedLine, 1, StrPos(ParsedLine, EventExchIntTemplate."Ticket URL Placeholder(E-Mail)") - 1);
                        CollectedURLs := '';
                        JobPlanningLineTickets.FindSet;
                        repeat
                            if CollectedURLs <> '' then
                                CollectedURLs += ', ';
                            CollectedURLs += '<a href="' + EventTicketMgt.GetTicketURL(JobPlanningLineTickets) + '">' + JobPlanningLineTickets.Description + '</a>';
                        until JobPlanningLineTickets.Next = 0;
                        BodyText += ParsedLine + CollectedURLs + ParsedSuffix;
                    end else
                        BodyText += ParsedLine;
                until EMailTemplateLine.Next = 0;
                BodyText += '</br></font>';
                EmailMessage.Body := MessageBody.MessageBody(BodyType.HTML, BodyText);
            end;
        end else
            EmailMessage.Subject := EventEWSMgt.CreateFileName(Job, EMailTemplateHeader);

        if EventEWSMgt.CreateAttachment(Job, MailFor, EMailTemplateHeader, FileName) then
            EmailMessage.Attachments.AddFileAttachment(FileName);

        if not EMailMessageSendAndSaveCopyWithLog(RecRef.RecordId, ExchService, EmailMessage, Job) then
            exit(false);
        FileMgt.DeleteServerFile(FileName);
        exit(true);
    end;

    local procedure AddEMailRecipient(var EmailMessage: DotNet NPRNetEmailMessage; RecipientType: Option "To",Cc,Bcc; EMail: Text)
    var
        EMailAddress: DotNet NPRNetEmailAddress;
        EMailAddressCollection: DotNet NPRNetEmailAddressCollection;
        EMailEnumerator: DotNet NPRNetIEnumerator_Of_T;
        Found: Boolean;
    begin
        case RecipientType of
            RecipientType::"To":
                EMailAddressCollection := EmailMessage.ToRecipients;
            RecipientType::Cc:
                EMailAddressCollection := EmailMessage.CcRecipients;
            RecipientType::Bcc:
                EMailAddressCollection := EmailMessage.BccRecipients;
        end;

        EMailAddress := EMailAddress.EmailAddress();
        EMailEnumerator := EMailAddressCollection.GetEnumerator();
        while EMailEnumerator.MoveNext() and not Found do begin
            EMailAddress := EMailEnumerator.Current();
            Found := EMailAddress.Address = EMail;
        end;

        if not Found then
            case RecipientType of
                RecipientType::"To":
                    EmailMessage.ToRecipients.Add(EMail);
                RecipientType::Cc:
                    EmailMessage.CcRecipients.Add(EMail);
                RecipientType::Bcc:
                    EmailMessage.BccRecipients.Add(EMail);
            end;
    end;

    local procedure EMailMessageSendAndSaveCopyWithLog(RecordId: RecordID; ExchService: DotNet NPRNetExchangeService; EmailMessage: DotNet NPRNetEmailMessage; var Job: Record Job): Boolean
    var
        ActivityLog: Record "Activity Log";
        SendContext: Label 'E-MAIL SEND';
        ActivityDescription: Label 'Sending...';
    begin
        if not EMailMessageSendAndSaveCopy(EmailMessage) then begin
            //try again
            if not EMailMessageSendAndSaveCopy(EmailMessage) then begin
                ActivityLog.LogActivity(RecordId, 1, SendContext, ActivityDescription, CopyStr(GetLastErrorText, 1, MaxStrLen(ActivityLog."Activity Message")));
                exit(false);
            end;
        end;
        exit(true);
    end;

    [TryFunction]
    local procedure EMailMessageSendAndSaveCopy(EmailMessage: DotNet NPRNetEmailMessage)
    begin
        EmailMessage.SendAndSaveCopy();
    end;

    procedure SetEventExcIntTemplate(EventExchIntTemplateHere: Record "NPR Event Exch. Int. Template")
    begin
        UseTemplate := true;
        EventExchIntTemplate := EventExchIntTemplateHere;
    end;

    procedure SetAskOnce(EmailCounterHere: Integer)
    begin
        EmailCounter := EmailCounterHere;
    end;
}


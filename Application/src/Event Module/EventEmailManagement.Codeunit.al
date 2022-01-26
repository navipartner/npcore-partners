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

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobOnAfterInsert(var Rec: Record Job; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        if not EventMgt.IsEventJob(Rec) then
            exit;

        Rec."NPR Mail Item Status" := Rec."NPR Mail Item Status"::" ";
        Rec.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::Job, 'OnAfterValidateEvent', 'Bill-to Customer No.', false, false)]
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

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterInsertEvent', '', false, false)]
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
        Rec.Modify();
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
            Job.Modify();
    end;

    procedure SendEmailFromLine(var JobPlanningLine: Record "Job Planning Line")
    var
        RecRef: RecordRef;
        Job: Record Job;
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

        JobPlanningLine.Modify();
    end;

    procedure ProcessMailItemWithLog(var RecRef: RecordRef; MailFor: Option Customer,Team): Boolean
    var
        ActivityLog: Record "Activity Log";
        ActivityDescription: Label 'Processing Mail Item...';
        SuccessfulMailItem: Label 'Successfully sent an e-mail.';
    begin
        if not ProcessMailItemNew(RecRef, MailFor) then begin
            ActivityLog.LogActivity(RecRef.RecordId, 1, '', ActivityDescription, CopyStr(GetLastErrorText, 1, MaxStrLen(ActivityLog."Activity Message")));
            exit(false);
        end;
        ActivityLog.LogActivity(RecRef.RecordId, 0, '', ActivityDescription, SuccessfulMailItem);
        exit(true);
    end;


    procedure ProcessMailItemNew(var RecRef: RecordRef; MailFor: Option Customer,Team): Boolean
    var
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
        RecRef2: RecordRef;
        BodyText: Text;
        ResourceGroup: Record "Resource Group";
        EMailTemplateHeader: Record "NPR E-mail Template Header";
        Recipients, CcRecipients : List of [Text];
#IF NOT BC17
        EmailRelationType: Enum "Email Relation Type";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        BCCRecipients: List of [Text];
#ENDIF
        EmailAccount: Record "Email Account";
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
                    JobPlanningLine.SetRecFilter();
                    Job.Get(JobPlanningLine."Job No.");
                end;
        end;

        case MailFor of
            MailFor::Customer:
                Recipients.Add(Job."NPR Bill-to E-Mail");
            MailFor::Team:
                if JobPlanningLine.FindSet() then
                    repeat
                        Recipients.Add(JobPlanningLine."NPR Resource E-Mail");
                        if JobPlanningLine."Resource Group No." <> '' then begin
                            ResourceGroup.Get(JobPlanningLine."Resource Group No.");
                            if ResourceGroup."NPR E-Mail" <> '' then
                                CcRecipients.Add(ResourceGroup."NPR E-Mail");
                        end;
                    until JobPlanningLine.Next() = 0;
        end;

        if UseTemplate and (EMailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code")) then begin
            RecRef2.GetTable(Job);
            CreateBody(BodyText, EMailTemplateHeader.Code, Job."No.", RecRef2);
        end;

        GetEmailAccount(EmailAccount, Job);


#IF NOT BC17
        EmailMessage.Create(Recipients, EventEWSMgt.ParseEmailTemplateText(RecRef2, EMailTemplateHeader.Subject), BodyText, true, CcRecipients, BCCRecipients);
        AddAttachment(MailFor, Job, EmailMessage);
#if BC20
        Email.AddRelation(EmailMessage, Database::Job, Job.SystemId, EmailRelationType::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
#else
        Email.AddRelation(EmailMessage, Database::Job, Job.SystemId, EmailRelationType::"Primary Source");
#endif

        if EventExchIntTemplate."Open E-mail dialog" then
            Email.OpenInEditorModally(EmailMessage, EmailAccount)
        else
            Email.Send(EmailMessage, EmailAccount);
#ENDIF
    end;

    local procedure CreateBody(var BodyText: Text; EmailTemplateHeaderCode: Code[20]; JobNo: Code[20]; RecRef2: RecordRef)
    var
        EMailTemplateLine: Record "NPR E-mail Templ. Line";
        ParsedLine, ParsedSuffix, CollectedURLs : Text;
        JobPlanningLineTickets: Record "Job Planning Line";
        EventTicketMgt: Codeunit "NPR Event Ticket Mgt.";
    begin
        EMailTemplateLine.SetRange("E-mail Template Code", EmailTemplateHeaderCode);
        if EMailTemplateLine.FindSet() then begin
            BodyText := '<font face="Calibri">';
            repeat
                JobPlanningLineTickets.SetRange("Job No.", JobNo);
                JobPlanningLineTickets.SetRange("NPR Ticket Collect Status", JobPlanningLineTickets."NPR Ticket Collect Status"::Collected);
                ParsedLine := EventEWSMgt.ParseEmailTemplateText(RecRef2, EMailTemplateLine."Mail Body Line") + '</br>';
                if (EventExchIntTemplate."Ticket URL Placeholder(E-Mail)" <> '') and
                  (StrPos(ParsedLine, EventExchIntTemplate."Ticket URL Placeholder(E-Mail)") > 0) and
                  not JobPlanningLineTickets.IsEmpty then begin
                    ParsedSuffix := CopyStr(ParsedLine, StrPos(ParsedLine, EventExchIntTemplate."Ticket URL Placeholder(E-Mail)") + StrLen(EventExchIntTemplate."Ticket URL Placeholder(E-Mail)"));
                    ParsedLine := CopyStr(ParsedLine, 1, StrPos(ParsedLine, EventExchIntTemplate."Ticket URL Placeholder(E-Mail)") - 1);
                    CollectedURLs := '';
                    JobPlanningLineTickets.FindSet();
                    repeat
                        if CollectedURLs <> '' then
                            CollectedURLs += ', ';
                        CollectedURLs += '<a href="' + EventTicketMgt.GetTicketURL(JobPlanningLineTickets) + '">' + JobPlanningLineTickets.Description + '</a>';
                    until JobPlanningLineTickets.Next() = 0;
                    BodyText += ParsedLine + CollectedURLs + ParsedSuffix;
                end else
                    BodyText += ParsedLine;
            until EMailTemplateLine.Next() = 0;
            BodyText += '</br></font>';
        end;
    end;
#IF NOT BC17
    local procedure AddAttachment(var MailFor: Option Customer,Team; var Job: Record Job; var EmailMessage: Codeunit "Email Message")
    var
        EventReportLayout: Record "NPR Event Report Layout";
        AttachmentTempBlob: Codeunit "Temp Blob";
        AttachmentStream: InStream;
        AttachmentName: Text;
        AttachmentExtension: Text;
    begin

        EventReportLayout.Reset();
        EventReportLayout.SetRange("Event No.", Job."No.");
        EventReportLayout.SetRange(Usage, MailFor + 1);
        if EventReportLayout.FindSet() then
            repeat
                if EventEWSMgt.CreateAttachment(EventReportLayout, Job, MailFor, AttachmentTempBlob, AttachmentName, AttachmentExtension) then begin
                    AttachmentTempBlob.CreateInStream(AttachmentStream);
                    EmailMessage.AddAttachment(AttachmentName, AttachmentExtension, AttachmentStream);
                    Clear(AttachmentTempBlob);
                end;
            until EventReportLayout.Next() = 0;
    end;
#ENDIF
    local procedure GetEmailAccount(var EmailAccount: Record "Email Account"; Job: Record Job)
    var
        EventExchIntEMail: Record "NPR Event Exch. Int. E-Mail";
        EmailAccountCodeunit: Codeunit "Email Account";
        NoEmailAccountsErr: Label 'There are no Email Accounts created. First create Email Accounts';
    begin
        EmailAccountCodeunit.GetAllAccounts(false, EmailAccount);
        if EmailAccount.IsEmpty() then
            Error(NoEmailAccountsErr);

        EventEWSMgt.GetEventExchIntEmail(EventExchIntEMail);
        if EventExchIntEMail."E-Mail" <> '' then
            EmailAccount.SetRange("Email Address", EventExchIntEMail."E-Mail")
        else
            EmailAccount.SetRange("Email Address", Job."NPR Organizer E-Mail");
        EmailAccount.FindFirst();
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


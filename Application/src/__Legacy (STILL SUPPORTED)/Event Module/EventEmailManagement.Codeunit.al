codeunit 6060153 "NPR Event Email Management"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;

    var
        JobsSetup: Record "Jobs Setup";
        EventExchIntTemplate: Record "NPR Event Exch. Int. Template";
        EventEWSMgt: Codeunit "NPR Event EWS Management";
        EventMgt: Codeunit "NPR Event Management";
        UseTemplate: Boolean;
        EmailCounter: Integer;
        ConfirmSendMail: Label 'You''re about to send e-mail(s). Do you want to continue?';
        NoEmailTemplate: Label 'No email template was found/selected. Email will be sent without one. Do you want to continue?';
        NoReportLayout: Label 'There is no report layout. Please create one either from Words Layout page or Report Layout Selection and set it as a default.';

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
        RecRef: RecordRef;
        Processed: Boolean;
        StatusWarning: Label 'Event is in status %1. Do you still want to send e-mail?';
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
        Job: Record Job;
        RecRef: RecordRef;
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
        Source: Text[250];
        ResourceGroup: Record "Resource Group";
        EMailTemplateHeader: Record "NPR E-mail Template Header";
        CcRecipients, Recipients : List of [Text];
#IF NOT BC17
        EmailRelationType: Enum "Email Relation Type";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
        BCCRecipients: List of [Text];
        EmailAction: Enum "Email Action";
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
            CreateBody(BodyText, EMailTemplateHeader, Job."No.", RecRef2);
        end;

        EventEWSMgt.GetOrganizerSetup(Job, Source);
        GetEmailAccount(EmailAccount);

#IF NOT BC17
        EmailMessage.Create(Recipients, EmailTemplateMgt.MergeMailContent(RecRef2, EMailTemplateHeader.Subject, EMailTemplateHeader."Fieldnumber Start Tag", EMailTemplateHeader."Fieldnumber End Tag"), BodyText, true, CcRecipients, BCCRecipients);
        AddAttachment(EventExchIntTemplate."E-mail Template Header Code", MailFor, Job, EmailMessage);
#if BC18
        Email.AddRelation(EmailMessage, Database::Job, Job.SystemId, EmailRelationType::"Primary Source");
#else
        Email.AddRelation(EmailMessage, Database::Job, Job.SystemId, EmailRelationType::"Primary Source", Enum::"Email Relation Origin"::"Compose Context");
#endif

        if EventExchIntTemplate."Open E-mail dialog" then
            exit(Email.OpenInEditorModally(EmailMessage, EmailAccount) = EmailAction::Sent)
        else
            exit(Email.Send(EmailMessage, EmailAccount));
#ENDIF
    end;

    local procedure CreateBody(var BodyText: Text; EmailTemplateHeader: Record "NPR E-mail Template Header"; JobNo: Code[20]; RecRef2: RecordRef)
    var
        JobPlanningLineTickets: Record "Job Planning Line";
        EMailTemplateLine: Record "NPR E-mail Templ. Line";
        EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
        EventTicketMgt: Codeunit "NPR Event Ticket Mgt.";
        InStream: Instream;
        CollectedURLs, ParsedLine, ParsedSuffix : Text;
    begin
        if (EmailTemplateHeader."Use HTML Template") and (EmailTemplateHeader."HTML Template".HasValue()) then begin
            EmailTemplateHeader.CalcFields("HTML Template");
            EmailTemplateHeader."HTML Template".CreateInStream(InStream);
            InStream.Read(BodyText);
            BodyText := EmailTemplateMgt.MergeMailContent(RecRef2, BodyText, EmailTemplateHeader."Fieldnumber Start Tag", EmailTemplateHeader."Fieldnumber End Tag");
            Clear(InStream);
        end else begin
            EMailTemplateLine.SetRange("E-mail Template Code", EmailTemplateHeader.Code);
            if EMailTemplateLine.FindSet() then begin
                BodyText := '<font face="Calibri">';
                repeat
                    JobPlanningLineTickets.SetRange("Job No.", JobNo);
                    JobPlanningLineTickets.SetRange("NPR Ticket Collect Status", JobPlanningLineTickets."NPR Ticket Collect Status"::Collected);
                    ParsedLine := EmailTemplateMgt.MergeMailContent(RecRef2, EMailTemplateLine."Mail Body Line", EmailTemplateHeader."Fieldnumber Start Tag", EmailTemplateHeader."Fieldnumber End Tag") + '</br>';
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
    end;
#IF NOT BC17
    local procedure AddAttachment(EmailTemplateHeaderCode: Code[20]; var MailFor: Option Customer,Team; var Job: Record Job; var EmailMessage: Codeunit "Email Message")
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        EventReportLayout: Record "NPR Event Report Layout";
        EmailTemplateMgt: Codeunit "NPR E-mail Templ. Mgt.";
        AttachmentTempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        AttachmentStream: InStream;
        AttachmentExtension: Text;
        AttachmentName: Text;
    begin
        if EmailTemplateHeader.Get(EmailTemplateHeaderCode) and (EmailTemplateHeader.Filename <> '') then begin
            RecRef.GetTable(Job);
            AttachmentName := EmailTemplateMgt.MergeMailContent(RecRef, EmailTemplateHeader.Filename, EmailTemplateHeader."Fieldnumber Start Tag", EmailTemplateHeader."Fieldnumber End Tag");
        end;

        EventReportLayout.Reset();
        EventReportLayout.SetRange("Event No.", Job."No.");
        EventReportLayout.SetRange(Usage, MailFor + 1);
        if EventReportLayout.FindSet() then
            repeat
                if EventEWSMgt.CreateAttachment(EventReportLayout, Job, MailFor, AttachmentTempBlob, AttachmentName, AttachmentExtension) then begin
                    AttachmentTempBlob.CreateInStream(AttachmentStream);
                    EmailMessage.AddAttachment(CopyStr(AttachmentName, 1, 250), CopyStr(AttachmentExtension, 1, 250), AttachmentStream);
                    Clear(AttachmentTempBlob);
                end;
            until EventReportLayout.Next() = 0;
    end;
#ENDIF
    local procedure GetEmailAccount(var EmailAccount: Record "Email Account")
    var
        EventExchIntEMail: Record "NPR Event Exch. Int. E-Mail";
        EmailAccountCodeunit: Codeunit "Email Account";
        NoEmailAccountErr: Label 'Email Account %1 doesn''t exist. Please create it and try again.', Comment = '%1 = email';
        NoEmailAccountsErr: Label 'There are no Email Accounts created. First create Email Accounts';
    begin
        EmailAccountCodeunit.GetAllAccounts(false, EmailAccount);
        if EmailAccount.IsEmpty() then
            Error(NoEmailAccountsErr);

        EventEWSMgt.GetEventExchIntEmail(EventExchIntEMail);
        if EventExchIntEMail."E-Mail" <> '' then
            EmailAccount.SetFilter("Email Address", '@' + EventExchIntEMail."E-Mail");
        if not EmailAccount.FindFirst() then
            Error(NoEmailAccountErr, EventExchIntEMail."E-Mail");
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

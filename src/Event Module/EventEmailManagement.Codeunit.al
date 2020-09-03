codeunit 6060153 "NPR Event Email Management"
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.31/TJ  /20170330 CASE 269162 Using E-Mail Template Header field Filename for naming attachment
    //                                   Using same filename process for Subject in case e-mail template is not used
    //                                   Removed questions about attachment as it'll always be included in the e-mail
    //                                   Moved file name and layout functions to codeunit "Event EWS Management"
    // NPR5.32/TJ  /20170502 CASE 274405 Recoded check if attachment will be created
    //                                   Making an e-mail body only if there's a template defined
    // NPR5.32/TJ  /20170515 CASE 275946 Recoded how to authenticate and initialize exchange service
    // NPR5.34/TJ  /20170627 CASE 275991 Added new argument when calling function InitializeExchService
    // NPR5.34/TJ  /20170707 CASE 277938 Function UseTemplate moved to codeunit Event EWS Management and rewritten
    //                                   Most of code using fields from Jobs Setup that were removed is recoded to use new table Event Exch. Int. Template
    //                                   Fixed an error that record is pointing to old definition
    // NPR5.38/TJ  /20171026 CASE 285194 Changed code in EMailMessageSendAndSaveCopyWithLog
    //                                   Added arguments when calling function OrganizerAccountSet
    // NPR5.43/TJ  /20180322 CASE 262079 Adding ticket URLs to e-mail body
    // NPR5.45/TJ  /20180530 CASE 317448 Changed TryFunction property of function ProcessMailItem from Yes to default
    //                                   Adjusted other code to reflect TryFunction change
    // NPR5.55/TJ  /20200204 CASE 374887 Removed unnecessary record get
    //                                   Added parameter CalledFromFieldNo to function SendEmail
    //                                   Sending an e-mail without a template now triggers a confirmation
    //                                   Updated older not properly versioned code
    //                                   New functions SetEventExcIntTemplate and SetAskOnce


    trigger OnRun()
    begin
    end;

    var
        EventMgt: Codeunit "NPR Event Management";
        EventEWSMgt: Codeunit "NPR Event EWS Management";
        JobsSetup: Record "Jobs Setup";
        ConfirmSendMail: Label 'You''re about to send e-mail(s). Do you want to continue?';
        ConfirmIncludeAttach: Label 'Do you want to include %1 template in attachment?';
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
        //-NPR5.55 [374887]
        if EmailCounter = 0 then
            //+NPR5.55 [374887]
            if not Confirm(ConfirmSendMail) then
                exit;

        //-NPR5.55 [374887]
        EventEWSMgt.SetSkipLookup(CalledFromFieldNo <> 0);
        if CalledFromFieldNo = 0 then
            //+NPR5.55 [374887]
            if not EventEWSMgt.CheckStatus(Job, false) then
                if not Confirm(StrSubstNo(StatusWarning, Format(Job."NPR Event Status"))) then
                    exit;

        if MailFor = MailFor::Customer then
            Job.TestField("NPR Bill-to E-Mail");

        //-NPR5.55 [374887]
        if not UseTemplate then
            //+NPR5.55 [374887]
            //-NPR5.34 [277938]
            UseTemplate := EventEWSMgt.UseTemplate(Job, MailFor, 0, EventExchIntTemplate);
        //+NPR5.34 [277938]

        //-NPR5.55 [374887]
        if not UseTemplate then
            if not Confirm(NoEmailTemplate) then
                exit;
        //+NPR5.55 [374887]

        JobsSetup.Get();
        //-NPR5.38 [285194]
        //-NPR5.32 [275946]
        //EventEWSMgt.OrganizerAccountSet(Job);
        //EventEWSMgt.OrganizerAccountSet(Job,TRUE);
        //+NPR5.32 [275946]
        EventEWSMgt.OrganizerAccountSet(Job, true, true);
        //+NPR5.38 [285194]
        //-NPR5.31 [269162]
        /*
        IncludeAttachment := CONFIRM(STRSUBSTNO(ConfirmIncludeAttach,FORMAT(MailFor)));
        IF IncludeAttachment AND NOT CustomizedLayoutFound(Job,MailFor) THEN
          IF NOT ConfirmCreateBaseLayout() THEN
            EXIT;
        */

        //-NPR5.32 [274405]
        //EventEWSMgt.IncludeAttachmentCheck(Job,MailFor);
        if not EventEWSMgt.IncludeAttachmentCheck(Job, MailFor) then
            Error(NoReportLayout);
        //+NPR5.32 [274405]

        //+NPR5.31 [269162]

        RecRef.GetTable(Job);
        //-NPR5.32 [275946]
        /*
        Authenticated := EventEWSMgt.AuthenticateExchServWithLog(RecRef,ExchService,Job."No.");
        IF NOT Authenticated THEN
          Job."Mail Item Status" := Job."Mail Item Status"::Error
        ELSE BEGIN
        
        //-NPR5.31 [269162]
        //IF ProcessMailItemWithLog(RecRef,ExchService,MailFor,IncludeAttachment) THEN
        IF ProcessMailItemWithLog(RecRef,ExchService,MailFor) THEN
        //+NPR5.31 [269162]
        */
        //-NPR5.34 [277938]
        //IF ProcessMailItemWithLog(RecRef,MailFor) THEN
        Processed := ProcessMailItemWithLog(RecRef, MailFor);
        RecRef.SetTable(Job);
        //-NPR5.55 [374887]
        //Job.GET(Job."No.");
        //+NPR5.55 [374887]
        if Processed then
            //+NPR5.34 [277938]

            //+NPR5.32 [275946]
            Job."NPR Mail Item Status" := Job."NPR Mail Item Status"::Sent
        else
            Job."NPR Mail Item Status" := Job."NPR Mail Item Status"::Error;

        //-NPR5.32 [275946]
        //END;
        //+NPR5.32 [275946]
        //-NPR5.55 [374887]
        if CalledFromFieldNo = 0 then
            //+NPR5.55 [374887]
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

        //-NPR5.34 [277938]
        UseTemplate := EventEWSMgt.UseTemplate(Job, 1, 0, EventExchIntTemplate);
        //+NPR5.34 [277938]

        //-NPR5.38 [285194]
        //-NPR5.32 [275946]
        //EventEWSMgt.OrganizerAccountSet(Job);
        //EventEWSMgt.OrganizerAccountSet(Job,TRUE);
        //+NPR5.32 [275946]
        EventEWSMgt.OrganizerAccountSet(Job, true, true);
        //+NPR5.38 [285194]

        //-NPR5.31 [269162]
        /*
        IncludeAttachment := CONFIRM(STRSUBSTNO(ConfirmIncludeAttach,FORMAT(TeamTxt)));
        IF IncludeAttachment AND NOT CustomizedLayoutFound(Job,1) THEN
          IF NOT ConfirmCreateBaseLayout() THEN
            EXIT;
        */

        //-NPR5.32 [274405]
        //EventEWSMgt.IncludeAttachmentCheck(Job,1);
        if not EventEWSMgt.IncludeAttachmentCheck(Job, 1) then
            Error(NoReportLayout);
        //+NPR5.32 [274405]

        //+NPR5.31 [269162]

        RecRef.GetTable(JobPlanningLine);

        //-NPR5.32 [275946]
        /*
        Authenticated := EventEWSMgt.AuthenticateExchServWithLog(RecRef,ExchService,Job."No.");
        IF NOT Authenticated THEN
          JobPlanningLine."Mail Item Status" := JobPlanningLine."Mail Item Status"::Error
        ELSE BEGIN
        
        //-NPR5.31 [269162]
        //IF ProcessMailItemWithLog(RecRef,ExchService,1,IncludeAttachment) THEN
        IF ProcessMailItemWithLog(RecRef,ExchService,1) THEN
        //+NPR5.31 [269162]
        */
        if ProcessMailItemWithLog(RecRef, 1) then
            //+NPR5.32 [275946]
            JobPlanningLine."NPR Mail Item Status" := JobPlanningLine."NPR Mail Item Status"::Sent
        else
            JobPlanningLine."NPR Mail Item Status" := JobPlanningLine."NPR Mail Item Status"::Error;

        //-NPR5.32 [275946]
        //END;
        //+NPR5.32 [275946]

        JobPlanningLine.Modify;

    end;

    procedure ProcessMailItemWithLog(var RecRef: RecordRef; MailFor: Option Customer,Team): Boolean
    var
        ActivityLog: Record "Activity Log";
        ActivityDescription: Label 'Processing Mail Item...';
        SuccessfulMailItem: Label 'Successfully sent an e-mail.';
    begin
        //-NPR5.31 [269162]
        //IF NOT ProcessMailItem(RecRef,ExchService,MailFor,IncludeAttachment) THEN BEGIN
        //-NPR5.32 [275946]
        //IF NOT ProcessMailItem(RecRef,ExchService,MailFor) THEN BEGIN
        if not ProcessMailItem(RecRef, MailFor) then begin
            //+NPR5.32 [275946]
            //-NPR5.31 [269162]
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
        //-NPR5.32 [275946]
        //EmailMessage := EmailMessage.EmailMessage(ExchService);
        //+NPR5.32 [275946]

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

        //-NPR5.45 [317448]
        /*
        //-NPR5.34 [275991]
        //EventEWSMgt.InitializeExchService(RecRef.RECORDID,Job,ExchService);
        EventEWSMgt.InitializeExchService(RecRef.RECORDID,Job,ExchService,0);
        //+NPR5.34 [275991]
        */
        if not EventEWSMgt.InitializeExchService(RecRef.RecordId, Job, ExchService, 0) then
            exit(false);
        //+NPR5.45 [317448]
        EmailMessage := EmailMessage.EmailMessage(ExchService);
        //+NPR5.32 [275946]

        //-NPR5.31 [269162]
        /*
        JobsSetup.GET();
        CASE Job."Event Status" OF
          Job."Event Status"::Quote: UseTemplate := (JobsSetup."Quote Email Template Code" <> '') AND (EMailTemplateHeader.GET(JobsSetup."Quote Email Template Code"));
          Job."Event Status"::Order: UseTemplate := (JobsSetup."Order Email Template Code" <> '') AND (EMailTemplateHeader.GET(JobsSetup."Order Email Template Code"));
          Job."Event Status"::Cancelled: UseTemplate := (JobsSetup."Cancel Email Template Code" <> '') AND (EMailTemplateHeader.GET(JobsSetup."Cancel Email Template Code"));
        END;
        */
        //+NPR5.31 [269162]

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
        //-NPR5.32 [274405]
        //BodyText := '<font face="Calibri">';
        //+NPR5.32 [274405]

        //-NPR5.34 [277938]
        //-NPR5.31 [269162]
        //IF UseTemplate THEN BEGIN
        //IF UseTemplate(Job,EMailTemplateHeader) THEN BEGIN
        if UseTemplate and (EMailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code")) then begin
            //+NPR5.31 [269162]
            //+NPR5.34 [277938]

            RecRef2.GetTable(Job);
            EmailMessage.Subject := EventEWSMgt.ParseEmailTemplateText(RecRef2, EMailTemplateHeader.Subject);
            EMailTemplateLine.SetRange("E-mail Template Code", EMailTemplateHeader.Code);
            //-NPR5.32 [274405]
            //IF EMailTemplateLine.FINDSET THEN
            if EMailTemplateLine.FindSet then begin
                BodyText := '<font face="Calibri">';
                //+NPR5.32 [274405]
                repeat
                    //-NPR5.43 [262079]
                    //BodyText += EventEWSMgt.ParseEmailTemplateText(RecRef2,EMailTemplateLine."Mail Body Line") + '</br>';
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
                //+NPR5.43 [262079]
                until EMailTemplateLine.Next = 0;
                //-NPR5.32 [274405]
                BodyText += '</br></font>';
                EmailMessage.Body := MessageBody.MessageBody(BodyType.HTML, BodyText);
            end;
            //+NPR5.32 [274405]
        end else

            //-NPR5.31 [269162]
            //  EmailMessage.Subject := STRSUBSTNO(MailSubjectText,FORMAT(Job."Event Status"),Job."No.");
            //-NPR5.34 [277938]
            //EmailMessage.Subject := EventEWSMgt.CreateFileName(Job,1);
            EmailMessage.Subject := EventEWSMgt.CreateFileName(Job, EMailTemplateHeader);
        //+NPR5.34 [277938]
        //+NPR5.31 [269162]

        //-NPR5.32 [274405]
        //BodyText += MailBodyAddText + '</br></font>';
        //EmailMessage.Body := MessageBody.MessageBody(BodyType.HTML,BodyText);
        //+NPR5.32 [274405]

        //-NPR5.31 [269162]
        /*
        IF IncludeAttachment THEN BEGIN
          FileName := CreateFilePath(Job,FileMgt.ServerTempFileName('pdf'));
          IF CustomizedLayoutFound(Job,MailFor) THEN BEGIN
            EventWordLayout.GET(Job.RECORDID,MailFor + 1);
            EventMgt.MergeAndSaveWordLayout(EventWordLayout,1,FileName);
          END ELSE
            EventMgt.SaveReportAs(Job,MailFor,1,FileName);
          EmailMessage.Attachments.AddFileAttachment(FileName);
        END;
        */
        //-NPR5.34 [277938]
        //IF EventEWSMgt.CreateAttachment(Job,MailFor,1,FileName) THEN
        if EventEWSMgt.CreateAttachment(Job, MailFor, EMailTemplateHeader, FileName) then
            //+NPR5.34 [277938]
            EmailMessage.Attachments.AddFileAttachment(FileName);
        //+NPR5.31 [269162]

        //-NPR5.32 [275946]
        //EmailMessage.SendAndSaveCopy();
        if not EMailMessageSendAndSaveCopyWithLog(RecRef.RecordId, ExchService, EmailMessage, Job) then
            //-NPR5.45 [317448]
            //ERROR('');
            exit(false);
        //+NPR5.45 [317448]
        //-NPR5.55 [374887]
        /*
        IF RecRef.NUMBER = DATABASE::Job THEN
          RecRef.GET(Job.RECORDID);
        */
        //+NPR5.55 [374887]
        //+NPR5.32 [275946]
        FileMgt.DeleteServerFile(FileName);
        //-NPR5.45 [317448]
        exit(true);
        //+NPR5.45 [317448]

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
            //first we eliminate potential problem with wrong exchange server Url
            //-NPR5.38 [285194]
            //IF NOT EventEWSMgt.AutoDiscoverExchangeServiceWithLog(RecordId,ExchService,Job) THEN
            if not EventEWSMgt.AutoDiscoverExchangeServiceWithLog(RecordId, ExchService, Job, true) then
                //+NPR5.38 [285194]
                exit(false);
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
        //-NPR5.55 [374887]
        UseTemplate := true;
        EventExchIntTemplate := EventExchIntTemplateHere;
        //+NPR5.55 [374887]
    end;

    procedure SetAskOnce(EmailCounterHere: Integer)
    begin
        //-NPR5.55 [374887]
        EmailCounter := EmailCounterHere;
        //+NPR5.55 [374887]
    end;
}


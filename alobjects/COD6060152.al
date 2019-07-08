codeunit 6060152 "Event Calendar Management"
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.31/TJ  /20170406 CASE 269162 Added new function UseTemplate
    //                                   Attaching file to calendar item, since there's a problem with sending attachments for a meeting request created a workaround
    //                                   to first save/update empty/used calendar item and then update it with attachment
    // NPR5.32/TJ  /20170205 CASE 274405 Checking if report layout exists before making attachment
    // NPR5.32/TJ  /20170515 CASE 275946 Changed authentication to occur at requested action rather then upfront
    //                                   Also changed alot of code related to authentication and service initialization
    //                                   Testing Starting Date for appointment and Planning Date for meeting request as they are mandatory for calendar item creation
    // NPR5.32/TJ  /20170525 CASE 277974 Setting Show As on calendar items
    // NPR5.32/TJ  /20170525 CASE 275953 Changed when appointment is marked as All day event
    // NPR5.34/TJ  /20170707 CASE 277938 Function UseTemplate moved to codeunit Event EWS Management and rewritten
    //                                   Most of code using fields from Jobs Setup that were removed is recoded to use new table Event Exch. Int. Template
    // NPR5.34/TJ  /20170727 CASE 275991 Added extra argument when calling function InitializeExchService
    // NPR5.35/TJ  /20170822 CASE 281185 Reminder on calendar items is set based on exchange template
    // NPR5.35/TJ  /20170822 CASE 287798 E-mail address is not recognized if someone has changed letters to capital (or other way around) after invitation has been sent and before reponse has been fetched
    //                                   Reworked email recognition if several other email accounts are in attendee list
    // NPR5.36/TJ  /20170901 CASE 289046 New functions to check/remove calendar
    //                                   New subscriber to Job Planning Line - OnBeforeDelete
    // NPR5.36/TJ  /20170912 CASE 287800 Appointment can be created for first day only if needed
    // NPR5.38/TJ  /20171019 CASE 285194 Cleaned unused variable in function RemoveLineFromCalendar
    //                                   Added code to GetMsgDialogText
    //                                   Changed code in RunAppointmentItemMethodWithLog and JobOrganizerEmailOnAfterValidate
    //                                   Added arguments when calling function OrganizerAccountSet
    // NPR5.38/TJ  /20170102 CASE 299519 Additional requirements for sending meeting requests
    // NPR5.40/TJ  /20171128 CASE 296137 Reminder minutes need to be sent regardless of enabled property
    // NPR5.40/TJ  /20180301 CASE 306643 Fixed an issue when Both calendar items are sent and if there's no exchange template found, transaction error occurs regarding using Page.RUNMODAL
    // NPR5.45/TJ  /20180530 CASE 317448 Changed TryFunction property of function ProcessCalendarItem from Yes to default
    //                                   Adjusted other code to reflect TryFunction change
    // NPR5.46/TJ  /20180810 CASE 323953 Sent meeting request will be created in set timezone
    //                                   Fixed wrong return value when removing calendar item
    // NPR5.48/TJ  /20190130 CASE 342511 Moved template selection prior to calendar processing


    trigger OnRun()
    begin
    end;

    var
        JobsSetup: Record "Jobs Setup";
        EventMgt: Codeunit "Event Management";
        EventEWSMgt: Codeunit "Event EWS Management";
        CalendarTypeChoice: Label 'Appointment,Meeting Request,Both';
        CantFindCalendar: Label 'Couldn''t locate calendar item. You''ll need to create new one if it''s needed.';
        ErrorContext: Label 'ERROR';
        UseTemplateArr: array [2] of Boolean;
        EventExchIntTemplateArr: array [2] of Record "Event Exch. Int. Template";

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobOnAfterInsert(var Rec: Record Job;RunTrigger: Boolean)
    begin
        if not RunTrigger then
          exit;

        if not EventMgt.IsEventJob(Rec) then
          exit;

        Rec."Calendar Item ID" := '';
        Rec."Calendar Item Status" := Rec."Calendar Item Status"::" ";
        Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterModifyEvent', '', false, false)]
    local procedure JobOnAfterModify(var Rec: Record Job;var xRec: Record Job;RunTrigger: Boolean)
    var
        JobsSetup: Record "Jobs Setup";
        JobTask: Record "Job Task";
    begin
        if not RunTrigger then
          exit;

        if not EventMgt.IsEventJob(Rec) then
          exit;

        if not EventEWSMgt.CheckStatus(Rec,false) then
          exit;

        if Rec."Calendar Item Status" = xRec."Calendar Item Status" then
          //-NPR5.38 [285194]
          //-NPR5.32 [275946]
          //IF EventEWSMgt.GetOrganizerAccount(Rec) <> '' THEN BEGIN
          //IF EventEWSMgt.OrganizerAccountSet(Rec,FALSE) THEN BEGIN
          //+NPR5.32 [275946]
          if EventEWSMgt.OrganizerAccountSet(Rec,false,false) then begin
          //+NPR5.38 [285194]
            Rec."Calendar Item Status" := Rec."Calendar Item Status"::Send;
            Rec.Modify;
          end;
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'Organizer E-Mail', false, false)]
    local procedure JobOrganizerEmailOnAfterValidate(var Rec: Record Job;var xRec: Record Job;CurrFieldNo: Integer)
    var
        JobPlanningLine: Record "Job Planning Line";
        IntegrationEmailUsed: Label 'E-mail %1 is allready used for outlook integration. Current outlook items will not be moved to new e-mail account and you''ll have to manually do that. Do you want to continue?';
    begin
        if Rec."Organizer E-Mail" <> xRec."Organizer E-Mail" then begin
          JobPlanningLine.SetRange("Job No.",Rec."No.");
          JobPlanningLine.SetFilter("Calendar Item ID",'<>%1','');
          if (Rec."Calendar Item ID" <> '') or JobPlanningLine.FindFirst then
            if not Confirm(StrSubstNo(IntegrationEmailUsed,xRec."Organizer E-Mail")) then
              Error('');
          //-NPR5.38 [285194]
          //Rec."Organizer E-Mail Password" := '';
          //+NPR5.38 [285194]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobPlanningLineOnAfterInsert(var Rec: Record "Job Planning Line";RunTrigger: Boolean)
    var
        Job: Record Job;
    begin
        if not RunTrigger then
          exit;

        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
          exit;

        Rec."Calendar Item ID" := '';
        Rec."Calendar Item Status" := Rec."Calendar Item Status"::" ";
        Rec."Meeting Request Response" := Rec."Meeting Request Response"::" ";
        Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterModifyEvent', '', false, false)]
    local procedure JobPlanningLineOnAfterModify(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";RunTrigger: Boolean)
    var
        Job: Record Job;
    begin
        if not RunTrigger then
          exit;

        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
          exit;

        if not EventEWSMgt.CheckStatus(Job,false) then
          exit;

        if Rec."Calendar Item Status" = xRec."Calendar Item Status" then
          if (Rec.Type = Rec.Type::Resource) and (Rec."Resource E-Mail" <> '') then begin
            Rec."Calendar Item Status" := Rec."Calendar Item Status"::Send;
            Rec.Modify;
          end;
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure JobPlanningLineOnBeforeDelete(var Rec: Record "Job Planning Line";RunTrigger: Boolean)
    var
        Job: Record Job;
    begin
        //-NPR5.36 [289046]
        if not RunTrigger then
          exit;

        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
          exit;

        if CheckForCalendar(Rec,Rec) then
          if not ConfirmCalendarRemove(Rec) then
            Error('');
        //+NPR5.36 [289046]
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure JobPlanningLineNoOnAfterValidate(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";CurrFieldNo: Integer)
    var
        Resource: Record Resource;
    begin
        //-NPR5.36 [289046]
        /*
        IF Rec.Type = Rec.Type::Resource THEN BEGIN
          IF (Rec."No." <> xRec."No.") AND (Rec."Calendar Item ID" <> '') THEN
            IF CONFIRM(STRSUBSTNO(CancelConfirm,xRec."No.")) THEN
              RemoveLineFromCalendarAction(Rec,FALSE);
        END;
        */
        if Rec."No." <> xRec."No." then
          CheckForCalendarAndRemove(Rec,xRec);
        //+NPR5.36 [289046]

    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'Resource E-Mail', false, false)]
    local procedure JobPlanningLineResourceEMailOnAfterValidate(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";CurrFieldNo: Integer)
    begin
        //-NPR5.36 [289046]
        /*
        IF (Rec."Resource E-Mail" <> xRec."Resource E-Mail") AND (Rec."Calendar Item ID" <> '') THEN BEGIN
          IF CONFIRM(STRSUBSTNO(CancelConfirm,Rec."No.")) THEN
            RemoveLineFromCalendarAction(Rec,FALSE);
          Rec."Calendar Item Status" := Rec."Calendar Item Status"::Send;
        END;
        */
        if Rec."Resource E-Mail" <> xRec."Resource E-Mail" then
          if CheckForCalendar(Rec,xRec) then begin
            ConfirmCalendarRemove(Rec);
            Rec."Calendar Item Status" := Rec."Calendar Item Status"::Send;
          end;
        //+NPR5.36 [289046]

    end;

    procedure SendToCalendar(var Job: Record Job)
    var
        ChooseConfirm: Label 'Please choose type of calendar item keeping in mind that: %1 \ %2 \\ %3';
        AppointmentMsg: Label 'Appointments do not require atendees and single calendar item will be created for this event.';
        MeetingRequestMsg: Label 'Meeting Requests require attendees and a calendar item will be created for each resource line.';
        ExchService: DotNet ExchangeService;
        CalendarType: Option Appointment,MeetingRequest,Both;
        UpdateMsg: Label 'If selected calendar type is allready created it''ll be updated if required.';
        RecRef: RecordRef;
        Processed: Boolean;
    begin
        EventEWSMgt.CheckStatus(Job,true);
        
        CalendarType := StrMenu(CalendarTypeChoice,1,StrSubstNo(ChooseConfirm,AppointmentMsg,MeetingRequestMsg,UpdateMsg)) - 1;
        if CalendarType = -1 then
          exit;
        
        if CalendarType in [CalendarType::Appointment,CalendarType::Both] then
          Job.TestField("Calendar Item Status",Job."Calendar Item Status"::Send);
        
        JobsSetup.Get();
        //-NPR5.38 [285194]
        //-NPR5.32 [275946]
        //EventEWSMgt.OrganizerAccountSet(Job);
        //EventEWSMgt.OrganizerAccountSet(Job,TRUE);
        //+NPR5.32 [275946]
        EventEWSMgt.OrganizerAccountSet(Job,true,false);
        //+NPR5.38 [285194]
        RecRef.GetTable(Job);
        
        //-NPR5.32 [275946]
        //Authenticated := EventEWSMgt.AuthenticateExchServWithLog(RecRef,ExchService,Job."No.");
        //+NPR5.32 [275946]
        
        case CalendarType of
          CalendarType::Appointment,CalendarType::Both:
            begin
              //-NPR5.48 [342511]
              /*
              //-NPR5.32 [275946]
              IF CalendarType = CalendarType::Appointment THEN BEGIN
                Job.TESTFIELD("Starting Date");
                Job.TESTFIELD("Ending Date");
              //-NPR5.38 [299519]
              //END;
              END ELSE
                CheckMeetingReqMinReq(Job);
              */
              if CalendarType in [CalendarType::Appointment,CalendarType::Both] then begin
                Job.TestField("Starting Date");
                Job.TestField("Ending Date");
                GetExchTemplate(RecRef,1);
              end;
              if CalendarType in [CalendarType::MeetingRequest,CalendarType::Both] then begin
                CheckMeetingReqMinReq(Job);
                GetExchTemplate(RecRef,2);
              end;
              //+NPR5.48 [342511]
              //+NPR5.38 [299519]
              /*
              IF NOT Authenticated THEN
                Job."Calendar Item Status" := Job."Calendar Item Status"::Error
              ELSE IF ProcessCalendarItemWithLog(RecRef,ExchService,0,0,'',Job."Calendar Item ID") THEN
              */
              Processed := ProcessCalendarItemWithLog(RecRef,0,'');
              RecRef.SetTable(Job);
              Job.Get(Job."No.");
              if Processed then
              //+NPR5.32 [275946]
                Job."Calendar Item Status" := Job."Calendar Item Status"::Sent
              else
                Job."Calendar Item Status" := Job."Calendar Item Status"::Error;
              Job.Modify;
              //-NPR5.40 [306643]
              //COMMIT needs to be here as it separates two distinct processes, sending of an appointment and a meeting request
              //each of those processes has a template selection subprocess which requires user selection for exchange templates
              //can be recoded to show template selection before the transaction begins, so one template selection for an appointment and one for meeting request
              Commit;
              //+NPR5.40 [306643]
              if CalendarType = CalendarType::Both then
          //-NPR5.32 [275946]
          /*
                SendMultipleLinesToCalendar(Job,ExchService,Authenticated);
            END;
          CalendarType::MeetingRequest: SendMultipleLinesToCalendar(Job,ExchService,Authenticated);
          */
                SendMultipleLinesToCalendar(Job);
            end;
          CalendarType::MeetingRequest:
            begin
              //-NPR5.38 [299519]
              CheckMeetingReqMinReq(Job);
              //+NPR5.38 [299519]
              //-NPR5.48 [342511]
              GetExchTemplate(RecRef,2);
              //+NPR5.48 [342511]
              SendMultipleLinesToCalendar(Job);
            end;
          //+NPR5.32 [275946]
        end;

    end;

    local procedure SendMultipleLinesToCalendar(Job: Record Job)
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        //-NPR5.38 [299519]
        //EventEWSMgt.SetJobPlanLineFilter(Job,JobPlanningLine);
        SetJobPlanLineMeetingRequestSendFilter(Job,JobPlanningLine);
        //+NPR5.38 [299519]
        if JobPlanningLine.FindSet then
          repeat
            //-NPR5.38 [299519]
            /*
            IF JobPlanningLine."Calendar Item Status" = JobPlanningLine."Calendar Item Status"::Send THEN
              //-NPR5.32 [275946]
              //SendLineToCalendar(JobPlanningLine,ExchService,FALSE,FALSE,FALSE,Authenticated);
              SendLineToCalendar(JobPlanningLine,FALSE,FALSE,FALSE);
              //+NPR5.32 [275946]
            */
            SendLineToCalendar(JobPlanningLine,false,false,false,false);
            //+NPR5.38 [299519]
          until JobPlanningLine.Next = 0;

    end;

    procedure SendLineToCalendarAction(var JobPlanningLine: Record "Job Planning Line")
    var
        RecRef: RecordRef;
    begin
        //-NPR5.38 [299519]
        /*
        //-NPR5.32 [275946]
        //SendLineToCalendar(JobPlanningLine,ExchService,TRUE,TRUE,TRUE,FALSE);
        SendLineToCalendar(JobPlanningLine,TRUE,TRUE,TRUE);
        //+NPR5.32 [275946]
        */
        //-NPR5.48 [342511]
        RecRef.GetTable(JobPlanningLine);
        GetExchTemplate(RecRef,2);
        //+NPR5.48 [342511]
        SendLineToCalendar(JobPlanningLine,true,true,true,true);
        //+NPR5.38 [299519]

    end;

    local procedure SendLineToCalendar(var JobPlanningLine: Record "Job Planning Line";StatusCheckNeeded: Boolean;ResEMailCheck: Boolean;CalendarStatusCheck: Boolean;StartEndTimeCheck: Boolean): Boolean
    var
        Job: Record Job;
        RecRef: RecordRef;
        Processed: Boolean;
    begin
        Job.Get(JobPlanningLine."Job No.");
        JobsSetup.Get();
        //-NPR5.38 [285194]
        //-NPR5.32 [275946]
        //EventEWSMgt.OrganizerAccountSet(Job);
        //EventEWSMgt.OrganizerAccountSet(Job,TRUE);
        //+NPR5.32 [275946]
        EventEWSMgt.OrganizerAccountSet(Job,true,false);
        //+NPR5.38 [285194]
        if StatusCheckNeeded then
          EventEWSMgt.CheckStatus(Job,true);
        
        if ResEMailCheck then
          JobPlanningLine.TestField("Resource E-Mail");
        
        if CalendarStatusCheck then
          JobPlanningLine.TestField("Calendar Item Status",JobPlanningLine."Calendar Item Status"::Send);
        
        //-NPR5.38 [299519]
        if StartEndTimeCheck then begin
          JobPlanningLine.TestField("Starting Time");
          JobPlanningLine.TestField("Ending Time");
        end;
        //+NPR5.38 [299519]
        
        RecRef.GetTable(JobPlanningLine);
        //-NPR5.32 [275946]
        JobPlanningLine.TestField("Planning Date");
        
        /*
        IF NOT Authenticated THEN BEGIN
          Authenticated := EventEWSMgt.AuthenticateExchServWithLog(RecRef,ExchService,Job."No.");
          IF NOT Authenticated THEN
            JobPlanningLine."Calendar Item Status" := JobPlanningLine."Calendar Item Status"::Error;
        END;
        IF Authenticated THEN BEGIN
          IF ProcessCalendarItemWithLog(RecRef,ExchService,1,0,'',JobPlanningLine."Calendar Item ID") THEN
        */
          Processed := ProcessCalendarItemWithLog(RecRef,0,'');
          RecRef.SetTable(JobPlanningLine);
          JobPlanningLine.Get(JobPlanningLine."Job No.",JobPlanningLine."Job Task No.",JobPlanningLine."Line No.");
          if Processed then
        //+NPR5.32 [275946]
            JobPlanningLine."Calendar Item Status" := JobPlanningLine."Calendar Item Status"::Sent
          else
            JobPlanningLine."Calendar Item Status" := JobPlanningLine."Calendar Item Status"::Error;
          JobPlanningLine."Meeting Request Response" := JobPlanningLine."Meeting Request Response"::" ";
        //-NPR5.32 [275946]
        //END;
        //+NPR5.32 [275946]
        JobPlanningLine.Modify;
        exit(JobPlanningLine."Calendar Item Status" = JobPlanningLine."Calendar Item Status"::Sent);

    end;

    procedure RemoveFromCalendar(var Job: Record Job)
    var
        CancelConfirm: Label 'This will cancel appoinment/meeting request for this event. Do you want to continue?';
        CancelMsg: Text;
        JobPlanningLine: Record "Job Planning Line";
        NothingToRemoveMsg: Label 'There are no calendar items to remove.';
        RecRef: RecordRef;
        CalendarType: Option Appointment,MeetingRequest,Both;
        Processed: Boolean;
    begin
        if not Confirm(CancelConfirm) then
          exit;
        
        JobPlanningLine.SetRange("Job No.",Job."No.");
        JobPlanningLine.SetRange(Type,JobPlanningLine.Type::Resource);
        JobPlanningLine.SetFilter("Calendar Item ID",'<>%1','');
        
        case true of
          (Job."Calendar Item ID" = '') and JobPlanningLine.IsEmpty:
            Error(NothingToRemoveMsg);
          (Job."Calendar Item ID" <> '') and not JobPlanningLine.IsEmpty:
            begin
              CalendarType := StrMenu(CalendarTypeChoice,1) - 1;
              if CalendarType = -1 then
                exit;
            end;
          (Job."Calendar Item ID" = '') and not JobPlanningLine.IsEmpty:
            CalendarType := CalendarType::MeetingRequest;
          (Job."Calendar Item ID" <> '') and JobPlanningLine.IsEmpty:
            CalendarType := CalendarType::Appointment;
        end;
        
        CancelMsg := GetMsgDialogText();
        
        JobsSetup.Get();
        //-NPR5.38 [285194]
        //-NPR5.32 [275946]
        //EventEWSMgt.OrganizerAccountSet(Job);
        //EventEWSMgt.OrganizerAccountSet(Job,TRUE);
        //+NPR5.32 [275946]
        EventEWSMgt.OrganizerAccountSet(Job,true,false);
        //+NPR5.38 [285194]
        RecRef.GetTable(Job);
        //-NPR5.32 [275946]
        //Authenticated := EventEWSMgt.AuthenticateExchServWithLog(RecRef,ExchService,Job."No.");
        //+NPR5.32 [275946]
        JobPlanningLine.SetRange("Calendar Item ID");
        
        case CalendarType of
          CalendarType::Appointment,CalendarType::Both:
            begin
              //-NPR5.32 [275946]
              /*
              IF NOT Authenticated THEN
                Job."Calendar Item Status" := Job."Calendar Item Status"::Error
              ELSE IF ProcessCalendarItemWithLog(RecRef,ExchService,0,1,CancelMsg,Job."Calendar Item ID") THEN
              */
              Processed := ProcessCalendarItemWithLog(RecRef,1,CancelMsg);
              RecRef.SetTable(Job);
              Job.Get(Job."No.");
              if Processed then
              //+NPR5.32 [275946]
                Job."Calendar Item Status" := Job."Calendar Item Status"::Removed
              else
                Job."Calendar Item Status" := Job."Calendar Item Status"::Error;
              Job.Modify;
              if CalendarType = CalendarType::Both then
                //-NPR5.32 [275946]
                //RemoveMultipleLinesFromCalendar(JobPlanningLine,ExchService,CancelMsg,Authenticated);
                RemoveMultipleLinesFromCalendar(JobPlanningLine,CancelMsg);
                //+NPR5.32 [275946]
            end;
          //-NPR5.32 [275946]
          //CalendarType::MeetingRequest: RemoveMultipleLinesFromCalendar(JobPlanningLine,ExchService,CancelMsg,Authenticated);
          CalendarType::MeetingRequest:
            RemoveMultipleLinesFromCalendar(JobPlanningLine,CancelMsg);
          //+NPR5.32 [275946]
        end;

    end;

    local procedure RemoveMultipleLinesFromCalendar(var JobPlanningLine: Record "Job Planning Line";CancelMsg: Text)
    begin
        if JobPlanningLine.FindSet then
          repeat
            if JobPlanningLine."Calendar Item ID" <> '' then
              //-NPR5.32 [275946]
              //RemoveLineFromCalendar(JobPlanningLine,ExchService,FALSE,FALSE,CancelMsg,Authenticated);
              RemoveLineFromCalendar(JobPlanningLine,false,false,CancelMsg);
              //+NPR5.32 [275946]
          until JobPlanningLine.Next = 0;
    end;

    procedure RemoveLineFromCalendarAction(JobPlanningLine: Record "Job Planning Line";ConfirmNeeded: Boolean)
    begin
        //-NPR5.32 [275946]
        //RemoveLineFromCalendar(JobPlanningLine,ExchService,ConfirmNeeded,TRUE,'',FALSE);
        RemoveLineFromCalendar(JobPlanningLine,ConfirmNeeded,true,'');
        //+NPR5.32 [275946]
    end;

    procedure RemoveLineFromCalendar(var JobPlanningLine: Record "Job Planning Line";ConfirmNeeded: Boolean;CancelDialogNeeded: Boolean;CancelMsg: Text): Boolean
    var
        CancelConfirm: Label 'This will cancel a meeting request. Do you want to continue?';
        NothingToRemoveMsg: Label 'There are no calendar items to remove.';
        RecRef: RecordRef;
        Job: Record Job;
        Processed: Boolean;
    begin
        if ConfirmNeeded then
          if not Confirm(CancelConfirm) then
            exit;
        
        if JobPlanningLine."Calendar Item ID" = '' then
          Error(NothingToRemoveMsg);
        
        if CancelDialogNeeded then
          CancelMsg := GetMsgDialogText();
        
        RecRef.GetTable(JobPlanningLine);
        //-NPR5.32 [275946]
        /*
        IF NOT Authenticated THEN BEGIN
          JobsSetup.GET();
          Job.GET(JobPlanningLine."Job No.");
          EventEWSMgt.OrganizerAccountSet(Job);
          Authenticated := EventEWSMgt.AuthenticateExchServWithLog(RecRef,ExchService,Job."No.");
          IF NOT Authenticated THEN
            JobPlanningLine."Calendar Item Status" := JobPlanningLine."Calendar Item Status"::Error;
        END;
        IF Authenticated THEN
          IF ProcessCalendarItemWithLog(RecRef,ExchService,1,1,CancelMsg,JobPlanningLine."Calendar Item ID") THEN BEGIN
        */
          Processed := ProcessCalendarItemWithLog(RecRef,1,CancelMsg);
          RecRef.SetTable(JobPlanningLine);
          JobPlanningLine.Get(JobPlanningLine."Job No.",JobPlanningLine."Job Task No.",JobPlanningLine."Line No.");
          if Processed then begin
        //+NPR5.32 [275946]
            JobPlanningLine."Calendar Item Status" := JobPlanningLine."Calendar Item Status"::Removed;
            JobPlanningLine."Meeting Request Response" := JobPlanningLine."Meeting Request Response"::" ";
          end else
            JobPlanningLine."Calendar Item Status" := JobPlanningLine."Calendar Item Status"::Error;
        JobPlanningLine.Modify;
        exit(JobPlanningLine."Calendar Item Status" = JobPlanningLine."Calendar Item Status"::Removed);

    end;

    procedure ProcessCalendarItemWithLog(var RecRef: RecordRef;ActionToTake: Option Send,Remove;CancelMessage: Text): Boolean
    var
        ActivityLog: Record "Activity Log";
        ActivityDescription: Label 'Processing Calendar Item...';
        ActivityMessage: Text;
        SuccessfulCalendarItem: Label 'Successfully %1 calendar.';
        SentToTxt: Label 'sent to';
        RemovedFromTxt: Label 'removed from';
        NewContext: Text;
        RemoveContext: Label 'REMOVE';
        SendContext: Label 'SEND';
        ReasonContext: Label 'REASON';
    begin
        //-NPR5.32 [275946]
        //IF NOT ProcessCalendarItem(RecRef,ExchService,CalendarType,ActionToTake,OutlookItemID) THEN BEGIN
        if not ProcessCalendarItem(RecRef,ActionToTake) then begin
        //+NPR5.32 [275946]
          ActivityLog.LogActivity(RecRef.RecordId,1,ErrorContext,ActivityDescription,CopyStr(GetLastErrorText,1,MaxStrLen(ActivityLog."Activity Message")));
          exit(false);
        end;
        //-NPR5.32 [275946]
        RecRef.Get(RecRef.RecordId);
        //+NPR5.32 [275946]
        case ActionToTake of
          ActionToTake::Send:
            begin
              NewContext := SendContext;
              //-NPR5.32 [275946]
              //IF OutlookItemID <> '' THEN BEGIN
              if ProcessCalendarItemID(2,RecRef,'') <> '' then begin
              //+NPR5.32 [275946]
                ActivityMessage := StrSubstNo(SuccessfulCalendarItem,SentToTxt);
              end else begin
                ActivityLog.LogActivity(RecRef.RecordId,1,ErrorContext,ActivityDescription,CantFindCalendar);
                exit(false);
              end;
            end;
          ActionToTake::Remove:
            begin
              NewContext := RemoveContext;
              ActivityMessage := StrSubstNo(SuccessfulCalendarItem,RemovedFromTxt);
            end;
        end;

        ActivityLog.LogActivity(RecRef.RecordId,0,NewContext,ActivityDescription,ActivityMessage);
        if CancelMessage <> '' then
          ActivityLog.LogActivity(RecRef.RecordId,0,ReasonContext,'',CancelMessage);
        exit(true);
    end;

    procedure ProcessCalendarItem(var RecRef: RecordRef;ActionToTake: Option Send,Remove): Boolean
    var
        ExchService: DotNet ExchangeService;
        AppointmentItem: DotNet Appointment;
        ItemId: DotNet ItemId;
        MessageBody: DotNet MessageBody;
        BodyType: DotNet BodyType;
        TimeZoneInfo: DotNet TimeZoneInfo;
        StringList: DotNet StringList;
        BodyText: Text;
        Resource: Record Resource;
        EMailTemplateHeader: Record "E-mail Template Header";
        EMailTemplateLine: Record "E-mail Template Line";
        RecRef2: RecordRef;
        CommentLine: Record "Comment Line";
        CalendarItemID: Text;
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
        FileName: Text;
        FileMgt: Codeunit "File Management";
        LegacyFreeBusyStatus: DotNet LegacyFreeBusyStatus;
        UseTemplate: Boolean;
        EventExchIntTemplate: Record "Event Exch. Int. Template";
        EndingDate: Date;
        StartingTime: Time;
        EndingTime: Time;
        EventExchIntEmail: Record "Event Exch. Int. E-Mail";
        TimeZoneId: Text;
        ServerTimeZoneId: Text;
        TimeZone: Record "Time Zone";
        ServerOffSet: Duration;
        DateTimeWithOffSet: DateTime;
        SenderOffSet: Duration;
        DateTimeOffSet: DotNet DateTimeOffset;
        TimeSpan: DotNet TimeSpan;
        CustomOffSet: Duration;
    begin
        case RecRef.Number of
          //-NPR5.32 [275946]
          //DATABASE::Job: RecRef.SETTABLE(Job);
          DATABASE::Job:
            begin
              RecRef.SetTable(Job);
              CalendarItemID := Job."Calendar Item ID";
              //-NPR5.45 [317448]
              /*
              //-NPR5.34 [275991]
              EventEWSMgt.InitializeExchService(RecRef.RECORDID,Job,ExchService,1);
              //+NPR5.34 [275991]
              */
              if not EventEWSMgt.InitializeExchService(RecRef.RecordId,Job,ExchService,1) then
                exit(false);
              //+NPR5.45 [317448]
              //-NPR5.48 [342511]
              UseTemplate := UseTemplateArr[1];
              EventExchIntTemplate := EventExchIntTemplateArr[1];
              //+NPR5.48 [342511]
            end;
          //+NPR5.32 [275946]
          DATABASE::"Job Planning Line":
            begin
              RecRef.SetTable(JobPlanningLine);
              Job.Get(JobPlanningLine."Job No.");
              //-NPR5.32 [275946]
              CalendarItemID := JobPlanningLine."Calendar Item ID";
              //+NPR5.32 [275946]
              //-NPR5.45 [317448]
              /*
              //-NPR5.34 [275991]
              EventEWSMgt.InitializeExchService(RecRef.RECORDID,Job,ExchService,2);
              //+NPR5.34 [275991]
              */
              if not EventEWSMgt.InitializeExchService(RecRef.RecordId,Job,ExchService,2) then
                exit(false);
              //+NPR5.45 [317448]
              //-NPR5.48 [342511]
              UseTemplate := UseTemplateArr[2];
              EventExchIntTemplate := EventExchIntTemplateArr[2];
              //+NPR5.48 [342511]
            end;
        end;
        
        Clear(AppointmentItem);
        
        //-NPR5.32 [275946]
        //-NPR5.34 [275991]
        //EventEWSMgt.InitializeExchService(RecRef.RECORDID,Job,ExchService);
        //+NPR5.34 [275991]
        //+NPR5.32 [275946]
        
        AppointmentItem := AppointmentItem.Appointment(ExchService);
        //-NPR5.32 [275946]
        /*
        CASE CalendarType OF
          CalendarType::Appointment:
            CalendarItemID := Job."Calendar Item ID";
          CalendarType::MeetingRequest:
            CalendarItemID := JobPlanningLine."Calendar Item ID";
        END;
        */
        //+NPR5.32 [275946]
        
        if CalendarItemID <> '' then begin
          if not GetCalendarItem(CalendarItemID,ExchService,AppointmentItem) then begin
            //-NPR5.32 [275946]
            //OutlookItemID := '';
            ProcessCalendarItemID(0,RecRef,'');
            //+NPR5.32 [275946]
            //-NPR5.46 [323953]
            //EXIT;
            exit(true);
            //+NPR5.46 [323953]
          end;
          if ActionToTake = ActionToTake::Remove then begin
            //-NPR5.32 [275946]
            //AppointmentItem.Delete(DeleteMode.HardDelete,SendCancellationsMode.SendToAllAndSaveCopy);
            //OutlookItemID := '';
            if not RunAppointmentItemMethodWithLog(RecRef.RecordId,ExchService,AppointmentItem,Job,'Delete',0) then
              //-NPR5.45 [317448]
              //ERROR('');
              exit(false);
              //+NPR5.45 [317448]
            ProcessCalendarItemID(0,RecRef,'');
            //+NPR5.32 [275946]
            //-NPR5.46 [323953]
            //EXIT;
            exit(true);
            //+NPR5.46 [323953]
          end;
        end;
        
        //-NPR5.48 [342511]
        /*
        //-NPR5.34 [277938]
        CASE RecRef.NUMBER OF
          DATABASE::Job:
            UseTemplate := EventEWSMgt.UseTemplate(Job,1,1,EventExchIntTemplate);
          DATABASE::"Job Planning Line":
            UseTemplate := EventEWSMgt.UseTemplate(Job,1,2,EventExchIntTemplate);
        END;
        */
        //-NPR5.48 [342511]
        
        if UseTemplate then
          if not EMailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code") then
            Clear(EMailTemplateHeader);
        //+NPR5.34 [277938]
        
        //-NPR5.32 [274405]
        if EventEWSMgt.IncludeAttachmentCheck(Job,1) then
        //+NPR5.32 [274405]
        //-NPR5.31 [269162]
          //-NPR5.34 [277938]
          //IF EventEWSMgt.CreateAttachment(Job,1,2,FileName) THEN BEGIN
          if EventEWSMgt.CreateAttachment(Job,1,EMailTemplateHeader,FileName) then begin
          //+NPR5.34 [277938]
            if CalendarItemID <> '' then
              AppointmentItem.Attachments.Clear();
            AppointmentItem.Attachments.AddFileAttachment(FileName);
          end;
        
        //-NPR5.46 [323953]
        EventEWSMgt.GetEventExchIntEmail(EventExchIntEmail);
        TimeZoneInfo := TimeZoneInfo.Local;
        ServerTimeZoneId := TimeZoneInfo.Id;
        ApplySubstituteTimeZone(ServerTimeZoneId);
        TimeZoneId := ServerTimeZoneId;
        if EventExchIntEmail."Time Zone No." <> 0 then begin
          TimeZone.Get(EventExchIntEmail."Time Zone No.");
          if TimeZone.ID <> TimeZoneInfo.Id then
            TimeZoneId := TimeZone.ID;
        end;
        ApplySubstituteTimeZone(TimeZoneId);
        
        if EventExchIntEmail."Time Zone Custom Offset (Min)" <> 0 then
          CustomOffSet := TimeSpan.FromMinutes(EventExchIntEmail."Time Zone Custom Offset (Min)");
        
        TimeZoneInfo := TimeZoneInfo.FindSystemTimeZoneById(ServerTimeZoneId);
        ServerOffSet := TimeZoneInfo.GetUtcOffset(CurrentDateTime);
        TimeZoneInfo := TimeZoneInfo.FindSystemTimeZoneById(TimeZoneId);
        SenderOffSet := TimeZoneInfo.GetUtcOffset(CurrentDateTime);
        
        AppointmentItem.StartTimeZone := TimeZoneInfo.FindSystemTimeZoneById(TimeZoneId);
        AppointmentItem.EndTimeZone := TimeZoneInfo.FindSystemTimeZoneById(TimeZoneId);
        //+NPR5.46 [323953]
        
        //-NPR5.32 [274405]
        /*
        IF CalendarItemID <> '' THEN
          AppointmentItem.Update(ConflictResolutionMode.AlwaysOverwrite,SendInviteCancelMode.SendToNone)
        ELSE
          AppointmentItem.Save(SendInvitationsMode.SendToNone);
        */
        if CalendarItemID <> '' then begin
          if not RunAppointmentItemMethodWithLog(RecRef.RecordId,ExchService,AppointmentItem,Job,'Update',0) then
            //-NPR5.45 [317448]
            //ERROR('')
            exit(false);
            //+NPR5.45 [317448]
        end else
          if not RunAppointmentItemMethodWithLog(RecRef.RecordId,ExchService,AppointmentItem,Job,'Save',0) then
            //-NPR5.45 [317448]
            //ERROR('');
            exit(false);
            //+NPR5.45 [317448]
        //+NPR5.32 [274405]
        ItemId := AppointmentItem.Id;
        //-NPR5.32 [275946]
        //OutlookItemID := ItemId.UniqueId;
        //GetCalendarItem(OutlookItemID,ExchService,AppointmentItem);
        ProcessCalendarItemID(1,RecRef,ItemId.UniqueId);
        //+NPR5.32 [275946]
        
        /*
        IF JobsSetup."Calendar Template Code" <> '' THEN BEGIN
          EMailTemplateHeader.GET(JobsSetup."Calendar Template Code");
        */
        //-NPR5.34 [277938]
        //IF UseTemplate(EMailTemplateHeader) THEN BEGIN
        if UseTemplate and EMailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code") then begin
        //+NPR5.34 [277938]
        //+NPR5.31 [269162]
          RecRef2.GetTable(Job);
          AppointmentItem.Subject := EventEWSMgt.ParseEmailTemplateText(RecRef2,EMailTemplateHeader.Subject);
        end else
          AppointmentItem.Subject := Job.Description;
        
        //-NPR5.46 [323953]
        //AppointmentItem.StartTimeZone := TimeZoneInfo.Local; //EndTimeZone is automatically set with same value
        //+NPR5.46 [323953]
        
        //-NPR5.32 [275946]
        //CASE CalendarType OF
        //  CalendarType::Appointment:
        case RecRef.Number of
          DATABASE::Job:
        //+NPR5.32 [275946]
            begin
              //-NPR5.36 [287800]
              /*
              AppointmentItem.Start := TimeZoneInfo.ConvertTimeFromUtc(DATI2VARIANT(Job."Starting Date",Job."Starting Time"),TimeZoneInfo.Local);
              AppointmentItem."End" := TimeZoneInfo.ConvertTimeFromUtc(DATI2VARIANT(Job."Ending Date",Job."Ending Time"),TimeZoneInfo.Local);
              //-NPR5.34 [277938]
              //AppointmentItem.IsAllDayEvent := IsAllDayEvent(Job."Starting Date",Job."Ending Date",Job."Starting Time",Job."Ending Time");
              AppointmentItem.IsAllDayEvent := IsAllDayEvent(Job."Starting Date",Job."Ending Date",Job."Starting Time",Job."Ending Time",EventExchIntTemplate."Lasts Whole Day (Appointment)");
              //+NPR5.34 [277938]
              */
              EndingDate := Job."Ending Date";
              StartingTime := Job."Starting Time";
              EndingTime := Job."Ending Time";
              AppointmentItem.IsAllDayEvent := IsAllDayEvent(StartingTime,EndingTime,EventExchIntTemplate."Lasts Whole Day (Appointment)");
        
              if AppointmentItem.IsAllDayEvent then begin
                EndingDate := CalcDate('<1D>',EndingDate);
                StartingTime := 000000T;
                EndingTime := 000000T;
                if EventExchIntTemplate."First Day Only (Appointment)" then
                  EndingDate := CalcDate('<1D>',Job."Starting Date");
              end;
              //-NPR5.46 [323953]
              /*
              AppointmentItem.Start := TimeZoneInfo.ConvertTimeFromUtc(DATI2VARIANT(Job."Starting Date",StartingTime),TimeZoneInfo.Local);
              AppointmentItem."End" := TimeZoneInfo.ConvertTimeFromUtc(DATI2VARIANT(EndingDate,EndingTime),TimeZoneInfo.Local);
              */
              DateTimeWithOffSet := CreateDateTime(Job."Starting Date",StartingTime) + (ServerOffSet - SenderOffSet) + CustomOffSet;
              AppointmentItem.Start := DateTimeWithOffSet;
              DateTimeWithOffSet := CreateDateTime(EndingDate,EndingTime) + (ServerOffSet - SenderOffSet) + CustomOffSet;
              AppointmentItem."End" := DateTimeWithOffSet;
              //+NPR5.46 [323953]
              //+NPR5.36 [287800]
            end;
          //-NPR5.32 [275946]
          //CalendarType::MeetingRequest:
          DATABASE::"Job Planning Line":
          //+NPR5.32 [275946]
            begin
              //-NPR5.46 [323953]
              /*
              AppointmentItem.Start := TimeZoneInfo.ConvertTimeFromUtc(DATI2VARIANT(JobPlanningLine."Planning Date",JobPlanningLine."Starting Time"),TimeZoneInfo.Local);
              AppointmentItem."End" := TimeZoneInfo.ConvertTimeFromUtc(DATI2VARIANT(JobPlanningLine."Planning Date",JobPlanningLine."Ending Time"),TimeZoneInfo.Local);
              */
              DateTimeWithOffSet := CreateDateTime(JobPlanningLine."Planning Date",JobPlanningLine."Starting Time") + (ServerOffSet - SenderOffSet) + CustomOffSet;
              AppointmentItem.Start := DateTimeWithOffSet;
              DateTimeWithOffSet := CreateDateTime(JobPlanningLine."Planning Date",JobPlanningLine."Ending Time") + (ServerOffSet - SenderOffSet) + CustomOffSet;
              AppointmentItem."End" := DateTimeWithOffSet;
              //+NPR5.46 [323953]
              AppointmentItem.RequiredAttendees.Add(JobPlanningLine."Resource E-Mail");
            end;
        end;
        
        BodyText := '<font face="Calibri">';
        
        //-NPR5.31 [269162]
        /*
        IF JobsSetup."Calendar Template Code" <> '' THEN BEGIN
          EMailTemplateLine.SETRANGE("E-mail Template Code",JobsSetup."Calendar Template Code");
        */
        //-NPR5.34 [277938]
        //IF UseTemplate(EMailTemplateHeader) THEN BEGIN
        if UseTemplate and EMailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code") then begin
        //+NPR5.34 [277938]
          EMailTemplateLine.SetRange("E-mail Template Code",EMailTemplateHeader.Code);
        //-NPR5.31 [269162]
          if EMailTemplateLine.FindSet then
            repeat
              BodyText += EventEWSMgt.ParseEmailTemplateText(RecRef2,EMailTemplateLine."Mail Body Line") + '</br>';
            until EMailTemplateLine.Next = 0;
        end else
          BodyText += Job.FieldCaption("No.") + ': ' + Job."No." + '</br>' +
                      Job.FieldCaption(Description) + ': ' + Job.Description + '</br>';
        BodyText += '</br>';
        //-NPR5.34 [277938]
        //IF JobsSetup."Include Comments in Calendar" THEN BEGIN
        if UseTemplate and EventExchIntTemplate."Include Comments (Calendar)" then begin
        //+NPR5.34 [277938]
          CommentLine.SetRange("Table Name",CommentLine."Table Name"::Job);
          CommentLine.SetRange("No.",Job."No.");
          if CommentLine.FindSet then
            repeat
              BodyText += CommentLine.Comment + '</br>'
            until CommentLine.Next = 0;
        end;
        BodyText += '</font>';
        AppointmentItem.Body := MessageBody.MessageBody(BodyType.HTML,BodyText);
        
        //-NPR5.32 [277974]
        AppointmentItem.LegacyFreeBusyStatus := LegacyFreeBusyStatus.Tentative;
        
        //IF (Job.Status = Job.Status::Order) AND (JobsSetup."Calendar Confirmed Category" <> '') THEN BEGIN
        if Job.Status = Job.Status::Open then begin //NAV2017
          AppointmentItem.LegacyFreeBusyStatus := LegacyFreeBusyStatus.Busy;
          //-NPR5.34 [277938]
          //IF JobsSetup."Calendar Confirmed Category" <> '' THEN BEGIN
          if UseTemplate and (EventExchIntTemplate."Conf. Color Categ. (Calendar)" <> '') then begin
          //+NPR5.34 [277938]
        //+NPR5.32 [277974]
          StringList := AppointmentItem.Categories;
          //-NPR5.34 [277938]
          /*
          IF NOT StringList.Contains(JobsSetup."Calendar Confirmed Category") THEN
            AppointmentItem.Categories.Add(JobsSetup."Calendar Confirmed Category");
          */
          if not StringList.Contains(EventExchIntTemplate."Conf. Color Categ. (Calendar)") then
            AppointmentItem.Categories.Add(EventExchIntTemplate."Conf. Color Categ. (Calendar)");
          //+NPR5.34 [277938]
        //-NPR5.32 [277974]
          end;
        //+NPR5.32 [277974]
        end;
        
        //-NPR5.32 [275946]
        /*
        CASE CalendarType OF
        //-NPR5.31 [269162]
        {
          CalendarType::Appointment:
            IF CalendarItemID <> '' THEN
              AppointmentItem.Update(ConflictResolutionMode.AlwaysOverwrite)
            ELSE
              AppointmentItem.Save(SendInvitationsMode.SendToNone);
          CalendarType::MeetingRequest:
            IF CalendarItemID <> '' THEN
              AppointmentItem.Update(ConflictResolutionMode.AlwaysOverwrite,SendInviteCancelMode.SendToAllAndSaveCopy)
            ELSE
              AppointmentItem.Save(SendInvitationsMode.SendToAllAndSaveCopy);
        }
          CalendarType::Appointment:
            AppointmentItem.Update(ConflictResolutionMode.AlwaysOverwrite);
          CalendarType::MeetingRequest:
            AppointmentItem.Update(ConflictResolutionMode.AlwaysOverwrite,SendInviteCancelMode.SendToAllAndSaveCopy);
        //+NPR5.31 [269162]
        END;
        */
        //-NPR5.35 [281185]
        if UseTemplate then begin
          AppointmentItem.IsReminderSet := EventExchIntTemplate."Reminder Enabled (Calendar)";
          //-NPR5.40 [296137]
          //IF EventExchIntTemplate."Reminder Enabled (Calendar)" THEN
          //+NPR5.40 [296137]
            AppointmentItem.ReminderMinutesBeforeStart := EventExchIntTemplate."Reminder (Minutes) (Calendar)";
        end;
        //+NPR5.35 [281185]
        case RecRef.Number of
          DATABASE::Job:
            begin
              if not RunAppointmentItemMethodWithLog(RecRef.RecordId,ExchService,AppointmentItem,Job,'Update',0) then
                //-NPR5.45 [317448]
                //ERROR('');
                exit(false);
                //+NPR5.45 [317448]
              RecRef.Get(Job.RecordId);
            end;
          DATABASE::"Job Planning Line":
            if not RunAppointmentItemMethodWithLog(RecRef.RecordId,ExchService,AppointmentItem,Job,'Update',1) then
              //-NPR5.45 [317448]
              //ERROR('');
              exit(false);
              //+NPR5.45 [317448]
        end;
        //+NPR5.32 [275946]
        
        //-NPR5.31 [269162]
        FileMgt.DeleteServerFile(FileName);
        /*
        ItemId := AppointmentItem.Id;
        OutlookItemID := ItemId.UniqueId;
        */
        //+NPR5.31 [269162]
        //-NPR5.45 [317448]
        exit(true);
        //+NPR5.45 [317448]

    end;

    [TryFunction]
    local procedure GetCalendarItem(CalendarItemID: Text;ExchService: DotNet ExchangeService;var AppointmentItem: DotNet Appointment)
    var
        ItemId: DotNet ItemId;
        PropertySet: DotNet PropertySet;
    begin
        Clear(ItemId);
        ItemId := ItemId.ItemId(CalendarItemID);
        AppointmentItem := AppointmentItem.Bind(ExchService,ItemId);
    end;

    procedure GetCalendarAttendeeResponses(Job: Record Job)
    var
        RecRef: RecordRef;
        JobPlanningLine: Record "Job Planning Line";
    begin
        EventEWSMgt.CheckStatus(Job,true);
        
        JobsSetup.Get();
        //-NPR5.38 [285194]
        //-NPR5.32 [275946]
        //EventEWSMgt.OrganizerAccountSet(Job);
        //EventEWSMgt.OrganizerAccountSet(Job,TRUE);
        //+NPR5.32 [275946]
        EventEWSMgt.OrganizerAccountSet(Job,true,false);
        //+NPR5.38 [285194]
        RecRef.GetTable(Job);
        //-NPR5.32 [275946]
        /*
        Authenticated := EventEWSMgt.AuthenticateExchServWithLog(RecRef,ExchService,Job."No.");
        IF NOT Authenticated THEN
          Job."Calendar Item Status" := Job."Calendar Item Status"::Error
        ELSE BEGIN
        */
        //+NPR5.32 [275946]
        EventEWSMgt.SetJobPlanLineFilter(Job,JobPlanningLine);
        if JobPlanningLine.FindSet then
          repeat
            //-NPR5.32 [275946]
            //GetCalendarAttendeeResponse(JobPlanningLine,ExchService,Authenticated)
            GetCalendarAttendeeResponse(JobPlanningLine);
            //+NPR5.32 [275946]
          until JobPlanningLine.Next = 0;
        //-NPR5.32 [275946]
        //END;
        //+NPR5.32 [275946]

    end;

    procedure GetCalendarAttendeeResponseAction(var JobPlanningLine: Record "Job Planning Line")
    var
        ExchService: DotNet ExchangeService;
    begin
        //-NPR5.32 [275946]
        //GetCalendarAttendeeResponse(JobPlanningLine,ExchService,FALSE);
        GetCalendarAttendeeResponse(JobPlanningLine);
        //+NPR5.32 [275946]
    end;

    procedure GetCalendarAttendeeResponse(var JobPlanningLine: Record "Job Planning Line"): Boolean
    var
        Job: Record Job;
        RecRef: RecordRef;
        Response: Text;
        ResponseType: DotNet MeetingResponseType;
    begin
        Job.Get(JobPlanningLine."Job No.");
        EventEWSMgt.CheckStatus(Job,true);
        
        if JobPlanningLine."Calendar Item ID" = '' then
          exit(false);
        
        JobsSetup.Get();
        //-NPR5.38 [285194]
        //-NPR5.32 [275946]
        //EventEWSMgt.OrganizerAccountSet(Job);
        //EventEWSMgt.OrganizerAccountSet(Job,TRUE);
        //+NPR5.32 [275946]
        EventEWSMgt.OrganizerAccountSet(Job,true,false);
        //+NPR5.38 [285194]
        RecRef.GetTable(JobPlanningLine);
        //-NPR5.32 [275946]
        /*
        IF NOT Authenticated THEN BEGIN
          Authenticated := EventEWSMgt.AuthenticateExchServWithLog(RecRef,ExchService,Job."No.");
          IF NOT Authenticated THEN
            JobPlanningLine."Calendar Item Status" := JobPlanningLine."Calendar Item Status"::Error
        END;
        IF Authenticated THEN BEGIN
          IF NOT ProcessAttendeeReponseWithLog(JobPlanningLine,ExchService,Response) THEN BEGIN
        */
          if not ProcessAttendeeReponseWithLog(JobPlanningLine,Response) then begin
        //+NPR5.32 [275946]
            JobPlanningLine."Calendar Item Status" := JobPlanningLine."Calendar Item Status"::Error;
            JobPlanningLine."Meeting Request Response" := JobPlanningLine."Meeting Request Response"::" ";
          end else begin
            case Response of
              ResponseType.Unknown.ToString():
                JobPlanningLine."Meeting Request Response" := JobPlanningLine."Meeting Request Response"::Unknown;
              ResponseType.Organizer.ToString():
                JobPlanningLine."Meeting Request Response" := JobPlanningLine."Meeting Request Response"::Organizer;
              ResponseType.Tentative.ToString():
                JobPlanningLine."Meeting Request Response" := JobPlanningLine."Meeting Request Response"::Tentative;
              ResponseType.Accept.ToString():
                JobPlanningLine."Meeting Request Response" := JobPlanningLine."Meeting Request Response"::Accepted;
              ResponseType.Decline.ToString():
                JobPlanningLine."Meeting Request Response" := JobPlanningLine."Meeting Request Response"::Declined;
              ResponseType.NoResponseReceived.ToString():
                JobPlanningLine."Meeting Request Response" := JobPlanningLine."Meeting Request Response"::"No Response";
            end;
            JobPlanningLine."Calendar Item Status" := JobPlanningLine."Calendar Item Status"::Received;
          end;
        //-NPR5.32 [275946]
        //END;
        //+NPR5.32 [275946]
        JobPlanningLine.Modify;
        exit(JobPlanningLine."Calendar Item Status" = JobPlanningLine."Calendar Item Status"::Received);

    end;

    procedure ProcessAttendeeReponseWithLog(var JobPlanningLine: Record "Job Planning Line";var Response: Text): Boolean
    var
        ResponseContext: Label 'RESPONSE';
        ActivityDescription: Label 'Getting Response..';
        SuccessfullResponse: Label 'Response obtained: %1';
        ActivityLog: Record "Activity Log";
    begin
        //-NPR5.32 [275946]
        //IF NOT ProcessAttendeeResponse(JobPlanningLine,ExchService,Response) THEN BEGIN
        if not ProcessAttendeeResponse(JobPlanningLine,Response) then begin
        //+NPR5.32 [275946]
          ActivityLog.LogActivity(JobPlanningLine.RecordId,1,ResponseContext,ActivityDescription,CopyStr(GetLastErrorText,1,MaxStrLen(ActivityLog."Activity Message")));
          exit(false);
        end;
        if JobPlanningLine."Calendar Item ID" = '' then begin
          ActivityLog.LogActivity(JobPlanningLine.RecordId,1,ErrorContext,ActivityDescription,CantFindCalendar);
          exit(false);
        end;
        ActivityLog.LogActivity(JobPlanningLine.RecordId,0,ResponseContext,ActivityDescription,StrSubstNo(SuccessfullResponse,Response));
        exit(true);
    end;

    [TryFunction]
    procedure ProcessAttendeeResponse(var JobPlanningLine: Record "Job Planning Line";var Response: Text)
    var
        ExchService: DotNet ExchangeService;
        AppointmentItem: DotNet Appointment;
        Attendee: DotNet Attendee;
        i: Integer;
        CantFindEmailError: Label 'No calendar requests have been sent to this e-mail %1. Please resend the request.';
        Job: Record Job;
        j: Integer;
    begin
        Clear(AppointmentItem);
        //-NPR5.32 [275946]
        Job.Get(JobPlanningLine."Job No.");
        //-NPR5.34 [275991]
        //EventEWSMgt.InitializeExchService(JobPlanningLine.RECORDID,Job,ExchService);
        EventEWSMgt.InitializeExchService(JobPlanningLine.RecordId,Job,ExchService,2);
        //+NPR5.34 [275991]
        //+NPR5.32 [275946]
        AppointmentItem := AppointmentItem.Appointment(ExchService);
        if not GetCalendarItem(JobPlanningLine."Calendar Item ID",ExchService,AppointmentItem) then begin
          JobPlanningLine."Calendar Item ID" := '';
          exit;
        end;
        if AppointmentItem.RequiredAttendees.Count() = 0 then
          exit;
        //-NPR5.35 [287798]
        i := -1;
        j := -1;
        //+NPR5.35 [287798]
        foreach Attendee in AppointmentItem.RequiredAttendees do begin
          //-NPR5.35 [287798]
          /*
          IF Attendee.Address <> JobPlanningLine."Resource E-Mail" THEN
            i += 1;
          */
          i += 1;
          if LowerCase(Attendee.Address) = LowerCase(JobPlanningLine."Resource E-Mail") then
            j := i;
          //+NPR5.35 [287798]
        end;
        //-NPR5.35 [287798]
        //IF i > AppointmentItem.RequiredAttendees.Count() THEN
        if j = -1 then
        //+NPR5.35 [287798]
          Error(CantFindEmailError,JobPlanningLine."Resource E-Mail");
        //-NPR5.35 [287798]
        //Response := AppointmentItem.RequiredAttendees.Item(i).ResponseType.ToString();
        Response := AppointmentItem.RequiredAttendees.Item(j).ResponseType.ToString();
        //+NPR5.35 [287798]

    end;

    local procedure GetMsgDialogText(): Text
    var
        EventStdDialog: Page "Event Standard Dialog";
    begin
        //-NPR5.38 [285194]
        EventStdDialog.UseForMessage();
        //+NPR5.38 [285194]
        if EventStdDialog.RunModal = ACTION::OK then
          exit(EventStdDialog.GetMessage());
        exit('');
    end;

    local procedure IsAllDayEvent(StartTime: Time;EndTime: Time;LastsWholeDay: Boolean): Boolean
    begin
        //-NPR5.32 [275953]
        //-NPR5.34 [277938]
        //IF JobsSetup."Appointment Lasts Whole Day" THEN
        if LastsWholeDay then
        //+NPR5.34 [277938]
          exit(true);
        //+NPR5.32 [275953]

        //-NPR5.36 [287800]
        //EXIT((StartDate = EndDate) AND (StartTime = 0T) AND (EndTime = 0T));
        exit((StartTime = 0T) and (EndTime = 0T));
        //+NPR5.36 [287800]
    end;

    local procedure ProcessCalendarItemID("Action": Option Reset,Assign,Get;var RecRef: RecordRef;CalendarID: Text): Text
    var
        FieldRef: FieldRef;
        FieldNo2: Integer;
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
    begin
        case RecRef.Number of
          DATABASE::Job:
            FieldNo2 := Job.FieldNo("Calendar Item ID");
          DATABASE::"Job Planning Line":
            FieldNo2 := JobPlanningLine.FieldNo("Calendar Item ID");
        end;
        FieldRef := RecRef.Field(FieldNo2);
        case Action of
          Action::Reset,Action::Assign:
            begin
              FieldRef.Value(CalendarID);
              RecRef.Modify;
            end;
          Action::Get:
            exit(Format(FieldRef));
        end;
    end;

    local procedure RunAppointmentItemMethodWithLog(RecordId: RecordID;ExchService: DotNet ExchangeService;var AppointmentItem: DotNet Appointment;var Job: Record Job;MethodName: Text;SendMode: Integer): Boolean
    var
        ActivityLog: Record "Activity Log";
        Context: Text;
        ActivityDescription: Text;
    begin
        if not RunAppointmentItemMethod(AppointmentItem,MethodName,SendMode,Context,ActivityDescription) then begin
          //-NPR5.38 [285194]
          //IF NOT EventEWSMgt.AutoDiscoverExchangeServiceWithLog(RecordId,ExchService,Job) THEN
          if not EventEWSMgt.AutoDiscoverExchangeServiceWithLog(RecordId,ExchService,Job,true) then
          //+NPR5.38 [285194]
            exit(false);
          if not RunAppointmentItemMethod(AppointmentItem,MethodName,SendMode,Context,ActivityDescription) then begin
            ActivityLog.LogActivity(RecordId,1,Context,ActivityDescription,CopyStr(GetLastErrorText,1,MaxStrLen(ActivityLog."Activity Message")));
            exit(false);
          end;
        end;
        exit(true);
    end;

    local procedure RunAppointmentItemMethod(var AppointmentItem: DotNet Appointment;MethodName: Text;SendMode: Integer;var Context: Text;var ActivityDescription: Text): Boolean
    var
        DeleteContext: Label 'DELETE';
        DeleteDescription: Label 'Removing calendar item...';
        SaveContext: Label 'SAVE';
        SaveDescription: Label 'Saving calendar item...';
        UpdateContext: Label 'UPDATE';
        UpdateDescription: Label 'Updating calendar item...';
    begin
        case MethodName of
          'Delete':
            begin
              Context := DeleteContext;
              ActivityDescription := DeleteDescription;
              exit(AppointmentItemDelete(AppointmentItem));
            end;
          'Save':
            begin
              Context := SaveContext;
              ActivityDescription := SaveDescription;
              exit(AppointmentItemSave(AppointmentItem));
            end;
          'Update':
            begin
              Context := UpdateContext;
              ActivityDescription := UpdateDescription;
              exit(AppointmentItemUpdate(AppointmentItem,SendMode));
            end;
        end;
    end;

    [TryFunction]
    local procedure AppointmentItemDelete(var AppointmentItem: DotNet Appointment)
    var
        DeleteMode: DotNet DeleteMode;
        SendCancellationsMode: DotNet SendCancellationsMode;
    begin
        AppointmentItem.Delete(DeleteMode.HardDelete,SendCancellationsMode.SendToAllAndSaveCopy);
    end;

    [TryFunction]
    local procedure AppointmentItemSave(var AppointmentItem: DotNet Appointment)
    var
        SendInvitationsMode: DotNet SendInvitationsMode;
    begin
        AppointmentItem.Save(SendInvitationsMode.SendToNone);
    end;

    [TryFunction]
    local procedure AppointmentItemUpdate(var AppointmentItem: DotNet Appointment;SendMode: Option "None",AllAndSendCopy)
    var
        ConflictResolutionMode: DotNet ConflictResolutionMode;
        SendInviteCancelMode: DotNet SendInvitationsOrCancellationsMode;
    begin
        case SendMode of
          SendMode::None:
            AppointmentItem.Update(ConflictResolutionMode.AlwaysOverwrite,SendInviteCancelMode.SendToNone);
          SendMode::AllAndSendCopy:
            AppointmentItem.Update(ConflictResolutionMode.AlwaysOverwrite,SendInviteCancelMode.SendToAllAndSaveCopy);
        end;
    end;

    procedure CheckForCalendarAndRemove(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line"): Boolean
    begin
        if CheckForCalendar(Rec,xRec) then
          exit(ConfirmCalendarRemove(Rec));
        exit(false);
    end;

    procedure CheckForCalendar(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line"): Boolean
    begin
        exit((xRec.Type = xRec.Type::Resource) and (Rec."Calendar Item ID" <> ''));
    end;

    procedure ConfirmCalendarRemove(var Rec: Record "Job Planning Line"): Boolean
    var
        CancelConfirm: Label 'There is a scheduled meeting request for %1. Do you want to automatically cancel that meeting and send an update to %1?';
    begin
        if Confirm(StrSubstNo(CancelConfirm,Rec."No.")) then
          exit(RemoveLineFromCalendar(Rec,false,false,''));
        exit(false);
    end;

    procedure SetJobPlanLineMeetingRequestSendFilter(Job: Record Job;var JobPlanningLine: Record "Job Planning Line")
    begin
        EventEWSMgt.SetJobPlanLineFilter(Job,JobPlanningLine);
        JobPlanningLine.SetRange("Calendar Item Status",JobPlanningLine."Calendar Item Status"::Send);
        JobPlanningLine.SetFilter("Starting Time",'<>%1',0T);
        JobPlanningLine.SetFilter("Ending Time",'<>%1',0T);
    end;

    local procedure CheckMeetingReqMinReq(Job: Record Job)
    var
        JobPlanningLine: Record "Job Planning Line";
        ResourceLinesNotSetCorrectlyErr: Label 'Meeting Requests can''t be sent as there are no %1 with minimum requirements. These are: %2 = %3 and filled %4 and %5.';
    begin
        SetJobPlanLineMeetingRequestSendFilter(Job,JobPlanningLine);
        if JobPlanningLine.IsEmpty then
          Error(ResourceLinesNotSetCorrectlyErr,JobPlanningLine.TableCaption,
                                                JobPlanningLine.FieldCaption("Calendar Item Status"),
                                                Format(JobPlanningLine."Calendar Item Status"::Send),
                                                JobPlanningLine.FieldCaption("Starting Time"),
                                                JobPlanningLine.FieldCaption("Ending Time"));
    end;

    local procedure ApplySubstituteTimeZone(var TimeZoneId: Text)
    var
        TimeZone: Record "Time Zone";
    begin
        //-NPR5.46 [323953]
        //some timezones have different types between .NET and EWS and error occurs
        //one of those is Russian Standard Time
        //quickest workaround is to use other timezones of same offset
        TimeZone.SetRange(ID,TimeZoneId);
        if TimeZone.FindFirst then
          case TimeZone.ID of
            'Russian Standard Time':
              TimeZoneId := 'Belarus Standard Time';
          end;
        //+NPR5.46 [323953]
    end;

    local procedure GetExchTemplate(RecRef: RecordRef;CalendarType: Integer)
    var
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
    begin
        //-NPR5.48 [342511]
        //CalendarType: 1 = Appointment, 2 = Meeting Request
        case RecRef.Number of
          DATABASE::Job:
            begin
              RecRef.SetTable(Job);
            end;
          DATABASE::"Job Planning Line":
            begin
              RecRef.SetTable(JobPlanningLine);
              Job.Get(JobPlanningLine."Job No.");
            end;
        end;
        UseTemplateArr[CalendarType] := EventEWSMgt.UseTemplate(Job,1,CalendarType,EventExchIntTemplateArr[CalendarType]);
        //+NPR5.48 [342511]
    end;
}


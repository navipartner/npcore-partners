codeunit 6060152 "NPR Event Calendar Mgt."
{
    var
        JobsSetup: Record "Jobs Setup";
        EventMgt: Codeunit "NPR Event Management";
        EventEWSMgt: Codeunit "NPR Event EWS Management";
        CalendarTypeChoice: Label 'Appointment,Meeting Request,Both';
        CantFindCalendar: Label 'Couldn''t locate calendar item. You''ll need to create new one if it''s needed.';
        ErrorContext: Label 'ERROR';
        UseTemplateArr: array[2] of Boolean;
        EventExchIntTemplateArr: array[2] of Record "NPR Event Exch. Int. Template";

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterInsertEvent', '', false, false)]
    local procedure JobOnAfterInsert(var Rec: Record Job; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        if not EventMgt.IsEventJob(Rec) then
            exit;

        Rec."NPR Calendar Item ID" := '';
        Rec."NPR Calendar Item Status" := Rec."NPR Calendar Item Status"::" ";
        Rec.Modify();
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterModifyEvent', '', false, false)]
    local procedure JobOnAfterModify(var Rec: Record Job; var xRec: Record Job; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        if not EventMgt.IsEventJob(Rec) then
            exit;

        if not EventEWSMgt.CheckStatus(Rec, false) then
            exit;

        if Rec."NPR Calendar Item Status" = xRec."NPR Calendar Item Status" then
            if EventEWSMgt.OrganizerAccountSet(Rec, false, false) then begin
                Rec."NPR Calendar Item Status" := Rec."NPR Calendar Item Status"::Send;
                Rec.Modify();
            end;
    end;

    [EventSubscriber(ObjectType::Table, 167, 'OnAfterValidateEvent', 'NPR Organizer E-Mail', false, false)]
    local procedure JobOrganizerEmailOnAfterValidate(var Rec: Record Job; var xRec: Record Job; CurrFieldNo: Integer)
    var
        JobPlanningLine: Record "Job Planning Line";
        IntegrationEmailUsed: Label 'E-mail %1 is allready used for outlook integration. Current outlook items will not be moved to new e-mail account and you''ll have to manually do that. Do you want to continue?';
    begin
        if Rec."NPR Organizer E-Mail" <> xRec."NPR Organizer E-Mail" then begin
            JobPlanningLine.SetRange("Job No.", Rec."No.");
            JobPlanningLine.SetFilter("NPR Calendar Item ID", '<>%1', '');
            if (Rec."NPR Calendar Item ID" <> '') or JobPlanningLine.FindFirst() then
                if not Confirm(StrSubstNo(IntegrationEmailUsed, xRec."NPR Organizer E-Mail")) then
                    Error('');
        end;
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

        Rec."NPR Calendar Item ID" := '';
        Rec."NPR Calendar Item Status" := Rec."NPR Calendar Item Status"::" ";
        Rec."NPR Meeting Request Response" := Rec."NPR Meeting Request Response"::" ";
        Rec.Modify();
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterModifyEvent', '', false, false)]
    local procedure JobPlanningLineOnAfterModify(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; RunTrigger: Boolean)
    var
        Job: Record Job;
    begin
        if not RunTrigger then
            exit;

        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
            exit;

        if not EventEWSMgt.CheckStatus(Job, false) then
            exit;

        if Rec."NPR Calendar Item Status" = xRec."NPR Calendar Item Status" then
            if (Rec.Type = Rec.Type::Resource) and (Rec."NPR Resource E-Mail" <> '') then begin
                Rec."NPR Calendar Item Status" := Rec."NPR Calendar Item Status"::Send;
                Rec.Modify();
            end;
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnBeforeDeleteEvent', '', false, false)]
    local procedure JobPlanningLineOnBeforeDelete(var Rec: Record "Job Planning Line"; RunTrigger: Boolean)
    var
        Job: Record Job;
    begin
        if not RunTrigger then
            exit;

        Job.Get(Rec."Job No.");
        if not EventMgt.IsEventJob(Job) then
            exit;

        if CheckForCalendar(Rec, Rec) then
            if not ConfirmCalendarRemove(Rec) then
                Error('');
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure JobPlanningLineNoOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        if Rec."No." <> xRec."No." then
            CheckForCalendarAndRemove(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'NPR Resource E-Mail', false, false)]
    local procedure JobPlanningLineResourceEMailOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    begin
        if Rec."NPR Resource E-Mail" <> xRec."NPR Resource E-Mail" then
            if CheckForCalendar(Rec, xRec) then begin
                ConfirmCalendarRemove(Rec);
                Rec."NPR Calendar Item Status" := Rec."NPR Calendar Item Status"::Send;
            end;
    end;

    procedure SendToCalendar(var Job: Record Job)
    var
        ChooseConfirm: Label 'Please choose type of calendar item keeping in mind that: %1 \ %2 \\ %3';
        AppointmentMsg: Label 'Appointments do not require atendees and single calendar item will be created for this event.';
        MeetingRequestMsg: Label 'Meeting Requests require attendees and a calendar item will be created for each resource line.';
        CalendarType: Option Appointment,MeetingRequest,Both;
        UpdateMsg: Label 'If selected calendar type is allready created it''ll be updated if required.';
        RecRef: RecordRef;
        Processed: Boolean;
    begin
        EventEWSMgt.CheckStatus(Job, true);

        CalendarType := StrMenu(CalendarTypeChoice, 1, StrSubstNo(ChooseConfirm, AppointmentMsg, MeetingRequestMsg, UpdateMsg)) - 1;
        if CalendarType = -1 then
            exit;

        if CalendarType in [CalendarType::Appointment, CalendarType::Both] then
            Job.TestField("NPR Calendar Item Status", Job."NPR Calendar Item Status"::Send);

        JobsSetup.Get();
        EventEWSMgt.OrganizerAccountSet(Job, true, false);
        RecRef.GetTable(Job);

        case CalendarType of
            CalendarType::Appointment, CalendarType::Both:
                begin
                    if CalendarType in [CalendarType::Appointment, CalendarType::Both] then begin
                        Job.TestField("Starting Date");
                        Job.TestField("Ending Date");
                        GetExchTemplate(RecRef, 1);
                    end;
                    if CalendarType in [CalendarType::MeetingRequest, CalendarType::Both] then begin
                        CheckMeetingReqMinReq(Job);
                        GetExchTemplate(RecRef, 2);
                    end;

                    Processed := ProcessCalendarItemWithLog(RecRef, 0, '');
                    RecRef.SetTable(Job);
                    Job.Get(Job."No.");
                    if Processed then
                        Job."NPR Calendar Item Status" := Job."NPR Calendar Item Status"::Sent
                    else
                        Job."NPR Calendar Item Status" := Job."NPR Calendar Item Status"::Error;
                    Job.Modify();
                    //COMMIT needs to be here as it separates two distinct processes, sending of an appointment and a meeting request
                    //each of those processes has a template selection subprocess which requires user selection for exchange templates
                    //can be recoded to show template selection before the transaction begins, so one template selection for an appointment and one for meeting request
                    Commit();
                    if CalendarType = CalendarType::Both then
                        SendMultipleLinesToCalendar(Job);
                end;
            CalendarType::MeetingRequest:
                begin
                    CheckMeetingReqMinReq(Job);
                    GetExchTemplate(RecRef, 2);
                    SendMultipleLinesToCalendar(Job);
                end;
        end;

    end;

    local procedure SendMultipleLinesToCalendar(Job: Record Job)
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        SetJobPlanLineMeetingRequestSendFilter(Job, JobPlanningLine);
        if JobPlanningLine.FindSet() then
            repeat
                SendLineToCalendar(JobPlanningLine, false, false, false, false);
            until JobPlanningLine.Next() = 0;
    end;

    procedure SendLineToCalendarAction(var JobPlanningLine: Record "Job Planning Line")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(JobPlanningLine);
        GetExchTemplate(RecRef, 2);
        SendLineToCalendar(JobPlanningLine, true, true, true, true);
    end;

    local procedure SendLineToCalendar(var JobPlanningLine: Record "Job Planning Line"; StatusCheckNeeded: Boolean; ResEMailCheck: Boolean; CalendarStatusCheck: Boolean; StartEndTimeCheck: Boolean): Boolean
    var
        Job: Record Job;
        RecRef: RecordRef;
        Processed: Boolean;
    begin
        Job.Get(JobPlanningLine."Job No.");
        JobsSetup.Get();
        EventEWSMgt.OrganizerAccountSet(Job, true, false);
        if StatusCheckNeeded then
            EventEWSMgt.CheckStatus(Job, true);

        if ResEMailCheck then
            JobPlanningLine.TestField("NPR Resource E-Mail");

        if CalendarStatusCheck then
            JobPlanningLine.TestField("NPR Calendar Item Status", JobPlanningLine."NPR Calendar Item Status"::Send);

        if StartEndTimeCheck then begin
            JobPlanningLine.TestField("NPR Starting Time");
            JobPlanningLine.TestField("NPR Ending Time");
        end;

        RecRef.GetTable(JobPlanningLine);
        JobPlanningLine.TestField("Planning Date");

        Processed := ProcessCalendarItemWithLog(RecRef, 0, '');
        RecRef.SetTable(JobPlanningLine);
        JobPlanningLine.Get(JobPlanningLine."Job No.", JobPlanningLine."Job Task No.", JobPlanningLine."Line No.");
        if Processed then
            JobPlanningLine."NPR Calendar Item Status" := JobPlanningLine."NPR Calendar Item Status"::Sent
        else
            JobPlanningLine."NPR Calendar Item Status" := JobPlanningLine."NPR Calendar Item Status"::Error;
        JobPlanningLine."NPR Meeting Request Response" := JobPlanningLine."NPR Meeting Request Response"::" ";
        JobPlanningLine.Modify();
        exit(JobPlanningLine."NPR Calendar Item Status" = JobPlanningLine."NPR Calendar Item Status"::Sent);
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

        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Resource);
        JobPlanningLine.SetFilter("NPR Calendar Item ID", '<>%1', '');

        case true of
            (Job."NPR Calendar Item ID" = '') and JobPlanningLine.IsEmpty:
                Error(NothingToRemoveMsg);
            (Job."NPR Calendar Item ID" <> '') and not JobPlanningLine.IsEmpty:
                begin
                    CalendarType := StrMenu(CalendarTypeChoice, 1) - 1;
                    if CalendarType = -1 then
                        exit;
                end;
            (Job."NPR Calendar Item ID" = '') and not JobPlanningLine.IsEmpty:
                CalendarType := CalendarType::MeetingRequest;
            (Job."NPR Calendar Item ID" <> '') and JobPlanningLine.IsEmpty:
                CalendarType := CalendarType::Appointment;
        end;

        CancelMsg := GetMsgDialogText();

        JobsSetup.Get();
        EventEWSMgt.OrganizerAccountSet(Job, true, false);
        RecRef.GetTable(Job);
        JobPlanningLine.SetRange("NPR Calendar Item ID");

        case CalendarType of
            CalendarType::Appointment, CalendarType::Both:
                begin
                    Processed := ProcessCalendarItemWithLog(RecRef, 1, CancelMsg);
                    RecRef.SetTable(Job);
                    Job.Get(Job."No.");
                    if Processed then
                        Job."NPR Calendar Item Status" := Job."NPR Calendar Item Status"::Removed
                    else
                        Job."NPR Calendar Item Status" := Job."NPR Calendar Item Status"::Error;
                    Job.Modify();
                    if CalendarType = CalendarType::Both then
                        RemoveMultipleLinesFromCalendar(JobPlanningLine, CancelMsg);
                end;
            CalendarType::MeetingRequest:
                RemoveMultipleLinesFromCalendar(JobPlanningLine, CancelMsg);
        end;
    end;

    local procedure RemoveMultipleLinesFromCalendar(var JobPlanningLine: Record "Job Planning Line"; CancelMsg: Text)
    begin
        if JobPlanningLine.FindSet() then
            repeat
                if JobPlanningLine."NPR Calendar Item ID" <> '' then
                    RemoveLineFromCalendar(JobPlanningLine, false, false, CancelMsg);
            until JobPlanningLine.Next() = 0;
    end;

    procedure RemoveLineFromCalendarAction(JobPlanningLine: Record "Job Planning Line"; ConfirmNeeded: Boolean)
    begin
        RemoveLineFromCalendar(JobPlanningLine, ConfirmNeeded, true, '');
    end;

    procedure RemoveLineFromCalendar(var JobPlanningLine: Record "Job Planning Line"; ConfirmNeeded: Boolean; CancelDialogNeeded: Boolean; CancelMsg: Text): Boolean
    var
        CancelConfirm: Label 'This will cancel a meeting request. Do you want to continue?';
        NothingToRemoveMsg: Label 'There are no calendar items to remove.';
        RecRef: RecordRef;
        Processed: Boolean;
    begin
        if ConfirmNeeded then
            if not Confirm(CancelConfirm) then
                exit;

        if JobPlanningLine."NPR Calendar Item ID" = '' then
            Error(NothingToRemoveMsg);

        if CancelDialogNeeded then
            CancelMsg := GetMsgDialogText();

        RecRef.GetTable(JobPlanningLine);
        Processed := ProcessCalendarItemWithLog(RecRef, 1, CancelMsg);
        RecRef.SetTable(JobPlanningLine);
        JobPlanningLine.Get(JobPlanningLine."Job No.", JobPlanningLine."Job Task No.", JobPlanningLine."Line No.");
        if Processed then begin
            JobPlanningLine."NPR Calendar Item Status" := JobPlanningLine."NPR Calendar Item Status"::Removed;
            JobPlanningLine."NPR Meeting Request Response" := JobPlanningLine."NPR Meeting Request Response"::" ";
        end else
            JobPlanningLine."NPR Calendar Item Status" := JobPlanningLine."NPR Calendar Item Status"::Error;
        JobPlanningLine.Modify();
        exit(JobPlanningLine."NPR Calendar Item Status" = JobPlanningLine."NPR Calendar Item Status"::Removed);
    end;

    procedure ProcessCalendarItemWithLog(var RecRef: RecordRef; ActionToTake: Option Send,Remove; CancelMessage: Text): Boolean
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
        if not ProcessCalendarItem(RecRef, ActionToTake) then begin
            ActivityLog.LogActivity(RecRef.RecordId, 1, ErrorContext, ActivityDescription, CopyStr(GetLastErrorText, 1, MaxStrLen(ActivityLog."Activity Message")));
            exit(false);
        end;
        RecRef.Get(RecRef.RecordId);
        case ActionToTake of
            ActionToTake::Send:
                begin
                    NewContext := SendContext;
                    if ProcessCalendarItemID(2, RecRef, '') <> '' then begin
                        ActivityMessage := StrSubstNo(SuccessfulCalendarItem, SentToTxt);
                    end else begin
                        ActivityLog.LogActivity(RecRef.RecordId, 1, ErrorContext, ActivityDescription, CantFindCalendar);
                        exit(false);
                    end;
                end;
            ActionToTake::Remove:
                begin
                    NewContext := RemoveContext;
                    ActivityMessage := StrSubstNo(SuccessfulCalendarItem, RemovedFromTxt);
                end;
        end;

        ActivityLog.LogActivity(RecRef.RecordId, 0, NewContext, ActivityDescription, ActivityMessage);
        if CancelMessage <> '' then
            ActivityLog.LogActivity(RecRef.RecordId, 0, ReasonContext, '', CancelMessage);
        exit(true);
    end;


    procedure ProcessCalendarItem(var RecRef: RecordRef; ActionToTake: Option Send,Remove): Boolean
    var
        EventBodyText: Text;
        EMailTemplateHeader: Record "NPR E-mail Template Header";
        RecRef2: RecordRef;
        CalendarCategory, CalendarItemID : Text;
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
        ReminderMinutesBeforeStart: Integer;
        ShowAsBusy, UseTemplate : Boolean;
        EventExchIntTemplate: Record "NPR Event Exch. Int. Template";
        EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail";
        Subject, TimeZoneId, EventRequest : Text;
        AllDayEvent: Boolean;
        StartingDateTime: DateTime;
        EndingDateTime: DateTime;
        GraphAPIManagement: Codeunit "NPR Graph API Management";
        JAAttendees: JsonArray;
    begin
        GetTemplates(RecRef, CalendarItemID, Job, JobPlanningLine, UseTemplate, EventExchIntTemplate);
        EventEWSMgt.GetEventExchIntEmail(EventExchIntEmail);

        if CalendarItemID <> '' then begin
            if not GraphAPIManagement.GetEvent(EventExchIntEmail, CalendarItemID) then begin
                ProcessCalendarItemID(0, RecRef, '');
                exit(true);
            end;
            if ActionToTake = ActionToTake::Remove then begin
                if not GraphAPIManagement.DeleteEvent(EventExchIntEmail, CalendarItemID) then
                    exit(false);
                ProcessCalendarItemID(0, RecRef, '');
                ResetAtendeeResponse(RecRef, Job, JobPlanningLine);
                exit(true);
            end;
        end;

        GetAppointmentTemplate(EMailTemplateHeader, ReminderMinutesBeforeStart, EventExchIntTemplate, CalendarCategory, UseTemplate);

        GetTimeZone(EventExchIntEmail, TimeZoneId);
        GetSubject(EMailTemplateHeader, RecRef2, Job, EventExchIntTemplate, UseTemplate, Subject);
        GetTimes(RecRef, Job, JobPlanningLine, EventExchIntTemplate, AllDayEvent, StartingDateTime, EndingDateTime);
        GetAttendees(RecRef, JobPlanningLine, JAAttendees);
        GetEventBodyContent(EventBodyText, EMailTemplateHeader, RecRef2, Job, UseTemplate, EventExchIntTemplate);

        if Job.Status = Job.Status::Open then begin
            ShowAsBusy := true;
        end;

        EventRequest := GraphAPIManagement.CreateEventRequest(Subject, StartingDateTime, EndingDateTime, TimeZoneId, ShowAsBusy, ReminderMinutesBeforeStart, JAAttendees, EventBodyText, CalendarCategory);
        if CalendarItemID = '' then begin
            CalendarItemID := GraphAPIManagement.SendEventRequest(EventExchIntEmail, EventRequest);
        end else
            GraphAPIManagement.SendEventRequestUpdate(EventExchIntEmail, EventRequest, CalendarItemID);
        ProcessCalendarItemID(1, RecRef, CalendarItemID);

        if EventEWSMgt.IncludeAttachmentCheck(Job, 1) then
            AddAttachments(Job, EventExchIntEmail, CalendarItemID);

        exit(true);
    end;

    procedure GetCalendarAttendeeResponses(Job: Record Job)
    var
        EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail";
        GraphAPIManagement: Codeunit "NPR Graph API Management";
        EventContent, Response, Email : Text;
        JOEventContent: JsonObject;
        JToken, JTAttendee, JTResponse, JTEmail : JsonToken;
        JArray: JsonArray;
        i: Integer;
    begin
        Job.TestField("NPR Calendar Item ID");

        EventExchIntEmail.Get(Job."NPR Organizer E-Mail");

        EventContent := GraphAPIManagement.GetEventContent(EventExchIntEmail, Job."NPR Calendar Item ID");
        If EventContent = '' then
            exit;
        JOEventContent.ReadFrom(EventContent);
        JOEventContent.SelectToken('attendees', JToken);
        JArray := JToken.AsArray();
        for i := 0 to JArray.Count() - 1 do begin
            JArray.Get(i, JTAttendee);
            if JTAttendee.SelectToken('status.response', JTResponse) then
                Response := JTResponse.AsValue().AsText();
            if JTAttendee.SelectToken('emailAddress.address', JTEmail) then
                Email := JTEmail.AsValue().AsText();
            UpdateJobLineResponse(Job, Email, Response);
        end;
    end;

    procedure GetCalendarAttendeeResponse(var JobPlanningLine: Record "Job Planning Line"): Boolean
    var
        Job: Record Job;
        EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail";
        GraphAPIManagement: Codeunit "NPR Graph API Management";
        EventContent, Response, Email : Text;
        JOEventContent: JsonObject;
        JToken, JTAttendee, JTResponse, JTEmail : JsonToken;
        JArray: JsonArray;
        i: Integer;
    begin
        Job.Get(JobPlanningLine."Job No.");
        EventEWSMgt.CheckStatus(Job, true);

        JobPlanningLine.TestField("NPR Calendar Item ID");
        EventExchIntEmail.Get(Job."NPR Organizer E-Mail");

        EventContent := GraphAPIManagement.GetEventContent(EventExchIntEmail, JobPlanningLine."NPR Calendar Item ID");
        if EventContent = '' then
            exit(false);
        JOEventContent.ReadFrom(EventContent);
        JOEventContent.SelectToken('attendees', JToken);
        JArray := JToken.AsArray();
        for i := 0 to JArray.Count() - 1 do begin
            JArray.Get(i, JTAttendee);
            if JTAttendee.SelectToken('status.response', JTResponse) then
                Response := JTResponse.AsValue().AsText();
            if JTAttendee.SelectToken('emailAddress.address', JTEmail) then
                Email := JTEmail.AsValue().AsText();
            if JobPlanningLine."NPR Resource E-Mail" = Email then begin
                JobPlanningLine."NPR Meeting Request Response" := ConvertResponse(Response);
                JobPlanningLine."NPR Calendar Item Status" := JobPlanningLine."NPR Calendar Item Status"::Received;
                JobPlanningLine.Modify();
            end;
        end;
        exit(JobPlanningLine."NPR Calendar Item Status" = JobPlanningLine."NPR Calendar Item Status"::Received);
    end;

    local procedure GetMsgDialogText(): Text
    var
        EventStdDialog: Page "NPR Event Standard Dialog";
    begin
        EventStdDialog.UseForMessage();
        if EventStdDialog.RunModal() = ACTION::OK then
            exit(EventStdDialog.GetMessage());
        exit('');
    end;

    local procedure IsAllDayEvent(StartTime: Time; EndTime: Time; LastsWholeDay: Boolean): Boolean
    begin
        if LastsWholeDay then
            exit(true);

        exit((StartTime = 0T) and (EndTime = 0T));
    end;


    local procedure ProcessCalendarItemID("Action": Option Reset,Assign,Get; var RecRef: RecordRef; CalendarID: Text): Text
    var
        FieldRef: FieldRef;
        FieldNo2: Integer;
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
    begin
        case RecRef.Number of
            DATABASE::Job:
                FieldNo2 := Job.FieldNo("NPR Calendar Item ID");
            DATABASE::"Job Planning Line":
                FieldNo2 := JobPlanningLine.FieldNo("NPR Calendar Item ID");
        end;
        FieldRef := RecRef.Field(FieldNo2);
        case Action of
            Action::Reset, Action::Assign:
                begin
                    FieldRef.Value(CalendarID);
                    RecRef.Modify();
                end;
            Action::Get:
                exit(Format(FieldRef));
        end;
    end;

    procedure CheckForCalendarAndRemove(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"): Boolean
    begin
        if CheckForCalendar(Rec, xRec) then
            exit(ConfirmCalendarRemove(Rec));
        exit(false);
    end;

    procedure CheckForCalendar(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"): Boolean
    begin
        exit((xRec.Type = xRec.Type::Resource) and (Rec."NPR Calendar Item ID" <> ''));
    end;

    procedure ConfirmCalendarRemove(var Rec: Record "Job Planning Line"): Boolean
    var
        CancelConfirm: Label 'There is a scheduled meeting request for %1. Do you want to automatically cancel that meeting and send an update to %1?';
    begin
        if Confirm(StrSubstNo(CancelConfirm, Rec."No.")) then
            exit(RemoveLineFromCalendar(Rec, false, false, ''));
        exit(false);
    end;

    procedure SetJobPlanLineMeetingRequestSendFilter(Job: Record Job; var JobPlanningLine: Record "Job Planning Line")
    begin
        EventEWSMgt.SetJobPlanLineFilter(Job, JobPlanningLine);
        JobPlanningLine.SetRange("NPR Calendar Item Status", JobPlanningLine."NPR Calendar Item Status"::Send);
        JobPlanningLine.SetFilter("NPR Starting Time", '<>%1', 0T);
        JobPlanningLine.SetFilter("NPR Ending Time", '<>%1', 0T);
    end;

    local procedure CheckMeetingReqMinReq(Job: Record Job)
    var
        JobPlanningLine: Record "Job Planning Line";
        ResourceLinesNotSetCorrectlyErr: Label 'Meeting Requests can''t be sent as there are no %1 with minimum requirements. These are: %2 = %3 and filled %4 and %5.';
    begin
        SetJobPlanLineMeetingRequestSendFilter(Job, JobPlanningLine);
        if JobPlanningLine.IsEmpty then
            Error(ResourceLinesNotSetCorrectlyErr, JobPlanningLine.TableCaption,
                                                  JobPlanningLine.FieldCaption("NPR Calendar Item Status"),
                                                  Format(JobPlanningLine."NPR Calendar Item Status"::Send),
                                                  JobPlanningLine.FieldCaption("NPR Starting Time"),
                                                  JobPlanningLine.FieldCaption("NPR Ending Time"));
    end;


    local procedure GetExchTemplate(RecRef: RecordRef; CalendarType: Integer)
    var
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
    begin
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
        UseTemplateArr[CalendarType] := EventEWSMgt.UseTemplate(Job, 1, CalendarType, EventExchIntTemplateArr[CalendarType]);
    end;

    local procedure GetEventBodyContent(var BodyText: Text; EMailTemplateHeader: Record "NPR E-mail Template Header"; var RecRef2: RecordRef; var Job: Record Job; UseTemplate: Boolean; var EventExchIntTemplate: Record "NPR Event Exch. Int. Template")
    var
        EMailTemplateLine: Record "NPR E-mail Templ. Line";
        CommentLine: Record "Comment Line";
    begin
        BodyText := '<font face="Calibri">';

        if UseTemplate and EMailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code") then begin
            EMailTemplateLine.SetRange("E-mail Template Code", EMailTemplateHeader.Code);
            if EMailTemplateLine.FindSet() then
                repeat
                    BodyText += EventEWSMgt.ParseEmailTemplateText(RecRef2, EMailTemplateLine."Mail Body Line") + '</br>';
                until EMailTemplateLine.Next() = 0;
        end else
            BodyText += Job.FieldCaption("No.") + ': ' + Job."No." + '</br>' +
                        Job.FieldCaption(Description) + ': ' + Job.Description + '</br>';
        BodyText += '</br>';
        if UseTemplate and EventExchIntTemplate."Include Comments (Calendar)" then begin
            CommentLine.SetRange("Table Name", CommentLine."Table Name"::Job);
            CommentLine.SetRange("No.", Job."No.");
            if CommentLine.FindSet() then
                repeat
                    BodyText += CommentLine.Comment + '</br>'
                until CommentLine.Next() = 0;
        end;
        BodyText += '</font>';
    end;



    local procedure GetTemplates(var RecRef: RecordRef; var CalendarItemID: Text; var Job: Record Job; var JobPlanningLine: Record "Job Planning Line"; var UseTemplate: Boolean; var EventExchIntTemplate: Record "NPR Event Exch. Int. Template"): Boolean
    var
        Source: Text;
    begin
        case RecRef.Number of
            DATABASE::Job:
                begin
                    RecRef.SetTable(Job);
                    CalendarItemID := Job."NPR Calendar Item ID";
                    UseTemplate := UseTemplateArr[1];
                    EventExchIntTemplate := EventExchIntTemplateArr[1];
                end;
            DATABASE::"Job Planning Line":
                begin
                    RecRef.SetTable(JobPlanningLine);
                    Job.Get(JobPlanningLine."Job No.");
                    CalendarItemID := JobPlanningLine."NPR Calendar Item ID";
                    UseTemplate := UseTemplateArr[2];
                    EventExchIntTemplate := EventExchIntTemplateArr[2];
                end;
        end;
        EventEWSMgt.GetOrganizerSetup(Job, Source);
    end;

    local procedure AttendeeFromPlanningLine(JobPlanningLine: Record "Job Planning Line") JOAttendee: JsonObject;
    var
        JOEmailAddress: JsonObject;
    begin
        JOAttendee.Add('type', 'required');
        JOEmailAddress.Add('name', JobPlanningLine.Description);
        JOEmailAddress.Add('address', JobPlanningLine."NPR Resource E-Mail");
        JOAttendee.Add('emailAddress', JOEmailAddress);
    end;



    local procedure GetTimeZone(var EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; var TimeZoneId: Text)
    var
        TimeZone: Record "Time Zone";
    begin
        if EventExchIntEmail."Time Zone No." <> 0 then begin
            TimeZone.Get(EventExchIntEmail."Time Zone No.");
            TimeZoneId := TimeZone.ID;
        end;
    end;

    local procedure GetSubject(var EMailTemplateHeader: Record "NPR E-mail Template Header"; var RecRef2: RecordRef; var Job: Record Job; var EventExchIntTemplate: Record "NPR Event Exch. Int. Template"; UseTemplate: Boolean; var Subject: Text)
    begin
        if UseTemplate and EMailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code") then begin
            RecRef2.GetTable(Job);
            Subject := EventEWSMgt.ParseEmailTemplateText(RecRef2, EMailTemplateHeader.Subject);
        end else
            Subject := Job.Description;
    end;

    local procedure UpdateJobLineResponse(Job: Record Job; Email: Text; Response: Text)
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        If Email = '' then
            exit;
        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Resource);
        JobPlanningLine.SetRange("NPR Resource E-Mail", Email);
        if JobPlanningLine.FindFirst() then begin
            JobPlanningLine."NPR Meeting Request Response" := ConvertResponse(Response);
            JobPlanningLine.Modify();
        end;
    end;

    local procedure ConvertResponse(Response: Text) MeetingRequestResponse: Enum "NPR Meeting Request Response"
    begin
        case Response of
            'none', 'notResponded':
                exit(MeetingRequestResponse::"No Response");
            'organizer':
                exit(MeetingRequestResponse::Organizer);
            'tentativelyAccepted':
                exit(MeetingRequestResponse::Tentative);
            'accepted':
                exit(MeetingRequestResponse::Accepted);
            'declined':
                exit(MeetingRequestResponse::Declined);
            else
                exit(MeetingRequestResponse::" ");
        end;
    end;

    local procedure AddAttachments(Job: Record Job; EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail"; CalendarItemID: Text)
    var
        EventReportLayout: Record "NPR Event Report Layout";
        AttachmentTempBlob: Codeunit "Temp Blob";
        GraphAPIManagement: Codeunit "NPR Graph API Management";
        Base64Convert: Codeunit "Base64 Convert";
        AttachmentStream: InStream;
        AttachmentName, AttachmentExtension, AttachmentRequest : Text;
    begin
        if CalendarItemID = '' then
            exit;
        EventReportLayout.Reset();
        EventReportLayout.SetRange("Event No.", Job."No.");
        EventReportLayout.SetRange(Usage, EventReportLayout.Usage::Team);
        if EventReportLayout.FindSet() then
            repeat
                if EventEWSMgt.CreateAttachment(EventReportLayout, Job, EventReportLayout.Usage::Team - 1, AttachmentTempBlob, AttachmentName, AttachmentExtension) then
                    AttachmentTempBlob.CreateInStream(AttachmentStream);
                AttachmentRequest := GraphAPIManagement.CreateAttachmentRequest(Base64Convert.ToBase64(AttachmentStream), AttachmentName);
                GraphAPIManagement.AddAttachment(EventExchIntEmail, AttachmentRequest, CalendarItemID);
            until EventReportLayout.Next() = 0;
    end;

    local procedure GetTimes(var RecRef: RecordRef; Job: Record Job; JobPlanningLine: Record "Job Planning Line"; EventExchIntTemplate: Record "NPR Event Exch. Int. Template"; var AllDayEvent: Boolean; var StartingDateTime: DateTime; var EndingDateTime: DateTime)
    begin
        case RecRef.Number of
            DATABASE::Job:
                begin
                    EndingDateTime := CreateDateTime(Job."Ending Date", Job."NPR Ending Time");
                    StartingDateTime := CreateDateTime(Job."Starting Date", Job."NPR Starting Time");
                    AllDayEvent := IsAllDayEvent(Job."NPR Starting Time", Job."NPR Ending Time", EventExchIntTemplate."Lasts Whole Day (Appointment)");

                    if AllDayEvent then begin
                        EndingDateTime := CreateDateTime(CalcDate('<1D>', Job."Ending Date"), 0T);
                        StartingDateTime := CreateDateTime(Job."Starting Date", 0T);
                        if EventExchIntTemplate."First Day Only (Appointment)" then
                            EndingDateTime := CreateDateTime(CalcDate('<1D>', Job."Starting Date"), 0T);
                    end;
                end;
            DATABASE::"Job Planning Line":
                begin
                    StartingDateTime := CreateDateTime(JobPlanningLine."Planning Date", JobPlanningLine."NPR Starting Time");
                    EndingDateTime := CreateDateTime(JobPlanningLine."Planning Date", JobPlanningLine."NPR Ending Time");
                end;
        end;
    end;

    local procedure GetAttendees(var RecRef: RecordRef; JobPlanningLine: Record "Job Planning Line"; JAAttendees: JsonArray)
    begin
        case RecRef.Number of
            DATABASE::"Job Planning Line":
                begin
                    JAAttendees.Add(AttendeeFromPlanningLine(JobPlanningLine));
                end;
        end;
    end;

    local procedure GetAppointmentTemplate(var EMailTemplateHeader: Record "NPR E-mail Template Header"; var ReminderMinutesBeforeStart: Integer; EventExchIntTemplate: Record "NPR Event Exch. Int. Template"; var CalendarCategory: Text; UseTemplate: Boolean)
    begin
        if UseTemplate then begin
            if not EMailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code") then
                Clear(EMailTemplateHeader);
            if EventExchIntTemplate."Reminder Enabled (Calendar)" then
                ReminderMinutesBeforeStart := EventExchIntTemplate."Reminder (Minutes) (Calendar)";
            CalendarCategory := EventExchIntTemplate."Conf. Color Categ. (Calendar)";
        end;
    end;

    local procedure ResetAtendeeResponse(RecRef: RecordRef; Job: Record Job; var JobPlanningLine: Record "Job Planning Line")
    begin
        case RecRef.Number of
            DATABASE::Job:
                begin
                    ResetAtendeeResponse(Job);
                end;
            DATABASE::"Job Planning Line":
                begin
                    JobPlanningLine."NPR Meeting Request Response" := JobPlanningLine."NPR Meeting Request Response"::" ";
                end;
        end;
    end;

    local procedure ResetAtendeeResponse(Job: Record Job)
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Resource);
        JobPlanningLine.SetRange("NPR Calendar Item ID", '');
        JobPlanningLine.SetFilter("NPR Resource E-Mail", '<>%1');
        JobPlanningLine.ModifyAll("NPR Meeting Request Response", JobPlanningLine."NPR Meeting Request Response"::" ");
    end;

}


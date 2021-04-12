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
        ExchService: DotNet NPRNetExchangeService;
        AppointmentItem: DotNet NPRNetAppointment;
        ItemId: DotNet NPRNetItemId;
        MessageBody: DotNet NPRNetMessageBody;
        BodyType: DotNet NPRNetBodyType;
        TimeZoneInfo: DotNet NPRNetTimeZoneInfo;
        StringList: DotNet NPRNetStringList;
        BodyText: Text;
        EMailTemplateHeader: Record "NPR E-mail Template Header";
        EMailTemplateLine: Record "NPR E-mail Templ. Line";
        RecRef2: RecordRef;
        CommentLine: Record "Comment Line";
        CalendarItemID: Text;
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
        FileName: Text;
        FileMgt: Codeunit "File Management";
        LegacyFreeBusyStatus: DotNet NPRNetLegacyFreeBusyStatus;
        UseTemplate: Boolean;
        EventExchIntTemplate: Record "NPR Event Exch. Int. Template";
        EndingDate: Date;
        StartingTime: Time;
        EndingTime: Time;
        EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail";
        TimeZoneId: Text;
        ServerTimeZoneId: Text;
        TimeZone: Record "Time Zone";
        ServerOffSet: Duration;
        DateTimeWithOffSet: DateTime;
        SenderOffSet: Duration;
        TimeSpan: DotNet NPRNetTimeSpan;
        CustomOffSet: Duration;
    begin
        case RecRef.Number of
            DATABASE::Job:
                begin
                    RecRef.SetTable(Job);
                    CalendarItemID := Job."NPR Calendar Item ID";
                    if not EventEWSMgt.InitializeExchService(RecRef.RecordId, Job, ExchService, 1) then
                        exit(false);
                    UseTemplate := UseTemplateArr[1];
                    EventExchIntTemplate := EventExchIntTemplateArr[1];
                end;
            DATABASE::"Job Planning Line":
                begin
                    RecRef.SetTable(JobPlanningLine);
                    Job.Get(JobPlanningLine."Job No.");
                    CalendarItemID := JobPlanningLine."NPR Calendar Item ID";
                    if not EventEWSMgt.InitializeExchService(RecRef.RecordId, Job, ExchService, 2) then
                        exit(false);
                    UseTemplate := UseTemplateArr[2];
                    EventExchIntTemplate := EventExchIntTemplateArr[2];
                end;
        end;

        Clear(AppointmentItem);

        AppointmentItem := AppointmentItem.Appointment(ExchService);

        if CalendarItemID <> '' then begin
            if not GetCalendarItem(CalendarItemID, ExchService, AppointmentItem) then begin
                ProcessCalendarItemID(0, RecRef, '');
                exit(true);
            end;
            if ActionToTake = ActionToTake::Remove then begin
                if not RunAppointmentItemMethodWithLog(RecRef.RecordId, ExchService, AppointmentItem, Job, 'Delete', 0) then
                    exit(false);
                ProcessCalendarItemID(0, RecRef, '');
                exit(true);
            end;
        end;

        if UseTemplate then
            if not EMailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code") then
                Clear(EMailTemplateHeader);

        if EventEWSMgt.IncludeAttachmentCheck(Job, 1) then
            if EventEWSMgt.CreateAttachment(Job, 1, EMailTemplateHeader, FileName) then begin
                if CalendarItemID <> '' then
                    AppointmentItem.Attachments.Clear();
                AppointmentItem.Attachments.AddFileAttachment(FileName);
            end;

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

        if CalendarItemID <> '' then begin
            if not RunAppointmentItemMethodWithLog(RecRef.RecordId, ExchService, AppointmentItem, Job, 'Update', 0) then
                exit(false);
        end else
            if not RunAppointmentItemMethodWithLog(RecRef.RecordId, ExchService, AppointmentItem, Job, 'Save', 0) then
                exit(false);
        ItemId := AppointmentItem.Id;
        ProcessCalendarItemID(1, RecRef, ItemId.UniqueId);

        if UseTemplate and EMailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code") then begin
            RecRef2.GetTable(Job);
            AppointmentItem.Subject := EventEWSMgt.ParseEmailTemplateText(RecRef2, EMailTemplateHeader.Subject);
        end else
            AppointmentItem.Subject := Job.Description;

        case RecRef.Number of
            DATABASE::Job:
                begin
                    EndingDate := Job."Ending Date";
                    StartingTime := Job."NPR Starting Time";
                    EndingTime := Job."NPR Ending Time";
                    AppointmentItem.IsAllDayEvent := IsAllDayEvent(StartingTime, EndingTime, EventExchIntTemplate."Lasts Whole Day (Appointment)");

                    if AppointmentItem.IsAllDayEvent then begin
                        EndingDate := CalcDate('<1D>', EndingDate);
                        StartingTime := 000000T;
                        EndingTime := 000000T;
                        if EventExchIntTemplate."First Day Only (Appointment)" then
                            EndingDate := CalcDate('<1D>', Job."Starting Date");
                    end;
                    DateTimeWithOffSet := CreateDateTime(Job."Starting Date", StartingTime) + (ServerOffSet - SenderOffSet) + CustomOffSet;
                    AppointmentItem.Start := DateTimeWithOffSet;
                    DateTimeWithOffSet := CreateDateTime(EndingDate, EndingTime) + (ServerOffSet - SenderOffSet) + CustomOffSet;
                    AppointmentItem."End" := DateTimeWithOffSet;
                end;
            DATABASE::"Job Planning Line":
                begin
                    DateTimeWithOffSet := CreateDateTime(JobPlanningLine."Planning Date", JobPlanningLine."NPR Starting Time") + (ServerOffSet - SenderOffSet) + CustomOffSet;
                    AppointmentItem.Start := DateTimeWithOffSet;
                    DateTimeWithOffSet := CreateDateTime(JobPlanningLine."Planning Date", JobPlanningLine."NPR Ending Time") + (ServerOffSet - SenderOffSet) + CustomOffSet;
                    AppointmentItem."End" := DateTimeWithOffSet;
                    AppointmentItem.RequiredAttendees.Add(JobPlanningLine."NPR Resource E-Mail");
                end;
        end;

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
        AppointmentItem.Body := MessageBody.MessageBody(BodyType.HTML, BodyText);

        AppointmentItem.LegacyFreeBusyStatus := LegacyFreeBusyStatus.Tentative;

        if Job.Status = Job.Status::Open then begin //NAV2017
            AppointmentItem.LegacyFreeBusyStatus := LegacyFreeBusyStatus.Busy;
            if UseTemplate and (EventExchIntTemplate."Conf. Color Categ. (Calendar)" <> '') then begin
                StringList := AppointmentItem.Categories;
                if not StringList.Contains(EventExchIntTemplate."Conf. Color Categ. (Calendar)") then
                    AppointmentItem.Categories.Add(EventExchIntTemplate."Conf. Color Categ. (Calendar)");
            end;
        end;

        if UseTemplate then begin
            AppointmentItem.IsReminderSet := EventExchIntTemplate."Reminder Enabled (Calendar)";
            AppointmentItem.ReminderMinutesBeforeStart := EventExchIntTemplate."Reminder (Minutes) (Calendar)";
        end;
        case RecRef.Number of
            DATABASE::Job:
                begin
                    if not RunAppointmentItemMethodWithLog(RecRef.RecordId, ExchService, AppointmentItem, Job, 'Update', 0) then
                        exit(false);
                    RecRef.Get(Job.RecordId);
                end;
            DATABASE::"Job Planning Line":
                if not RunAppointmentItemMethodWithLog(RecRef.RecordId, ExchService, AppointmentItem, Job, 'Update', 1) then
                    exit(false);
        end;

        FileMgt.DeleteServerFile(FileName);
        exit(true);
    end;

    [TryFunction]
    local procedure GetCalendarItem(CalendarItemID: Text; ExchService: DotNet NPRNetExchangeService; var AppointmentItem: DotNet NPRNetAppointment)
    var
        ItemId: DotNet NPRNetItemId;
    begin
        Clear(ItemId);
        ItemId := ItemId.ItemId(CalendarItemID);
        AppointmentItem := AppointmentItem.Bind(ExchService, ItemId);
    end;

    procedure GetCalendarAttendeeResponses(Job: Record Job)
    var
        RecRef: RecordRef;
        JobPlanningLine: Record "Job Planning Line";
    begin
        EventEWSMgt.CheckStatus(Job, true);

        JobsSetup.Get();
        EventEWSMgt.OrganizerAccountSet(Job, true, false);
        RecRef.GetTable(Job);
        EventEWSMgt.SetJobPlanLineFilter(Job, JobPlanningLine);
        if JobPlanningLine.FindSet() then
            repeat
                GetCalendarAttendeeResponse(JobPlanningLine);
            until JobPlanningLine.Next() = 0;
    end;

    procedure GetCalendarAttendeeResponseAction(var JobPlanningLine: Record "Job Planning Line")
    begin
        GetCalendarAttendeeResponse(JobPlanningLine);
    end;

    procedure GetCalendarAttendeeResponse(var JobPlanningLine: Record "Job Planning Line"): Boolean
    var
        Job: Record Job;
        RecRef: RecordRef;
        Response: Text;
        ResponseType: DotNet NPRNetMeetingResponseType;
    begin
        Job.Get(JobPlanningLine."Job No.");
        EventEWSMgt.CheckStatus(Job, true);

        if JobPlanningLine."NPR Calendar Item ID" = '' then
            exit(false);

        JobsSetup.Get();
        EventEWSMgt.OrganizerAccountSet(Job, true, false);
        RecRef.GetTable(JobPlanningLine);
        if not ProcessAttendeeReponseWithLog(JobPlanningLine, Response) then begin
            JobPlanningLine."NPR Calendar Item Status" := JobPlanningLine."NPR Calendar Item Status"::Error;
            JobPlanningLine."NPR Meeting Request Response" := JobPlanningLine."NPR Meeting Request Response"::" ";
        end else begin
            case Response of
                ResponseType.Unknown.ToString():
                    JobPlanningLine."NPR Meeting Request Response" := JobPlanningLine."NPR Meeting Request Response"::Unknown;
                ResponseType.Organizer.ToString():
                    JobPlanningLine."NPR Meeting Request Response" := JobPlanningLine."NPR Meeting Request Response"::Organizer;
                ResponseType.Tentative.ToString():
                    JobPlanningLine."NPR Meeting Request Response" := JobPlanningLine."NPR Meeting Request Response"::Tentative;
                ResponseType.Accept.ToString():
                    JobPlanningLine."NPR Meeting Request Response" := JobPlanningLine."NPR Meeting Request Response"::Accepted;
                ResponseType.Decline.ToString():
                    JobPlanningLine."NPR Meeting Request Response" := JobPlanningLine."NPR Meeting Request Response"::Declined;
                ResponseType.NoResponseReceived.ToString():
                    JobPlanningLine."NPR Meeting Request Response" := JobPlanningLine."NPR Meeting Request Response"::"No Response";
            end;
            JobPlanningLine."NPR Calendar Item Status" := JobPlanningLine."NPR Calendar Item Status"::Received;
        end;
        JobPlanningLine.Modify();
        exit(JobPlanningLine."NPR Calendar Item Status" = JobPlanningLine."NPR Calendar Item Status"::Received);

    end;

    procedure ProcessAttendeeReponseWithLog(var JobPlanningLine: Record "Job Planning Line"; var Response: Text): Boolean
    var
        ResponseContext: Label 'RESPONSE';
        ActivityDescription: Label 'Getting Response..';
        SuccessfullResponse: Label 'Response obtained: %1';
        ActivityLog: Record "Activity Log";
    begin
        if not ProcessAttendeeResponse(JobPlanningLine, Response) then begin
            ActivityLog.LogActivity(JobPlanningLine.RecordId, 1, ResponseContext, ActivityDescription, CopyStr(GetLastErrorText, 1, MaxStrLen(ActivityLog."Activity Message")));
            exit(false);
        end;
        if JobPlanningLine."NPR Calendar Item ID" = '' then begin
            ActivityLog.LogActivity(JobPlanningLine.RecordId, 1, ErrorContext, ActivityDescription, CantFindCalendar);
            exit(false);
        end;
        ActivityLog.LogActivity(JobPlanningLine.RecordId, 0, ResponseContext, ActivityDescription, StrSubstNo(SuccessfullResponse, Response));
        exit(true);
    end;

    [TryFunction]
    procedure ProcessAttendeeResponse(var JobPlanningLine: Record "Job Planning Line"; var Response: Text)
    var
        ExchService: DotNet NPRNetExchangeService;
        AppointmentItem: DotNet NPRNetAppointment;
        Attendee: DotNet NPRNetAttendee;
        i: Integer;
        CantFindEmailError: Label 'No calendar requests have been sent to this e-mail %1. Please resend the request.';
        Job: Record Job;
        j: Integer;
    begin
        Clear(AppointmentItem);
        Job.Get(JobPlanningLine."Job No.");
        EventEWSMgt.InitializeExchService(JobPlanningLine.RecordId, Job, ExchService, 2);
        AppointmentItem := AppointmentItem.Appointment(ExchService);
        if not GetCalendarItem(JobPlanningLine."NPR Calendar Item ID", ExchService, AppointmentItem) then begin
            JobPlanningLine."NPR Calendar Item ID" := '';
            exit;
        end;
        if AppointmentItem.RequiredAttendees.Count() = 0 then
            exit;
        i := -1;
        j := -1;
        foreach Attendee in AppointmentItem.RequiredAttendees do begin
            i += 1;
            if LowerCase(Attendee.Address) = LowerCase(JobPlanningLine."NPR Resource E-Mail") then
                j := i;
        end;
        if j = -1 then
            Error(CantFindEmailError, JobPlanningLine."NPR Resource E-Mail");
        Response := AppointmentItem.RequiredAttendees.Item(j).ResponseType.ToString();
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

    local procedure RunAppointmentItemMethodWithLog(RecordId: RecordID; ExchService: DotNet NPRNetExchangeService; var AppointmentItem: DotNet NPRNetAppointment; var Job: Record Job; MethodName: Text; SendMode: Integer): Boolean
    var
        ActivityLog: Record "Activity Log";
        Context: Text;
        ActivityDescription: Text;
    begin
        if not RunAppointmentItemMethod(AppointmentItem, MethodName, SendMode, Context, ActivityDescription) then begin
            if not RunAppointmentItemMethod(AppointmentItem, MethodName, SendMode, Context, ActivityDescription) then begin
                ActivityLog.LogActivity(RecordId, 1, Context, ActivityDescription, CopyStr(GetLastErrorText, 1, MaxStrLen(ActivityLog."Activity Message")));
                exit(false);
            end;
        end;
        exit(true);
    end;

    local procedure RunAppointmentItemMethod(var AppointmentItem: DotNet NPRNetAppointment; MethodName: Text; SendMode: Integer; var Context: Text; var ActivityDescription: Text): Boolean
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
                    exit(AppointmentItemUpdate(AppointmentItem, SendMode));
                end;
        end;
    end;

    [TryFunction]
    local procedure AppointmentItemDelete(var AppointmentItem: DotNet NPRNetAppointment)
    var
        DeleteMode: DotNet NPRNetDeleteMode;
        SendCancellationsMode: DotNet NPRNetSendCancellationsMode;
    begin
        AppointmentItem.Delete(DeleteMode.HardDelete, SendCancellationsMode.SendToAllAndSaveCopy);
    end;

    [TryFunction]
    local procedure AppointmentItemSave(var AppointmentItem: DotNet NPRNetAppointment)
    var
        SendInvitationsMode: DotNet NPRNetSendInvitationsMode;
    begin
        AppointmentItem.Save(SendInvitationsMode.SendToNone);
    end;

    [TryFunction]
    local procedure AppointmentItemUpdate(var AppointmentItem: DotNet NPRNetAppointment; SendMode: Option "None",AllAndSendCopy)
    var
        ConflictResolutionMode: DotNet NPRNetConflictResolutionMode;
        SendInviteCancelMode: DotNet NPRNetSendInvitationsOrCancellationsMode;
    begin
        case SendMode of
            SendMode::None:
                AppointmentItem.Update(ConflictResolutionMode.AlwaysOverwrite, SendInviteCancelMode.SendToNone);
            SendMode::AllAndSendCopy:
                AppointmentItem.Update(ConflictResolutionMode.AlwaysOverwrite, SendInviteCancelMode.SendToAllAndSaveCopy);
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

    local procedure ApplySubstituteTimeZone(var TimeZoneId: Text)
    var
        TimeZone: Record "Time Zone";
    begin
        //-NPR5.46 [323953]
        //some timezones have different types between .NET and EWS and error occurs
        //one of those is Russian Standard Time
        //quickest workaround is to use other timezones of same offset
        TimeZone.SetRange(ID, TimeZoneId);
        if TimeZone.FindFirst() then
            case TimeZone.ID of
                'Russian Standard Time':
                    TimeZoneId := 'Belarus Standard Time';
            end;
        //+NPR5.46 [323953]
    end;

    local procedure GetExchTemplate(RecRef: RecordRef; CalendarType: Integer)
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
        UseTemplateArr[CalendarType] := EventEWSMgt.UseTemplate(Job, 1, CalendarType, EventExchIntTemplateArr[CalendarType]);
        //+NPR5.48 [342511]
    end;
}


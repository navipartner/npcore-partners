codeunit 6060151 "NPR Event EWS Management"
{
    Access = Internal;
    var

        ExchItemType: Option "E-Mail",Appointment,"Meeting Request";
        EventExchIntEmailGlobal: Record "NPR Event Exch. Int. E-Mail";
        ExchTemplateCaption: Label 'Please select a %1 template...';
        SkipLookup: Boolean;

    [EventSubscriber(ObjectType::Table, Database::"Job Planning Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure JobPlanningLineNoOnAfterValidate(var Rec: Record "Job Planning Line"; var xRec: Record "Job Planning Line"; CurrFieldNo: Integer)
    var
        Resource: Record Resource;
    begin
        if Rec.Type = Rec.Type::Resource then begin
            if Rec."No." <> '' then begin
                Resource.Get(Rec."No.");
                Rec."NPR Resource E-Mail" := Resource."NPR E-Mail";
            end;
        end;
    end;

    procedure OrganizerAccountSet(Job: Record Job; Test: Boolean; IsEmailBeingSent: Boolean): Boolean
    var
        SetEMailError: Label 'You must choose %1 on %2 or set %3 on Event Card or set %4 with %5 if sending an e-mail before you can proceed.';
        EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail";
        Resource: Record Resource;
        SearchForDefaultAccount: Boolean;
    begin
        SearchForDefaultAccount := Job."NPR Organizer E-Mail" = '';
        if IsEmailBeingSent then
            SearchForDefaultAccount := SearchForDefaultAccount and ((IsEmailBeingSent and (Job."Person Responsible" <> '') and Resource.Get(Job."Person Responsible") and (Resource."NPR E-Mail" = ''))
                                                                    or (IsEmailBeingSent and (Job."Person Responsible" = '')));
        if SearchForDefaultAccount then begin
            EventExchIntEmail.SetRange("Default Organizer E-Mail", true);
            SearchForDefaultAccount := EventExchIntEmail.IsEmpty();
            if SearchForDefaultAccount and Test then
                Error(SetEMailError, EventExchIntEmail.FieldCaption("Default Organizer E-Mail"), EventExchIntEmail.TableCaption, Job.FieldCaption("NPR Organizer E-Mail"),
                      Job.FieldCaption("Person Responsible"), Resource.FieldCaption("NPR E-Mail"));
        end;
        exit(not SearchForDefaultAccount);
    end;

    procedure GetOrganizerSetup(Job: Record Job; var Source: Text)
    var
        Resource: Record Resource;
        UserName: Text;
    begin
        EventExchIntEmailGlobal.SetRange("Default Organizer E-Mail", true);
        if EventExchIntEmailGlobal.FindFirst() then begin
            UserName := EventExchIntEmailGlobal."E-Mail";
            Source := GetObjectCaption(8, PAGE::"NPR Event Exch. Int. E-Mails") + ': ' + EventExchIntEmailGlobal.FieldCaption("Default Organizer E-Mail");
        end;
        if Job."NPR Organizer E-Mail" <> '' then begin
            UserName := Job."NPR Organizer E-Mail";
            Source := GetObjectCaption(8, PAGE::"NPR Event Card") + ': ' + Job.FieldCaption("NPR Organizer E-Mail");
        end;
        if (ExchItemType = ExchItemType::"E-Mail") and (Job."Person Responsible" <> '') and Resource.Get(Job."Person Responsible") and (Resource."NPR E-Mail" <> '') then begin
            UserName := Resource."NPR E-Mail";
            Source := GetObjectCaption(8, PAGE::"NPR Event Card") + ': ' + Job.FieldCaption("Person Responsible");
        end;
        if not EventExchIntEmailGlobal.Get(UserName) then begin
            Clear(EventExchIntEmailGlobal);
            Source := GetObjectCaption(8, PAGE::"NPR Event Card") + ': ' + Job.FieldCaption("NPR Organizer E-Mail");
        end;
    end;

    procedure CheckStatus(Job: Record Job; ShowError: Boolean) StatusOK: Boolean
    var
        ProperStatusText: Label 'Events in status %1 are not allowed for calendar integration.';
    begin
        StatusOK := InProperStatus(Job."NPR Event Status");
        if not StatusOK and ShowError then
            Error(ProperStatusText, Format(Job."NPR Event Status"));
        exit(StatusOK);
    end;

    local procedure InProperStatus(Status: Enum "NPR Event Status"): Boolean
    begin
        exit(Status.AsInteger() > 0);
    end;



    procedure SetJobPlanLineFilter(Job: Record Job; var JobPlanningLine: Record "Job Planning Line")
    begin
        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.SetRange(Type, JobPlanningLine.Type::Resource);
        JobPlanningLine.SetFilter("NPR Resource E-Mail", '<>%1', '');
    end;

    procedure ParseEmailTemplateText(var RecRef: RecordRef; Line: Text) NewLine: Text
    var
        FieldRef: FieldRef;
        EndPos: Integer;
        FieldNo: Integer;
        StartPos: Integer;
    begin
        //this function is a copy of function ParseEmailText in codeunit 6014450 E-Mail Management
        NewLine := Line;
        while (StrPos(NewLine, '{') > 0) do begin
            StartPos := StrPos(NewLine, '{');
            EndPos := StrPos(NewLine, '}');
            Evaluate(FieldNo, CopyStr(NewLine, StartPos + 1, EndPos - StartPos - 1));
            if RecRef.FieldExist(FieldNo) then begin
                FieldRef := RecRef.Field(FieldNo);
                if UpperCase(Format(FieldRef.Class)) = 'FLOWFIELD' then
                    FieldRef.CalcField();
                NewLine := InsStr(DelStr(NewLine, StartPos, EndPos - StartPos + 1), Format(FieldRef), StartPos);
            end;
            Line := NewLine;
        end;

        exit(NewLine);
    end;

    local procedure CustomizedLayoutFound(Job: Record Job; Usage: Option): Boolean
    var
        EventReportLayout: Record "NPR Event Report Layout";
    begin
        EventReportLayout.SetRange("Event No.", Job."No.");
        EventReportLayout.SetRange(Usage, Usage + 1);
        exit(not EventReportLayout.IsEmpty());
    end;

    local procedure BaseReportLayoutExists(Usage: Option Customer,Team): Boolean
    var
        ReportID: Integer;
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
    begin
        case Usage of
            Usage::Customer:
                ReportID := REPORT::"NPR Event Customer Template";
            Usage::Team:
                ReportID := REPORT::"NPR Event Team Template";
        end;

        if not ReportLayoutSelection.Get(ReportID, CompanyName) then
            exit(false);
        exit((ReportLayoutSelection.Type = ReportLayoutSelection.Type::"Custom Layout") and CustomReportLayout.Get(ReportLayoutSelection."Custom Report Layout Code"));
    end;

    procedure IncludeAttachmentCheck(Job: Record Job; Usage: Option): Boolean
    begin
        if not CustomizedLayoutFound(Job, Usage) then
            exit(BaseReportLayoutExists(Usage));
        exit(true);
    end;

    procedure CreateFilePath(Job: Record Job; FileName: Text; EMailTemplateHeader: Record "NPR E-mail Template Header"): Text
    var
        FileMgt: Codeunit "File Management";
    begin
        exit(FileMgt.GetDirectoryName(FileName) + '\' + CreateFileName(Job, EMailTemplateHeader) + '.' + FileMgt.GetExtension(FileName));
    end;

    procedure CreateFileName(Job: Record Job; EMailTemplateHeader: Record "NPR E-mail Template Header") Name: Text
    var
        RecRef: RecordRef;
    begin
        Name := Job.FieldCaption("NPR Event") + '-' + Format(Job."NPR Event Status") + '-' + Job."No.";
        if not EMailTemplateHeader.IsEmpty then begin
            RecRef.GetTable(Job);
            if EMailTemplateHeader.Filename <> '' then
                Name := ParseEmailTemplateText(RecRef, EMailTemplateHeader.Filename);
        end;
        exit(Name);

    end;



    procedure CreateAttachment(EventReportLayout: Record "NPR Event Report Layout"; Job: Record Job; MailFor: Option Customer,Team; var AttachmentTempBlob: Codeunit "Temp Blob"; var AttachmentName: Text; var AttachmentExtension: Text) Sucess: Boolean
    var
        ReportLayoutSelectionLocal: Record "Report Layout Selection";
        OutStream: OutStream;
        RecRef: RecordRef;
    begin

        ReportLayoutSelectionLocal.SetTempLayoutSelected(EventReportLayout."Layout Code");
        Job.SetRecFilter();
        RecRef.GetTable(Job);
        AttachmentTempBlob.CreateOutStream(OutStream);
        case MailFor of
            MailFor::Customer:
                begin
                    AttachmentExtension := '.pdf';
                    AttachmentName := EventReportLayout.Description + AttachmentExtension;
                    Sucess := Report.SaveAs(EventReportLayout."Report ID", EventReportLayout.GetParameters(), ReportFormat::Pdf, OutStream, RecRef);
                end;
            MailFor::Team:
                begin
                    AttachmentExtension := '.docx';
                    AttachmentName := EventReportLayout.Description + AttachmentExtension;
                    Sucess := Report.SaveAs(EventReportLayout."Report ID", EventReportLayout.GetParameters(), ReportFormat::Word, OutStream, RecRef);
                end;
        end;
        ReportLayoutSelectionLocal.SetTempLayoutSelected('');
    end;

    procedure UseTemplate(Job: Record Job; TemplateFor: Integer; ExchItemType: Integer; var EventExchIntTemplate: Record "NPR Event Exch. Int. Template"): Boolean
    begin
        Clear(EventExchIntTemplate);
        exit(FindExchIntTemplate(Job, TemplateFor, ExchItemType, EventExchIntTemplate));
    end;

    local procedure FindExchIntTemplate(Job: Record Job; TemplateFor: Integer; ExchItemType: Integer; var EventExchIntTemplate: Record "NPR Event Exch. Int. Template"): Boolean
    var
        EmailTemplateHeader: Record "NPR E-mail Template Header";
    begin
        if FindEmailTemplateHeader(Job, EmailTemplateHeader) then begin
            if SelectExchIntTemplate(EmailTemplateHeader, TemplateFor, ExchItemType, EventExchIntTemplate) then begin
                if SelectExchIntTemplateEntry(Job, EventExchIntTemplate) then
                    exit(true)
                else begin
                    Clear(EventExchIntTemplate);
                    if SelectExchIntTemplateEntry(Job, EventExchIntTemplate) then begin
                        EmailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code");
                        exit(true);
                    end else
                        exit(false);
                end;
            end else begin
                Clear(EmailTemplateHeader);
                if SelectExchIntTemplate(EmailTemplateHeader, TemplateFor, ExchItemType, EventExchIntTemplate) then begin
                    EmailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code");
                    exit(true);
                end else
                    exit(false);
            end;
        end;
    end;

    procedure GetEmailTemplateHeader(RecRef: RecordRef; var EmailTemplateHeader: Record "NPR E-mail Template Header") RecordExists: Boolean
    var
        EmailTemplateFilter: Record "NPR E-mail Template Filter";
        FieldRef: FieldRef;
        FieldRef2: FieldRef;
        RecRef2: RecordRef;
    begin
        RecRef.SetRecFilter();
        RecRef2 := RecRef.Duplicate();
        EmailTemplateHeader.SetRange("Table No.", RecRef.Number);
        if EmailTemplateHeader.FindSet() then
            repeat
                EmailTemplateFilter.SetRange("E-mail Template Code", EmailTemplateHeader.Code);
                EmailTemplateFilter.SetRange("Table No.", EmailTemplateHeader."Table No.");
                if EmailTemplateFilter.FindSet() then begin
                    RecordExists := true;
                    repeat
                        FieldRef := RecRef.Field(EmailTemplateFilter."Field No.");
                        FieldRef2 := RecRef2.Field(EmailTemplateFilter."Field No.");
                        if Evaluate(FieldRef2, EmailTemplateFilter.Value) then
                            RecordExists := RecordExists and (Format(FieldRef2) = Format(FieldRef))
                        else
                            RecordExists := false;
                    until (EmailTemplateFilter.Next() = 0) or (not RecordExists);
                end;
            until (EmailTemplateHeader.Next() = 0) or RecordExists;

        if RecordExists then
            EmailTemplateHeader.Get(EmailTemplateFilter."E-mail Template Code")
        else
            RecordExists := EmailTemplateHeader.FindFirst();
        exit(RecordExists);

    end;

    local procedure FindEmailTemplateHeader(Job: Record Job; var EmailTemplateHeader: Record "NPR E-mail Template Header"): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Job);
        exit(GetEmailTemplateHeader(RecRef, EmailTemplateHeader));
    end;

    local procedure SelectExchIntTemplate(EmailTemplateHeader: Record "NPR E-mail Template Header"; TemplateFor: Option Customer,Team; ExchItemType: Option "E-Mail",Appointment,"Meeting Request"; var EventExchIntTemplate: Record "NPR Event Exch. Int. Template"): Boolean
    var
        EventExchIntTemplates: Page "NPR Event Exch. Int. Templates";
    begin
        EventExchIntTemplate.SetRange("E-mail Template Header Code");
        if EmailTemplateHeader.Code <> '' then
            EventExchIntTemplate.SetRange("E-mail Template Header Code", EmailTemplateHeader.Code);
        EventExchIntTemplate.SetRange("Template For", TemplateFor);
        EventExchIntTemplate.SetRange("Exch. Item Type", ExchItemType);
        if EventExchIntTemplate.IsEmpty then
            exit(false);
        if EventExchIntTemplate.FindFirst() and (EventExchIntTemplate.Count() = 1) then
            exit(true);
        if SkipLookup then
            exit(false);
        EventExchIntTemplates.LookupMode := true;
        EventExchIntTemplates.Caption := StrSubstNo(ExchTemplateCaption, Format(ExchItemType, 0, 0));
        EventExchIntTemplates.SetTableView(EventExchIntTemplate);
        if EventExchIntTemplates.RunModal() = ACTION::LookupOK then begin
            EventExchIntTemplates.GetRecord(EventExchIntTemplate);
            exit(true);
        end;
        exit(false);
    end;

    local procedure SelectExchIntTemplateEntry(Job: Record Job; var EventExchIntTemplate: Record "NPR Event Exch. Int. Template"): Boolean
    var
        EventExchIntTempEntry: Record "NPR Event Exch.Int.Temp.Entry";
        EventExchIntTempEntries: Page "NPR Event Exch.Int.Tmp.Entries";
    begin
        if (EventExchIntTemplate.Code <> '') and EventExchIntTempEntry.Get(EventExchIntTemplate.Code, Job.RecordId) and EventExchIntTempEntry.Active then
            exit(true);
        if SkipLookup then
            exit(false);
        EventExchIntTempEntry.SetRange("Source Record ID", Job.RecordId);
        EventExchIntTempEntries.LookupMode := true;
        EventExchIntTempEntries.SetTableView(EventExchIntTempEntry);
        if EventExchIntTempEntries.RunModal() = ACTION::LookupOK then begin
            EventExchIntTempEntries.GetRecord(EventExchIntTempEntry);
            EventExchIntTemplate.Get(EventExchIntTempEntry.Code);
            exit(true);
        end;
        exit(false);
    end;



    local procedure PrepareExchIntSummary(Job: Record Job; var EventExchIntSumBuffer: Record "NPR Event Exc.Int.Summ. Buffer")
    var
        EmailCustomerText: Label 'E-mail (Customer)';
        FromText: Label 'From';
        ToText: Label 'To';
        EmailTeamText: Label 'E-mail (Team)';
        AppointmentText: Label 'Appointment';
        SavedInText: Label 'Saved in';
        MeetingReqText: Label 'Meeting Request';
        FromEmail: Text;
        FromSource: Text;
        JobPlanningLine: Record "Job Planning Line";
        EventCalendarMgt: Codeunit "NPR Event Calendar Mgt.";
        ParentEntryNo: Integer;
    begin
        AddExchObjToBuffer(EventExchIntSumBuffer, 0, EmailCustomerText, '', '', EventExchIntSumBuffer."Entry No.", 0);
        ExchItemType := ExchItemType::"E-Mail";
        GetOrganizerSetup(Job, FromSource);
        ParentEntryNo := EventExchIntSumBuffer."Entry No.";
        AddExchObjToBuffer(EventExchIntSumBuffer, 1, FromText, EventExchIntEmailGlobal."E-Mail", FromSource, EventExchIntSumBuffer."Entry No.", ParentEntryNo);
        AddExchObjToBuffer(EventExchIntSumBuffer, 1, ToText, Job."NPR Bill-to E-Mail", GetObjectCaption(8, PAGE::"NPR Event Card") + ': ' + Job.FieldCaption("NPR Bill-to E-Mail"), EventExchIntSumBuffer."Entry No.", ParentEntryNo);

        AddExchObjToBuffer(EventExchIntSumBuffer, 0, EmailTeamText, '', '', EventExchIntSumBuffer."Entry No.", 0);
        ParentEntryNo := EventExchIntSumBuffer."Entry No.";
        AddExchObjToBuffer(EventExchIntSumBuffer, 1, FromText, EventExchIntEmailGlobal."E-Mail", FromSource, EventExchIntSumBuffer."Entry No.", ParentEntryNo);
        JobPlanningLine.SetRange("Job No.", Job."No.");
        JobPlanningLine.SetFilter("NPR Resource E-Mail", '<>%1', '');
        AddJobPlanningLineToBuffer(EventExchIntSumBuffer, JobPlanningLine, ToText, ParentEntryNo);

        AddExchObjToBuffer(EventExchIntSumBuffer, 0, AppointmentText, '', '', EventExchIntSumBuffer."Entry No.", 0);
        ExchItemType := ExchItemType::Appointment;
        GetOrganizerSetup(Job, FromSource);
        FromEmail := EventExchIntEmailGlobal."E-Mail";
        if (Job."NPR Calendar Item Status" in [Job."NPR Calendar Item Status"::" ", Job."NPR Calendar Item Status"::Error]) then
            FromEmail := '';
        ParentEntryNo := EventExchIntSumBuffer."Entry No.";
        AddExchObjToBuffer(EventExchIntSumBuffer, 1, SavedInText, FromEmail, FromSource, EventExchIntSumBuffer."Entry No.", ParentEntryNo);

        AddExchObjToBuffer(EventExchIntSumBuffer, 0, MeetingReqText, '', '', EventExchIntSumBuffer."Entry No.", 0);
        ExchItemType := ExchItemType::"Meeting Request";
        GetOrganizerSetup(Job, FromSource);
        ParentEntryNo := EventExchIntSumBuffer."Entry No.";
        AddExchObjToBuffer(EventExchIntSumBuffer, 1, FromText, FromEmail, FromSource, EventExchIntSumBuffer."Entry No.", ParentEntryNo);
        JobPlanningLine.Reset();
        EventCalendarMgt.SetJobPlanLineMeetingRequestSendFilter(Job, JobPlanningLine);
        AddJobPlanningLineToBuffer(EventExchIntSumBuffer, JobPlanningLine, ToText, ParentEntryNo);
        EventExchIntSumBuffer.FindFirst();
    end;

    local procedure AddJobPlanningLineToBuffer(var EventExchIntSumBuffer: Record "NPR Event Exc.Int.Summ. Buffer"; var JobPlanningLine: Record "Job Planning Line"; ExchItem: Text; ParentEntryNo: Integer)
    var
        Source: Text;
    begin
        Source := GetObjectCaption(8, PAGE::"NPR Event Plan. Lines Sub.") + ': ' + JobPlanningLine.FieldCaption("NPR Resource E-Mail");
        case true of
            JobPlanningLine.IsEmpty:
                AddExchObjToBuffer(EventExchIntSumBuffer, 1, ExchItem, '', Source, EventExchIntSumBuffer."Entry No.", ParentEntryNo);
            JobPlanningLine.Count() = 1:
                begin
                    JobPlanningLine.FindFirst();
                    AddExchObjToBuffer(EventExchIntSumBuffer, 1, ExchItem, JobPlanningLine."NPR Resource E-Mail", Source, EventExchIntSumBuffer."Entry No.", ParentEntryNo);
                end;
            else begin
                    AddExchObjToBuffer(EventExchIntSumBuffer, 1, ExchItem, '', Source, EventExchIntSumBuffer."Entry No.", ParentEntryNo);
                    ParentEntryNo := EventExchIntSumBuffer."Entry No.";
                    JobPlanningLine.FindSet();
                    repeat
                        AddExchObjToBuffer(EventExchIntSumBuffer, 2, '', JobPlanningLine."NPR Resource E-Mail", '', EventExchIntSumBuffer."Entry No.", ParentEntryNo);
                    until JobPlanningLine.Next() = 0;
                end;
        end;
    end;

    local procedure AddExchObjToBuffer(var EventExchIntSumBuffer: Record "NPR Event Exc.Int.Summ. Buffer"; Indentation: Integer; ExchItem: Text; EmailAccount: Text; Source: Text; var EntryNo: Integer; ParentEntryNo: Integer)
    begin
        EntryNo += 1;
        EventExchIntSumBuffer.Init();
        EventExchIntSumBuffer."Entry No." := EntryNo;
        EventExchIntSumBuffer."Parent Entry No." := ParentEntryNo;
        EventExchIntSumBuffer.Indentation := Indentation;
        EventExchIntSumBuffer."Exchange Item" := ExchItem;
        EventExchIntSumBuffer."E-mail Account" := EmailAccount;
        EventExchIntSumBuffer.Source := Source;
        EventExchIntSumBuffer.Insert();
    end;

    local procedure GetObjectCaption(ObjectType: Integer; ObjectID: Integer): Text
    var
        ObjectCaption: Record AllObjWithCaption;
    begin
        if ObjectCaption.Get(ObjectType, ObjectID) then
            exit(ObjectCaption."Object Caption");
        exit('');
    end;

    procedure ShowExchIntSummary(Job: Record Job)
    var
        TempEventExchIntSumBuffer: Record "NPR Event Exc.Int.Summ. Buffer" temporary;
    begin
        PrepareExchIntSummary(Job, TempEventExchIntSumBuffer);
        PAGE.Run(PAGE::"NPR Event Exch. Int. Mail Sum.", TempEventExchIntSumBuffer);
    end;

    procedure ExchIntSummaryApplyStyleExpr(var EventExchIntSummaryBuffer: Record "NPR Event Exc.Int.Summ. Buffer" temporary; var ColorStyle: Text): Boolean
    var
        TempEventExchIntSummaryBuffer2: Record "NPR Event Exc.Int.Summ. Buffer" temporary;
        Apply: Boolean;
        ColorStyle2: Text;
    begin
        ColorStyle := 'Standard';
        TempEventExchIntSummaryBuffer2.Copy(EventExchIntSummaryBuffer, true);
        case EventExchIntSummaryBuffer.Indentation of
            0:
                begin
                    ColorStyle := 'Strong';
                    TempEventExchIntSummaryBuffer2.SetRange("Parent Entry No.", EventExchIntSummaryBuffer."Entry No.");
                    if TempEventExchIntSummaryBuffer2.FindSet() then
                        repeat
                            Apply := Apply or ExchIntSummaryApplyStyleExpr(TempEventExchIntSummaryBuffer2, ColorStyle2);
                        until (TempEventExchIntSummaryBuffer2.Next() = 0) or Apply;
                    if Apply then
                        ColorStyle := 'Unfavorable';
                    exit(Apply);
                end;
            1:
                if EventExchIntSummaryBuffer."E-mail Account" = '' then begin
                    ColorStyle := 'Attention';
                    TempEventExchIntSummaryBuffer2.Reset();
                    if (TempEventExchIntSummaryBuffer2.Next() <> 0) and (TempEventExchIntSummaryBuffer2.Indentation = 2) then begin
                        ColorStyle := 'Standard';
                        exit(false);
                    end;
                    exit(true);
                end;
        end;
        exit(false);
    end;

    procedure GetEventExchIntEmail(var EventExchIntEmail: Record "NPR Event Exch. Int. E-Mail")
    begin
        EventExchIntEmail := EventExchIntEmailGlobal;
    end;

    procedure SetSkipLookup(SkipLookupHere: Boolean)
    begin
        SkipLookup := SkipLookupHere;
    end;
}


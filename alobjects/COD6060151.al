codeunit 6060151 "Event EWS Management"
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.31/TJ  /20170316 CASE 269162 Uri property needed for sending e-mails between different organizations
    //                                   Cleaner error message if using wrong email provider/password
    //                                   Copied functions related with file name creation from "Event E-mail Management" codeunit
    // NPR5.32/TJ  /20170502 CASE 274405 Function IncludeAttachmentCheck now returns boolean instead of giving an error
    //                                   Before creating file for attachment, file is deleted from server just in case it allready exists
    //                                   When checking if base layout is set, checking also if custom report layout exists at all
    // NPR5.32/TJ  /20170515 CASE 275946 Removed functions GetOrganizerAccount and GetOrganizerPassword
    //                                   New functions GetOrganizerSetup, InitializeExchangeService and SetOrganizerExchangeUrl
    //                                   Improvement on authentication so Url is used if possible instead of AutoDiscover every time
    //                                   Renamed function TestAccountSpecified to OrganizerAccountSet and added one more parameter and return value
    //                                   Renamed functions AuthenticateExchangeService and AuthenticateExchServWithLog to AutoDiscoveExchangeService and AutoDiscoverExchangeServiceWIthLog
    // NPR5.34/TJ  /20170706 CASE 277938 New functions for selecting exchange integration template
    //                                   Function UseTemplate copied from codeunits Event Calendar Management and Event Email Management and rewritten
    // NPR5.34/TJ  /20170725 CASE 275991 Added new parameter to function InitializeExchService so different e-mail owner can be selected when sending an e-mail
    //                                   Added code to GetOrganizerSetup and SetOrganizerExchangeUrl
    // NPR5.35/TJ  /20170804 CASE 285826 Recoded usage of .NET assemblies that are specific for current NAV version
    // NPR5.38/TJ  /20171019 CASE 285194 New funcionality around password usage
    //                                   Recoded several functions
    // NPR5.39/TJ  /20171221 CASE 285388 New funcionality to detect e-mail info
    // NPR5.40/TJ  /20180313 CASE 307700 Function GetEmailTemplateHeader now properly returns a template found in template filter
    // NPR5.45/TJ  /20180605 CASE 317448 Function InitializeExchService now has a return value
    // NPR5.46/TJ  /20180904 CASE 323953 New function GetEventExchIntEmail
    // NPR5.48/TJ  /20181217 CASE 327413 Fixed issue with no default e-mail
    // NPR5.48/TJ  /20190130 CASE 342511 Easier to see for which calendar item type is template selection for


    trigger OnRun()
    begin
    end;

    var
        EventVersionSpecificMgt: Codeunit "Event Version Specific Mgt.";
        ExchItemType: Option "E-Mail",Appointment,"Meeting Request";
        EventExchIntEmailGlobal: Record "Event Exch. Int. E-Mail";
        ExchTemplateCaption: Label 'Please select a %1 template...';

    [EventSubscriber(ObjectType::Table, 1003, 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure JobPlanningLineNoOnAfterValidate(var Rec: Record "Job Planning Line";var xRec: Record "Job Planning Line";CurrFieldNo: Integer)
    var
        Resource: Record Resource;
        CancelConfirm: Label 'There is a scheduled meeting request for %1. Do you want to automatically cancel that meeting and send an update to %1?';
    begin
        if Rec.Type = Rec.Type::Resource then begin
          if Rec."No." <> '' then begin
            Resource.Get(Rec."No.");
            Rec."Resource E-Mail" := Resource."E-Mail";
          end;
        end;
    end;

    procedure OrganizerAccountSet(Job: Record Job;Test: Boolean;IsEmailBeingSent: Boolean): Boolean
    var
        SetEMailError: Label 'You must choose %1 on %2 or set %3 on Event Card or set %4 with %5 if sending an e-mail before you can proceed.';
        EventExchIntEmail: Record "Event Exch. Int. E-Mail";
        Resource: Record Resource;
        SearchForDefaultAccount: Boolean;
    begin
        //-NPR5.38 [285194]
        SearchForDefaultAccount := Job."Organizer E-Mail" = '';
        if IsEmailBeingSent then
          SearchForDefaultAccount := SearchForDefaultAccount and ((IsEmailBeingSent and (Job."Person Responsible" <> '') and Resource.Get(Job."Person Responsible") and (Resource."E-Mail" = ''))
                                                                  or (IsEmailBeingSent and (Job."Person Responsible" = '')));
        if SearchForDefaultAccount then begin
          EventExchIntEmail.SetRange("Default Organizer E-Mail",true);
          SearchForDefaultAccount := EventExchIntEmail.IsEmpty;
          if SearchForDefaultAccount and Test then
            Error(SetEMailError,EventExchIntEmail.FieldCaption("Default Organizer E-Mail"),EventExchIntEmail.TableCaption,Job.FieldCaption("Organizer E-Mail"),
                  Job.FieldCaption("Person Responsible"),Resource.FieldCaption("E-Mail"));
        end;
        exit(not SearchForDefaultAccount);
        //+NPR5.38 [285194]
    end;

    local procedure GetOrganizerSetup(Job: Record Job;var Source: Text)
    var
        Resource: Record Resource;
        UserName: Text;
    begin
        //-NPR5.38 [285194]
        EventExchIntEmailGlobal.SetRange("Default Organizer E-Mail",true);
        if EventExchIntEmailGlobal.FindFirst then begin
          UserName := EventExchIntEmailGlobal."E-Mail";
        //-NPR5.39 [285388]
          Source := GetObjectCaption(8,PAGE::"Event Exch. Int. E-Mails") + ': ' + EventExchIntEmailGlobal.FieldCaption("Default Organizer E-Mail");
        end;
        //+NPR5.39 [285388]
        if Job."Organizer E-Mail" <> '' then begin
          UserName := Job."Organizer E-Mail";
        //-NPR5.39 [285388]
          Source := GetObjectCaption(8,PAGE::"Event Card") + ': ' + Job.FieldCaption("Organizer E-Mail");
        end;
        //+NPR5.39 [285388]
        if (ExchItemType = ExchItemType::"E-Mail") and (Job."Person Responsible" <> '') and Resource.Get(Job."Person Responsible") and (Resource."E-Mail" <> '') then begin
          UserName := Resource."E-Mail";
        //-NPR5.39 [285388]
          Source := GetObjectCaption(8,PAGE::"Event Card") + ': ' + Job.FieldCaption("Person Responsible");
        end;
        //+NPR5.39 [285388]
        //-NPR5.48 [327413]
        /*
        EventExchIntEmailGlobal.GET(UserName);
        //+NPR5.38 [285194]
        */
        if not EventExchIntEmailGlobal.Get(UserName) then begin
          Clear(EventExchIntEmailGlobal);
          Source := GetObjectCaption(8,PAGE::"Event Card") + ': ' + Job.FieldCaption("Organizer E-Mail");
        end;
        //+NPR5.48 [327413]

    end;

    local procedure UpdateEventExchIntEmailExchangeUrl()
    var
        Resource: Record Resource;
        Url: Text;
    begin
        Url := EventVersionSpecificMgt.ExchServiceWrapperGetExchangeServiceUrl();
        //-NPR5.38 [285194]
        EventExchIntEmailGlobal."Exchange Server Url" := Url;
        EventExchIntEmailGlobal.Modify;
        //+NPR5.38 [285194]
    end;

    procedure CheckStatus(Job: Record Job;ShowError: Boolean) StatusOK: Boolean
    var
        ProperStatusText: Label 'Events in status %1 are not allowed for calendar integration.';
    begin
        StatusOK := InProperStatus(Job."Event Status");
        if not StatusOK and ShowError then
          Error(ProperStatusText,Format(Job."Event Status"));
        exit(StatusOK);
    end;

    local procedure InProperStatus(Status: Option): Boolean
    begin
        exit(Status > 0);
    end;

    [TryFunction]
    local procedure AutoDiscoverExchangeService(var ExchService: DotNet ExchangeService;Job: Record Job;ForceAutoDiscover: Boolean)
    var
        EmailNotDiscovered: Label 'E-mail provided %1 is not discoverable. Please verify you''re using Microsoft Exchange e-mail account and have entered proper e-mail account and password.';
        Uri: DotNet Uri;
        Source: Text;
    begin
        //-NPR5.38 [285194]
        if ForceAutoDiscover then
          //-NPR5.39 [285388]
          //GetOrganizerSetup(Job);
          GetOrganizerSetup(Job,Source);
          //+NPR5.39 [285388]
        if not EventVersionSpecificMgt.ExchServiceWrapperAutodiscoverServiceUrl(EventExchIntEmailGlobal."E-Mail") then
          Error(EmailNotDiscovered,EventExchIntEmailGlobal."E-Mail");
        //+NPR5.38 [285194]
    end;

    procedure AutoDiscoverExchangeServiceWithLog(RecordId: RecordID;var ExchService: DotNet ExchangeService;Job: Record Job;ForceAutoDiscover: Boolean): Boolean
    var
        ActivityLog: Record "Activity Log";
        ActivityDescription: Label 'Auto Discovering...';
        AutoDiscoverContext: Label 'AUTO DISCOVER';
    begin
        //-NPR5.38 [285194]
        //IF NOT AutoDiscoverExchangeService(ExchService) THEN BEGIN
        if not AutoDiscoverExchangeService(ExchService,Job,ForceAutoDiscover) then begin
        //+NPR5.38 [285194]
          ActivityLog.LogActivity(RecordId,1,AutoDiscoverContext,ActivityDescription,CopyStr(GetLastErrorText,1,MaxStrLen(ActivityLog."Activity Message")));
          exit(false);
        end else
          //-NPR5.38 [285194]
          //SetOrganizerExchangeUrl(Job);
          UpdateEventExchIntEmailExchangeUrl();
          //+NPR5.38 [285194]
        exit(true);
    end;

    procedure InitializeExchService(RecordId: RecordID;Job: Record Job;var ExchService: DotNet ExchangeService;ExchItemType2: Option "E-Mail",Appointment,"Meeting Request"): Boolean
    var
        ExchangeCredentials: DotNet ExchangeCredentials;
        NetworkCredential: DotNet NetworkCredential;
        Uri: DotNet Uri;
        Source: Text;
    begin
        //-NPR5.34 [275991]
        //GetOrganizerSetup(Job);
        //-NPR5.38 [285194]
        //GetOrganizerSetup(Job,ExchItemType);
        ExchItemType := ExchItemType2;
        //-NPR5.39 [285388]
        //GetOrganizerSetup(Job);
        GetOrganizerSetup(Job,Source);
        //+NPR5.39 [285388]
        //+NPR5.38 [285194]
        //+NPR5.34 [275991]
        //-NPR5.35 [285826]
        /*
        ExchServiceWrapper := ExchServiceWrapper.ExchangeServiceWrapper(
                                ExchangeCredentials.op_Implicit(
                                  NetworkCredential.NetworkCredential(UserName,Password)));
        ExchService := ExchServiceWrapper.Service();
        */
        //-NPR5.38 [285194]
        //EventVersionSpecificMgt.ExchServiceWrapperConstructor(UserName,Password);
        EventVersionSpecificMgt.ExchServiceWrapperConstructor(EventExchIntEmailGlobal."E-Mail",GetEmailPassword(EventExchIntEmailGlobal));
        //+NPR5.38 [285194]
        EventVersionSpecificMgt.ExchServiceWrapperService(ExchService);
        //+NPR5.35 [285826]
        //-NPR5.38 [285194]
        if EventExchIntEmailGlobal."Exchange Server Url" = '' then begin
        //+NPR5.38 [285194]
          //-NPR5.38 [285194]
          //IF NOT AutoDiscoverExchangeServiceWithLog(RecordId,ExchService,Job) THEN
          if not AutoDiscoverExchangeServiceWithLog(RecordId,ExchService,Job,false) then
          //+NPR5.38 [285194]
            //-NPR5.45 [317448]
            //ERROR('');
            exit(false);
            //+NPR5.45 [317448]
          //-NPR5.35 [285826]
          //ExchangeUrl := ExchServiceWrapper.ExchangeServiceUrl;
          //-NPR5.38 [285194]
          //ExchangeUrl := EventVersionSpecificMgt.ExchServiceWrapperGetExchangeServiceUrl();
          //+NPR5.38 [285194]
          //+NPR5.35 [285826]
        end;
        //-NPR5.38 [285194]
        //Uri := Uri.Uri(ExchangeUrl);
        Uri := Uri.Uri(EventExchIntEmailGlobal."Exchange Server Url");
        //+NPR5.38 [285194]
        ExchService.Url := Uri;
        //-NPR5.45 [317448]
        exit(true);
        //+NPR5.45 [317448]

    end;

    procedure SetJobPlanLineFilter(Job: Record Job;var JobPlanningLine: Record "Job Planning Line")
    begin
        JobPlanningLine.SetRange("Job No.",Job."No.");
        JobPlanningLine.SetRange(Type,JobPlanningLine.Type::Resource);
        JobPlanningLine.SetFilter("Resource E-Mail",'<>%1','');
    end;

    procedure ParseEmailTemplateText(var RecRef: RecordRef;Line: Text) NewLine: Text
    var
        FieldRef: FieldRef;
        "Count": Integer;
        EndPos: Integer;
        FieldNo: Integer;
        i: Integer;
        OptionInt: Integer;
        StartPos: Integer;
        OptionCaption: Text;
    begin
        //this function is a copy of function ParseEmailText in codeunit 6014450 E-Mail Management
        NewLine := Line;
        while (StrPos(NewLine,'{') > 0) do begin
          StartPos := StrPos(NewLine,'{');
          EndPos := StrPos(NewLine,'}');
          Evaluate (FieldNo,CopyStr(NewLine,StartPos + 1,EndPos - StartPos - 1));
          if RecRef.FieldExist(FieldNo) then begin
            FieldRef := RecRef.Field(FieldNo);
            if UpperCase(Format(FieldRef.Class)) = 'FLOWFIELD' then
              FieldRef.CalcField;
            NewLine := InsStr(DelStr(NewLine,StartPos,EndPos - StartPos + 1),Format(FieldRef),StartPos);
          end;
          Line := NewLine;
        end;

        exit(NewLine);
    end;

    local procedure CustomizedLayoutFound(Job: Record Job;Usage: Option): Boolean
    var
        EventWordLayout: Record "Event Word Layout";
    begin
        exit(EventWordLayout.Get(Job.RecordId,Usage + 1) and EventWordLayout.Layout.HasValue);
    end;

    local procedure BaseReportLayoutExists(Usage: Option Customer,Team): Boolean
    var
        ReportID: Integer;
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayout: Record "Custom Report Layout";
    begin
        case Usage of
          Usage::Customer:
            ReportID := REPORT::"Event Customer Template";
          Usage::Team:
            ReportID := REPORT::"Event Team Template";
        end;

        with ReportLayoutSelection do begin
          if not Get(ReportID,CompanyName) then
            exit(false);
          //-NPR5.32 [274405]
          //EXIT((Type = Type::"Custom Layout") AND ("Custom Report Layout ID" <> 0));
          exit((Type = Type::"Custom Layout") and CustomReportLayout.Get("Custom Report Layout Code")); //NAV 2017
          //+NPR5.32 [274405]
        end;
    end;

    procedure IncludeAttachmentCheck(Job: Record Job;Usage: Option): Boolean
    begin
        if not CustomizedLayoutFound(Job,Usage) then
        //-NPR5.32 [274405]
          /*
          IF NOT BaseReportLayoutExists(Usage) THEN
            ERROR(NoReportLayout);
          */
          exit(BaseReportLayoutExists(Usage));
        exit(true);
        //+NPR5.32 [274405]

    end;

    procedure CreateFilePath(Job: Record Job;FileName: Text;EMailTemplateHeader: Record "E-mail Template Header"): Text
    var
        FileMgt: Codeunit "File Management";
    begin
        //-NPR5.34 [277938]
        //EXIT(FileMgt.GetDirectoryName(FileName) + '\' + CreateFileName(Job,ForWhat) + '.' + FileMgt.GetExtension(FileName));
        exit(FileMgt.GetDirectoryName(FileName) + '\' + CreateFileName(Job,EMailTemplateHeader) + '.' + FileMgt.GetExtension(FileName));
        //+NPR5.34 [277938]
    end;

    procedure CreateFileName(Job: Record Job;EMailTemplateHeader: Record "E-mail Template Header") Name: Text
    var
        RecRef: RecordRef;
        EventEmailMgt: Codeunit "Event Email Management";
        EventCalendarMgt: Codeunit "Event Calendar Management";
    begin
        Name := Job.FieldCaption("Event") + '-' + Format(Job."Event Status") + '-' + Job."No.";
        //-NPR5.34 [277938]
        /*
        CASE ForWhat OF
          ForWhat::Email: HasTemplate := EventEmailMgt.UseTemplate(Job,EMailTemplateHeader);
          ForWhat::Calendar: HasTemplate := EventCalendarMgt.UseTemplate(EMailTemplateHeader);
        END;
        IF HasTemplate THEN BEGIN
          RecRef.GETTABLE(Job);
        */
        if not EMailTemplateHeader.IsEmpty then begin
          RecRef.GetTable(Job);
        //+NPR5.34 [277938]
          if EMailTemplateHeader.Filename <> '' then
            Name := ParseEmailTemplateText(RecRef,EMailTemplateHeader.Filename);
        end;
        exit(Name);

    end;

    procedure CreateAttachment(Job: Record Job;Usage: Option;EMailTemplateHeader: Record "E-mail Template Header";var FileName: Text): Boolean
    var
        FileMgt: Codeunit "File Management";
        EventWordLayout: Record "Event Word Layout";
        EventMgt: Codeunit "Event Management";
    begin
        //-NPR5.34 [277938]
        //FileName := CreateFilePath(Job,FileMgt.ServerTempFileName('pdf'),ForWhat);
        FileName := CreateFilePath(Job,FileMgt.ServerTempFileName('pdf'),EMailTemplateHeader);
        //+NPR5.34 [277938]
        //-NPR5.32 [274405]
        FileMgt.DeleteServerFile(FileName);
        //+NPR5.32 [274405]
        if CustomizedLayoutFound(Job,Usage) then begin
          EventWordLayout.Get(Job.RecordId,Usage + 1);
          EventMgt.MergeAndSaveWordLayout(EventWordLayout,1,FileName);
        end else
          EventMgt.SaveReportAs(Job,Usage,1,FileName);
        exit(true);
    end;

    procedure UseTemplate(Job: Record Job;TemplateFor: Integer;ExchItemType: Integer;var EventExchIntTemplate: Record "Event Exch. Int. Template"): Boolean
    begin
        Clear(EventExchIntTemplate);
        exit(FindExchIntTemplate(Job,TemplateFor,ExchItemType,EventExchIntTemplate));
    end;

    local procedure FindExchIntTemplate(Job: Record Job;TemplateFor: Integer;ExchItemType: Integer;var EventExchIntTemplate: Record "Event Exch. Int. Template"): Boolean
    var
        EmailTemplateHeader: Record "E-mail Template Header";
    begin
        if FindEmailTemplateHeader(Job,EmailTemplateHeader) then begin
          if SelectExchIntTemplate(EmailTemplateHeader,TemplateFor,ExchItemType,EventExchIntTemplate) then begin
            if SelectExchIntTemplateEntry(Job,EventExchIntTemplate) then
              exit(true)
            else begin
              Clear(EventExchIntTemplate);
              if SelectExchIntTemplateEntry(Job,EventExchIntTemplate) then begin
                EmailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code");
                exit(true);
              end else
                exit(false);
            end;
          end else begin
            Clear(EmailTemplateHeader);
            if SelectExchIntTemplate(EmailTemplateHeader,TemplateFor,ExchItemType,EventExchIntTemplate) then begin
              EmailTemplateHeader.Get(EventExchIntTemplate."E-mail Template Header Code");
              exit(true);
            end else
              exit(false);
          end;
        end;
    end;

    procedure GetEmailTemplateHeader(RecRef: RecordRef;var EmailTemplateHeader: Record "E-mail Template Header") RecordExists: Boolean
    var
        EmailTemplateFilter: Record "E-mail Template Filter";
        FieldRef: FieldRef;
    begin
        RecRef.SetRecFilter;
        EmailTemplateHeader.SetRange("Table No.",RecRef.Number);
        if EmailTemplateHeader.FindSet then
          repeat
            EmailTemplateFilter.SetRange("E-mail Template Code",EmailTemplateHeader.Code);
            EmailTemplateFilter.SetRange("Table No.",EmailTemplateHeader."Table No.");
            if EmailTemplateFilter.FindSet then begin
              repeat
                FieldRef := RecRef.Field(EmailTemplateFilter."Field No.");
                FieldRef.SetFilter(EmailTemplateFilter.Value);
              until EmailTemplateFilter.Next = 0;
              RecordExists := RecRef.FindFirst;
              Clear(FieldRef);
            end;
          until (EmailTemplateHeader.Next = 0) or RecordExists;

        //-NPR5.40 [307700]
        if RecordExists then
          EmailTemplateHeader.Get(EmailTemplateFilter."E-mail Template Code")
        else
        //IF NOT RecordExists THEN
        //+NPR5.40 [307700]
          RecordExists := EmailTemplateHeader.FindFirst;
        exit(RecordExists);
    end;

    local procedure FindEmailTemplateHeader(Job: Record Job;var EmailTemplateHeader: Record "E-mail Template Header"): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Job);
        exit(GetEmailTemplateHeader(RecRef,EmailTemplateHeader));
    end;

    local procedure SelectExchIntTemplate(EmailTemplateHeader: Record "E-mail Template Header";TemplateFor: Option Customer,Team;ExchItemType: Option "E-Mail",Appointment,"Meeting Request";var EventExchIntTemplate: Record "Event Exch. Int. Template"): Boolean
    var
        EventExchIntTemplates: Page "Event Exch. Int. Templates";
    begin
        EventExchIntTemplate.SetRange("E-mail Template Header Code");
        if EmailTemplateHeader.Code <> '' then
          EventExchIntTemplate.SetRange("E-mail Template Header Code",EmailTemplateHeader.Code);
        EventExchIntTemplate.SetRange("Template For",TemplateFor);
        EventExchIntTemplate.SetRange("Exch. Item Type",ExchItemType);
        if EventExchIntTemplate.IsEmpty then
          exit(false);
        if EventExchIntTemplate.FindFirst and (EventExchIntTemplate.Count = 1) then
          exit(true);
        EventExchIntTemplates.LookupMode := true;
        //-NPR5.48 [342511]
        EventExchIntTemplates.Caption := StrSubstNo(ExchTemplateCaption,Format(ExchItemType,0,0));
        //+NPR5.48 [342511]
        EventExchIntTemplates.SetTableView(EventExchIntTemplate);
        if EventExchIntTemplates.RunModal = ACTION::LookupOK then begin
          EventExchIntTemplates.GetRecord(EventExchIntTemplate);
          exit(true);
        end;
        exit(false);
    end;

    local procedure SelectExchIntTemplateEntry(Job: Record Job;var EventExchIntTemplate: Record "Event Exch. Int. Template"): Boolean
    var
        EventExchIntTempEntry: Record "Event Exch. Int. Temp. Entry";
        EventExchIntTempEntries: Page "Event Exch. Int. Temp. Entries";
    begin
        if (EventExchIntTemplate.Code <> '') and EventExchIntTempEntry.Get(EventExchIntTemplate.Code,Job.RecordId) and EventExchIntTempEntry.Active then
          exit(true);
        EventExchIntTempEntry.SetRange("Source Record ID",Job.RecordId);
        EventExchIntTempEntries.LookupMode := true;
        EventExchIntTempEntries.SetTableView(EventExchIntTempEntry);
        if EventExchIntTempEntries.RunModal = ACTION::LookupOK then begin
          EventExchIntTempEntries.GetRecord(EventExchIntTempEntry);
          EventExchIntTemplate.Get(EventExchIntTempEntry.Code);
          exit(true);
        end;
        exit(false);
    end;

    procedure SetEmailPassword(var EventExchIntEmail: Record "Event Exch. Int. E-Mail")
    var
        EventStdDialog: Page "Event Standard Dialog";
        PasswordText: Text;
    begin
        EventExchIntEmail.TestField("E-Mail");
        EventStdDialog.UseForPassword();
        if EventStdDialog.RunModal = ACTION::OK then
          SaveEmailPassword(EventExchIntEmail,EventStdDialog.GetPassword());
    end;

    procedure SaveEmailPassword(var EventExchIntEmail: Record "Event Exch. Int. E-Mail";PasswordText: Text)
    var
        EncryptionManagement: Codeunit "Encryption Management";
        OutStream: OutStream;
    begin
        if EncryptionManagement.IsEncryptionPossible then
          PasswordText := EncryptionManagement.Encrypt(PasswordText);
        EventExchIntEmail.Password.CreateOutStream(OutStream);
        OutStream.Write(PasswordText);
    end;

    procedure GetEmailPassword(EventExchIntEmail: Record "Event Exch. Int. E-Mail") PasswordText: Text
    var
        InStream: InStream;
        EncryptionManagement: Codeunit "Encryption Management";
        PasswordNotSet: Label 'Password is not set for %1 %2. Please set it before using this e-mail account.';
    begin
        if not EventExchIntEmail.Password.HasValue then
          Error(PasswordNotSet,EventExchIntEmail.FieldCaption("E-Mail"),EventExchIntEmail."E-Mail");
        EventExchIntEmail.CalcFields(Password);
        EventExchIntEmail.Password.CreateInStream(InStream);
        InStream.Read(PasswordText);
        if EncryptionManagement.IsEncryptionPossible then
          exit(EncryptionManagement.Decrypt(PasswordText));
        exit(PasswordText);
    end;

    procedure TestEmailServerConnection(var EventExchIntEmail: Record "Event Exch. Int. E-Mail")
    var
        ExchService: DotNet ExchangeService;
        ConnectionSuccessMsg: Label 'Connection succeeded.';
        NameResolutionCollection: DotNet NameResolutionCollection;
        NameResolution: DotNet NameResolution;
        DateTimeObject: DotNet DateTime;
        ExchangeVersion: DotNet ExchangeVersion;
        ExchangeServerInfo: DotNet ExchangeServerInfo;
        Job: Record Job;
    begin
        EventExchIntEmail.TestField("E-Mail");
        EventVersionSpecificMgt.ExchServiceWrapperConstructor(EventExchIntEmail."E-Mail",GetEmailPassword(EventExchIntEmail));
        EventVersionSpecificMgt.ExchServiceWrapperService(ExchService);
        EventExchIntEmailGlobal := EventExchIntEmail;
        AutoDiscoverExchangeService(ExchService,Job,false);
        EventExchIntEmail."Exchange Server Url" := EventVersionSpecificMgt.ExchServiceWrapperGetExchangeServiceUrl();
        Message(ConnectionSuccessMsg);
    end;

    local procedure PrepareExchIntSummary(Job: Record Job;var EventExchIntSumBuffer: Record "Event Exc. Int. Summary Buffer")
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
        EventCalendarMgt: Codeunit "Event Calendar Management";
        ParentEntryNo: Integer;
    begin
        AddExchObjToBuffer(EventExchIntSumBuffer,0,EmailCustomerText,'','',EventExchIntSumBuffer."Entry No.",0);
        ExchItemType := ExchItemType::"E-Mail";
        GetOrganizerSetup(Job,FromSource);
        ParentEntryNo := EventExchIntSumBuffer."Entry No.";
        AddExchObjToBuffer(EventExchIntSumBuffer,1,FromText,EventExchIntEmailGlobal."E-Mail",FromSource,EventExchIntSumBuffer."Entry No.",ParentEntryNo);
        AddExchObjToBuffer(EventExchIntSumBuffer,1,ToText,Job."Bill-to E-Mail",GetObjectCaption(8,PAGE::"Event Card") + ': ' + Job.FieldCaption("Bill-to E-Mail"),EventExchIntSumBuffer."Entry No.",ParentEntryNo);

        AddExchObjToBuffer(EventExchIntSumBuffer,0,EmailTeamText,'','',EventExchIntSumBuffer."Entry No.",0);
        ParentEntryNo := EventExchIntSumBuffer."Entry No.";
        AddExchObjToBuffer(EventExchIntSumBuffer,1,FromText,EventExchIntEmailGlobal."E-Mail",FromSource,EventExchIntSumBuffer."Entry No.",ParentEntryNo);
        JobPlanningLine.SetRange("Job No.",Job."No.");
        JobPlanningLine.SetFilter("Resource E-Mail",'<>%1','');
        AddJobPlanningLineToBuffer(EventExchIntSumBuffer,JobPlanningLine,ToText,EventExchIntSumBuffer."Entry No.",ParentEntryNo);

        AddExchObjToBuffer(EventExchIntSumBuffer,0,AppointmentText,'','',EventExchIntSumBuffer."Entry No.",0);
        ExchItemType := ExchItemType::Appointment;
        GetOrganizerSetup(Job,FromSource);
        FromEmail := EventExchIntEmailGlobal."E-Mail";
        if (Job."Calendar Item Status" in [Job."Calendar Item Status"::" ",Job."Calendar Item Status"::Error]) then
          FromEmail := '';
        ParentEntryNo := EventExchIntSumBuffer."Entry No.";
        AddExchObjToBuffer(EventExchIntSumBuffer,1,SavedInText,FromEmail,FromSource,EventExchIntSumBuffer."Entry No.",ParentEntryNo);

        AddExchObjToBuffer(EventExchIntSumBuffer,0,MeetingReqText,'','',EventExchIntSumBuffer."Entry No.",0);
        ExchItemType := ExchItemType::"Meeting Request";
        GetOrganizerSetup(Job,FromSource);
        ParentEntryNo := EventExchIntSumBuffer."Entry No.";
        AddExchObjToBuffer(EventExchIntSumBuffer,1,FromText,FromEmail,FromSource,EventExchIntSumBuffer."Entry No.",ParentEntryNo);
        JobPlanningLine.Reset;
        EventCalendarMgt.SetJobPlanLineMeetingRequestSendFilter(Job,JobPlanningLine);
        AddJobPlanningLineToBuffer(EventExchIntSumBuffer,JobPlanningLine,ToText,EventExchIntSumBuffer."Entry No.",ParentEntryNo);
        EventExchIntSumBuffer.FindFirst;
    end;

    local procedure AddJobPlanningLineToBuffer(var EventExchIntSumBuffer: Record "Event Exc. Int. Summary Buffer";var JobPlanningLine: Record "Job Planning Line";ExchItem: Text;var EntryNo: Integer;ParentEntryNo: Integer)
    var
        Source: Text;
    begin
        Source := GetObjectCaption(8,PAGE::"Event Planning Lines Subpage") + ': ' + JobPlanningLine.FieldCaption("Resource E-Mail");
        case true of
          JobPlanningLine.IsEmpty:
            AddExchObjToBuffer(EventExchIntSumBuffer,1,ExchItem,'',Source,EventExchIntSumBuffer."Entry No.",ParentEntryNo);
          JobPlanningLine.Count = 1:
            begin
              JobPlanningLine.FindFirst;
              AddExchObjToBuffer(EventExchIntSumBuffer,1,ExchItem,JobPlanningLine."Resource E-Mail",Source,EventExchIntSumBuffer."Entry No.",ParentEntryNo);
            end;
          else begin
            AddExchObjToBuffer(EventExchIntSumBuffer,1,ExchItem,'',Source,EventExchIntSumBuffer."Entry No.",ParentEntryNo);
            ParentEntryNo := EventExchIntSumBuffer."Entry No.";
            JobPlanningLine.FindSet;
            repeat
              AddExchObjToBuffer(EventExchIntSumBuffer,2,'',JobPlanningLine."Resource E-Mail",'',EventExchIntSumBuffer."Entry No.",ParentEntryNo);
            until JobPlanningLine.Next = 0;
          end;
        end;
    end;

    local procedure AddExchObjToBuffer(var EventExchIntSumBuffer: Record "Event Exc. Int. Summary Buffer";Indentation: Integer;ExchItem: Text;EmailAccount: Text;Source: Text;var EntryNo: Integer;ParentEntryNo: Integer)
    begin
        EntryNo += 1;
        EventExchIntSumBuffer.Init;
        EventExchIntSumBuffer."Entry No." := EntryNo;
        EventExchIntSumBuffer."Parent Entry No." := ParentEntryNo;
        EventExchIntSumBuffer.Indentation := Indentation;
        EventExchIntSumBuffer."Exchange Item" := ExchItem;
        EventExchIntSumBuffer."E-mail Account" := EmailAccount;
        EventExchIntSumBuffer.Source := Source;
        EventExchIntSumBuffer.Insert;
    end;

    local procedure GetObjectCaption(ObjectType: Integer;ObjectID: Integer): Text
    var
        ObjectCaption: Record AllObjWithCaption;
    begin
        if ObjectCaption.Get(ObjectType,ObjectID) then
          exit(ObjectCaption."Object Caption");
        exit('');
    end;

    procedure ShowExchIntSummary(Job: Record Job)
    var
        EventExchIntSumBuffer: Record "Event Exc. Int. Summary Buffer" temporary;
    begin
        PrepareExchIntSummary(Job,EventExchIntSumBuffer);
        PAGE.Run(PAGE::"Event Exch. Int. Email Summary",EventExchIntSumBuffer);
    end;

    procedure ExchIntSummaryApplyStyleExpr(var EventExchIntSummaryBuffer: Record "Event Exc. Int. Summary Buffer" temporary;var ColorStyle: Text): Boolean
    var
        EventExchIntSummaryBuffer2: Record "Event Exc. Int. Summary Buffer" temporary;
        Apply: Boolean;
        ColorStyle2: Text;
    begin
        ColorStyle := 'Standard';
        EventExchIntSummaryBuffer2.Copy(EventExchIntSummaryBuffer,true);
        case EventExchIntSummaryBuffer.Indentation of
          0:
            begin
              ColorStyle := 'Strong';
              EventExchIntSummaryBuffer2.SetRange("Parent Entry No.",EventExchIntSummaryBuffer."Entry No.");
              if EventExchIntSummaryBuffer2.FindSet then
                repeat
                  Apply := Apply or ExchIntSummaryApplyStyleExpr(EventExchIntSummaryBuffer2,ColorStyle2);
                until (EventExchIntSummaryBuffer2.Next = 0) or Apply;
              if Apply then
                ColorStyle := 'Unfavorable';
              exit(Apply);
            end;
          1:
            if EventExchIntSummaryBuffer."E-mail Account" = '' then
              begin
                ColorStyle := 'Attention';
                EventExchIntSummaryBuffer2.Reset;
                if (EventExchIntSummaryBuffer2.Next <> 0) and (EventExchIntSummaryBuffer2.Indentation = 2) then begin
                  ColorStyle := 'Standard';
                  exit(false);
                end;
                exit(true);
              end;
          end;
        exit(false);
    end;

    procedure GetEventExchIntEmail(var EventExchIntEmail: Record "Event Exch. Int. E-Mail")
    begin
        //-NPR5.46 [323953]
        EventExchIntEmail := EventExchIntEmailGlobal;
        //+NPR5.46 [323953]
    end;
}


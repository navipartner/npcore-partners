codeunit 6059993 "NPR HL Integration Mgt."
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    SingleInstance = true;

    var
        _HLSetup: Record "NPR HL Integration Setup";
        _HLIntegrationEvents: Codeunit "NPR HL Integration Events";

#if Debug
    trigger OnRun()
    begin
        InvokeGetHLMemberListRequest();
    end;

    procedure InvokeGetHLMemberListRequest()
    var
        NcTask: Record "NPR Nc Task";
        ResponseText: Text;
    begin
        ResponseText := SendHeyLoyaltyRequest(NcTask, 'GET', StrSubstNo('%1/%2', GetHLMembersUrl(), 'c7d9d1e0-4de5-423b-9a3e-6f983a28f542'));
        Message(ResponseText);
    end;
#endif

    [TryFunction]
    procedure InvokeGetMemberListInfo(var ResponseJToken: JsonToken)
    begin
        ResponseJToken.ReadFrom(SendHeyLoyaltyRequest('GET', GetHLMemberListUrl()));
    end;

    [TryFunction]
    procedure InvokeGetHLMemberByID(HeyLoyaltyID: Text; var ResponseJToken: JsonToken)
    begin
        ResponseJToken.ReadFrom(SendHeyLoyaltyRequest('GET', StrSubstNo('%1/%2', GetHLMembersUrl(), HeyLoyaltyID)));
    end;

    [TryFunction]
    procedure InvokeGetHLMemberByContactInfo(HLMember: Record "NPR HL HeyLoyalty Member"; var ResponseJToken: JsonToken)
    var
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        TypeHelper: Codeunit "Type Helper";
        QueryFieldName: Option email,mobile;
        QueryFieldValue: Text;
        UrlPlaceholderLbl: Label '%1?filter[%2][eq][]=%3', Locked = true;
    begin
        case HLIntegrationMgt.RequiredContactInfo() of
            "NPR HL Required Contact Method"::Email:
                QueryFieldName := QueryFieldName::email;
            "NPR HL Required Contact Method"::Phone:
                QueryFieldName := QueryFieldName::mobile;
            else begin
                QueryFieldName := QueryFieldName::email;
                if (HLMember."E-mail Address" = '') and (HLMember."Phone No." <> '') then
                    QueryFieldName := QueryFieldName::mobile;
            end;
        end;
        if QueryFieldName = QueryFieldName::email then begin
            HLMember.TestField("E-mail Address");
            QueryFieldValue := HLMember."E-Mail Address";
        end else begin
            HLMember.TestField("Phone No.");
            QueryFieldValue := HLMember."Phone No.";
        end;
        ResponseJToken.ReadFrom(SendHeyLoyaltyRequest('GET', StrSubstNo(UrlPlaceholderLbl, GetHLMembersUrl(), Format(QueryFieldName), TypeHelper.UrlEncode(QueryFieldValue))));
    end;

    [TryFunction]
    procedure InvokeMemberCreateRequest(var NcTask: Record "NPR Nc Task"; UrlQueryString: Text; var HeyLoyaltyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetHLMembersUrl() + StrSubstNo('/%1', UrlQueryString);
        ResponseText := SendHeyLoyaltyRequest(NcTask, 'POST', Url);
        HeyLoyaltyResponse.ReadFrom(ResponseText);
    end;

    [TryFunction]
    procedure InvokeMemberUpdateRequest(var NcTask: Record "NPR Nc Task"; HeyLoyaltyMemberID: Text[50]; UrlQueryString: Text; var HeyLoyaltyResponse: JsonToken)
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetHLMembersUrl() + StrSubstNo('/%1%2', HeyLoyaltyMemberID, UrlQueryString);
        ResponseText := SendHeyLoyaltyRequest(NcTask, 'PATCH', Url);
        HeyLoyaltyResponse.ReadFrom(ResponseText);
    end;

    procedure InvokeHeybookingDBUpdateRequest(var NcTask: Record "NPR Nc Task")
    var
        IntegrationID: Code[20];
        Url: Text;
    begin
        Url := GetHeybookingUrl(IntegrationID) + StrSubstNo('/import/%1', IntegrationID);
        SendHeyLoyaltyRequest(NcTask, 'POST', Url);
    end;

    [TryFunction]
    procedure InvokeMemberDeleteRequest(var NcTask: Record "NPR Nc Task"; HeyLoyaltyMemberID: Text[50])
    var
        ResponseText: Text;
        Url: Text;
    begin
        Url := GetHLMembersUrl() + StrSubstNo('/%1', HeyLoyaltyMemberID);
        ResponseText := SendHeyLoyaltyRequest(NcTask, 'DELETE', Url);
    end;

    local procedure SendHeyLoyaltyRequest(RestMethod: text; Url: Text) ResponseText: Text
    var
        NcTask: Record "NPR Nc Task";
    begin
        Clear(NcTask);
        ResponseText := SendHeyLoyaltyRequest(NcTask, RestMethod, Url);
    end;

    local procedure SendHeyLoyaltyRequest(var NcTask: Record "NPR Nc Task"; RestMethod: text; Url: Text) ResponseText: Text
    begin
        if not TrySendHeyLoyaltyRequest(NcTask, RestMethod, Url, ResponseText) then
            Error(GetLastErrorText());
    end;

    [TryFunction]
    local procedure TrySendHeyLoyaltyRequest(var NcTask: Record "NPR Nc Task"; RestMethod: text; Url: Text; var ResponseText: Text)
    var
        Client: HttpClient;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestMsg: HttpRequestMessage;
        ResponseMsg: HttpResponseMessage;
        InStr: InStream;
        DateString: Text;
        EmptyResponseTxt: Label '{}', Locked = true;
        RequestError: Label 'Error sending request to HeyLoyalty: %1 %2/%3', Comment = '%1 - HTTP status code, %2 - response text, %3 - response content';
    begin
        ClearLastError();

        //Only heybooking requests will have request content payload
        if NcTask."Table No." = Database::"NPR TM Ticket Notif. Entry" then
            if NcTask."Data Output".HasValue() then begin
                NcTask."Data Output".CreateInStream(InStr);
                Content.WriteFrom(InStr);

                Content.GetHeaders(Headers);
                if Headers.Contains('Content-Type') then
                    Headers.Remove('Content-Type');
                Headers.Add('Content-Type', StrSubstNo('multipart/form-data; boundary="%1"', NcTask."Record Value"));

                RequestMsg.Content := Content;
            end;

        RequestMsg.SetRequestUri(Url);
        RequestMsg.Method(RestMethod);
        RequestMsg.GetHeaders(Headers);
        Headers.Add('Authorization', 'Basic ' + GetAuthSignature(DateString));
        Headers.Add('X-Request-Timestamp', DateString);
        Headers.Add('Accept', 'application/json');
        Headers.Add('User-Agent', 'Dynamics 365');

        Client.Send(RequestMsg, ResponseMsg);

        SaveResponse(NcTask, ResponseMsg);

        if not ResponseMsg.Content.ReadAs(ResponseText) then
            ResponseText := '';

        if not ResponseMsg.IsSuccessStatusCode() then
            Error(RequestError, ResponseMsg.HttpStatusCode(), ResponseMsg.ReasonPhrase(), ResponseText);

        if ResponseText = '' then
            ResponseText := EmptyResponseTxt;
    end;

    procedure GetAuthSignature(var DateString: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        CryptoMgt: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
        TextEnc: TextEncoding;
        AuthSignature: Text;
        Hash: Text;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        ApiSecretSecretText: SecretText;
#ENDIF
    begin
        _HLSetup.GetRecordOnce(false);
        DateString := Format(CurrentDateTime, 0, 9);

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        ApiSecretSecretText := _HLSetup."HeyLoyalty Api Secret";
        Hash := CryptoMgt.GenerateHash(DateString, ApiSecretSecretText, HashAlgorithmType::SHA256);
#ELSE
        Hash := CryptoMgt.GenerateHash(DateString, _HLSetup."HeyLoyalty Api Secret", HashAlgorithmType::SHA256);
#ENDIF
        Hash := Base64Convert.ToBase64(LowerCase(DelChr(Hash, '=', '-')), TextEnc::UTF8);
        AuthSignature := Base64Convert.ToBase64(StrSubstNo('%1:%2', _HLSetup."HeyLoyalty Api Key", Hash), TextEnc::UTF8);
        exit(AuthSignature);
    end;

    local procedure SaveResponse(var NcTask: Record "NPR Nc Task"; var ResponseMsg: HttpResponseMessage)
    var
        Content: HttpContent;
        InStr: InStream;
        OutStr: OutStream;
    begin
        Content := ResponseMsg.Content();

        clear(NcTask.Response);
        NcTask.Response.CreateInStream(InStr);
        Content.ReadAs(InStr);

        NcTask.Response.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
    end;

    local procedure GetHLMemberListUrl(): Text
    begin
        _HLSetup.GetRecordOnce(false);
        _HLSetup.TestField("HeyLoyalty Api Url");
        _HLSetup.TestField("HeyLoyalty Member List Id");
        exit(_HLSetup."HeyLoyalty Api Url" + '/lists/' + _HLSetup."HeyLoyalty Member List Id");
    end;

    local procedure GetHeybookingUrl(var IntegrationID: Code[20]): Text
    begin
        _HLSetup.GetRecordOnce(false);
        _HLSetup.TestField("Heycommerce/Booking DB Api Url");
        _HLSetup.TestField("Heybooking Integration Id");
        IntegrationID := _HLSetup."Heybooking Integration Id";
        exit(_HLSetup."Heycommerce/Booking DB Api Url" + '/booking');
    end;

    local procedure GetHLMembersUrl(): Text
    begin
        exit(GetHLMemberListUrl() + '/members');
    end;

    procedure RegisterWebhookListeners()
    var
        TenantWebService: Record "Tenant Web Service";
        WebServiceManagement: Codeunit "Web Service Management";
        ServiceNameTok: Label 'heyloyalty_services', Locked = true, MaxLength = 240;
    begin
        WebServiceManagement.CreateTenantWebService(TenantWebService."Object Type"::Page, Page::"NPR API - HL Webhook Requests", ServiceNameTok, true);
    end;

    procedure EnableWebhookRequestRetentionPolicy()
    var
#if (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
        RetentionPolicySetup: Record "Retention Policy Setup";
#else
        RetentionPolicy: Record "NPR Retention Policy";
#endif
    begin
#if (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
        if not RetentionPolicySetup.WritePermission() then
            exit;
        if not RetentionPolicySetup.Get(Database::"NPR HL Webhook Request") or RetentionPolicySetup.Enabled then
            exit;
        RetentionPolicySetup.Validate(Enabled, true);
        RetentionPolicySetup.Modify(true);
#else
        RetentionPolicy.DiscoverRetentionPolicyTables();
        if RetentionPolicy.Get(Database::"NPR HL Webhook Request") then
            if not RetentionPolicy.Enabled then begin
                RetentionPolicy.Enabled := true;
                RetentionPolicy.Modify();
            end;
#endif
    end;

    procedure SetupTaskProcessingJobQueue()
    begin
        Clear(_HLSetup);
        SetupTaskProcessingJobQueue(IsEnabled(Enum::"NPR HL Integration Area"::Members));
    end;

    local procedure SetupTaskProcessingJobQueue(Enable: Boolean)
    var
        DummyNcTask: Record "NPR Nc Task";
        JobQueueEntry: Record "Job Queue Entry";
        HLScheduleSend: Codeunit "NPR HL Schedule Send Tasks";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NcTaskListProcessing: Codeunit "NPR Nc Task List Processing";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        ParameterFilterTxt: text;
        FilterPlaceholderTok: Label '@*%1?%2*', Locked = true;
    begin
        if Enable then
            Codeunit.Run(Codeunit::"NPR HL Schedule Send Tasks", DummyNcTask)
        else begin
            ParameterFilterTxt := StrSubstNo(FilterPlaceholderTok, NcTaskListProcessing.ParamProcessor(), HLScheduleSend.GetHeyLoyaltyTaskProcessorCode(false));
            JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
            JobQueueEntry.SetRange("Object ID to Run", NcSetupMgt.TaskListProcessingCodeunit());
            JobQueueEntry.SetFilter("Parameter String", ParameterFilterTxt);
            if not JobQueueEntry.IsEmpty() then
                JobQueueMgt.CancelNpManagedJobs(JobQueueEntry);
        end;
    end;

    procedure SetupHeybookingTicketNotifProfile()
    var
        TicketNotifPrifile: Record "NPR TM Notification Profile";
        TicketNotifPrifileLine: Record "NPR TM Notif. Profile Line";
        CreateNotProfileQst: Label 'HeyLoyalty booking database integration requires a ticket notification profile, which is going to be used to send data from BC to HeyLoyalty.\Do you want the system to setup the profile for you now?';
    begin
        TicketNotifPrifileLine.SetRange("Notification Engine", TicketNotifPrifileLine."Notification Engine"::NPR_HEYLOYALTY);
        TicketNotifPrifileLine.SetRange(Blocked, false);
        if TicketNotifPrifileLine.IsEmpty() then
            if not Confirm(CreateNotProfileQst, true) then
                exit;
        CreateDefaultHeybookingTicketNotifProfile(TicketNotifPrifile);
        Commit();
        Page.Run(Page::"NPR TM Notif. Profile Card", TicketNotifPrifile);
    end;

    local procedure CreateDefaultHeybookingTicketNotifProfile(var TicketNotifPrifile: Record "NPR TM Notification Profile")
    var
        TicketNotifPrifileLine: Record "NPR TM Notif. Profile Line";
        ProfileDescrTxt: Label 'Send data to HeyLoyalty', MaxLength = 80;
        TicketAdmisDescrTxt: Label 'Each ticket admission (scan)', MaxLength = 80;
        WelcomeNotifDescrTxt: Label 'New tickets', MaxLength = 80;
    begin
        TicketNotifPrifile."Profile Code" := CopyStr(DataProcessingHandlerID(true), 1, MaxStrLen(TicketNotifPrifile."Profile Code"));
        if not TicketNotifPrifile.Find() then begin
            TicketNotifPrifile.Init();
            TicketNotifPrifile.Description := ProfileDescrTxt;
            TicketNotifPrifile.Insert();
        end else
            if TicketNotifPrifile.Blocked then begin
                TicketNotifPrifile.Blocked := false;
                TicketNotifPrifile.Insert();
            end;
        CreateHeybookingTicketNotifProfileLine(TicketNotifPrifile, TicketNotifPrifileLine."Notification Trigger"::WELCOME, WelcomeNotifDescrTxt);
        CreateHeybookingTicketNotifProfileLine(TicketNotifPrifile, TicketNotifPrifileLine."Notification Trigger"::ON_EACH_ADMISSION, TicketAdmisDescrTxt);
    end;

    local procedure CreateHeybookingTicketNotifProfileLine(TicketNotifPrifile: Record "NPR TM Notification Profile"; NotifTrigger: Integer; Description: Text[80])
    var
        TicketNotifPrifileLine: Record "NPR TM Notif. Profile Line";
    begin
        TicketNotifPrifileLine.SetRange("Profile Code", TicketNotifPrifile."Profile Code");
        TicketNotifPrifileLine.SetRange("Notification Engine", TicketNotifPrifileLine."Notification Engine"::NPR_HEYLOYALTY);
        TicketNotifPrifileLine.SetRange("Notification Trigger", NotifTrigger);
        if not TicketNotifPrifileLine.FindFirst() then begin
            TicketNotifPrifileLine.Init();
            TicketNotifPrifileLine."Profile Code" := TicketNotifPrifile."Profile Code";
            TicketNotifPrifileLine."Notification Engine" := TicketNotifPrifileLine."Notification Engine"::NPR_HEYLOYALTY;
            TicketNotifPrifileLine."Notification Trigger" := NotifTrigger;
            TicketNotifPrifileLine.Description := Description;
            TicketNotifPrifileLine."Line No." := 0;
            TicketNotifPrifileLine.Insert(true);
        end;
        TicketNotifPrifileLine.Blocked := false;
        TicketNotifPrifileLine.Units := 0;
        TicketNotifPrifileLine."Detention Time Seconds" := 0;
        TicketNotifPrifileLine.Modify();
    end;

    procedure IsEnabled(IntegrationArea: Enum "NPR HL Integration Area"): Boolean
    var
        AreaIsEnabled: Boolean;
        Handled: Boolean;
    begin
        _HLIntegrationEvents.OnCheckIfIntegrationAreaIsEnabled(IntegrationArea, AreaIsEnabled, Handled);
        if Handled then
            exit(AreaIsEnabled);

        _HLSetup.GetRecordOnce(false);
        if not _HLSetup."Enable Integration" then
            exit(false);
        case IntegrationArea of
            IntegrationArea::" ":
                exit(_HLSetup."Enable Integration");
            IntegrationArea::Members:
                exit(_HLSetup."Member Integration");
            IntegrationArea::Heybooking:
                exit(_HLSetup."Heybooking Integration Enabled");
        end;
    end;

    procedure IsIntegratedTable(IntegrationArea: Enum "NPR HL Integration Area"; TableId: Integer): Boolean
    var
        Handled: Boolean;
        TableIsIntegrated: Boolean;
    begin
        _HLIntegrationEvents.OnCheckIfIsIntegratedTable(IntegrationArea, TableId, TableIsIntegrated, Handled);
        if Handled then
            exit(TableIsIntegrated);

        case IntegrationArea of
            IntegrationArea::Members:
                TableIsIntegrated :=
                    TableId in
                        [Database::"NPR MM Member",
                         Database::"NPR MM Membership",
                         Database::"NPR MM Membership Role",
                         Database::"NPR MM Membership Entry",
                         Database::"NPR GDPR Consent Log",
                         Database::"NPR HL Selected MCF Option"];
            IntegrationArea::Heybooking:
                TableIsIntegrated := TableId = Database::"NPR TM Ticket Notif. Entry";
            else
                TableIsIntegrated := false;
        end;

        exit(TableIsIntegrated);
    end;

    [Obsolete('Is not needed anymore with the new way of handling outstanding data log entries we have in BC Saas.', '2023-10-28')]
    procedure IsInstantTaskEnqueue(): Boolean
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Instant Task Enqueue");
    end;

    [Obsolete('Is not needed anymore with the new way of handling outstanding data log entries we have in BC Saas.', '2023-10-28')]
    procedure ConfirmInstantTaskEnqueue(): Boolean
    var
        AllowedOnlyInTestEnvMsg: Label 'This mode is not recommended on live environments, as it may lead to incorrect data being sent to HeyLoyalty.\Are you sure you want to enable it?';
    begin
        exit(Confirm(AllowedOnlyInTestEnvMsg, false));
    end;

    procedure NonTempParameterError()
    var
        ErroMsgWithCallStackLbl: Label '%1\Call stack:\%2', Comment = '%1 - error message, %2 - error call stack';
    begin
        ClearLastError();
        RaiseNonTempParameterError();
        Error(ErroMsgWithCallStackLbl, GetLastErrorText(), GetLastErrorCallStack);
    end;

    [TryFunction]
    local procedure RaiseNonTempParameterError()
    var
        NotTempErr: Label 'Function call on a non-temporary record variable. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        Error(NotTempErr);
    end;

    procedure FormatAsHLDateTime(DateIn: Date): Text
    begin
        if DateIn = 0D then
            exit('');
        exit(FormatAsHLDateTime(CreateDateTime(DateIn, 0T)));
    end;

    procedure FormatAsHLDateTime(DateTimeIn: DateTime): Text
    begin
        if DateTimeIn = 0DT then
            exit('');
        exit(Format(DateTimeIn, 0, '<Year4>-<Month,2>-<Day,2> <Hours24,2>:<Minutes,2>:<Seconds,2>'));
    end;

    procedure HLMembershipCodeFieldID(): Text[50]
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Membership HL Field ID");
    end;

    procedure HLExternalMembershipNoFieldID(): Text[50]
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."External Membership No. HLF ID");
    end;

    procedure HLMembershipIssuedOnFieldID(): Text[50]
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Membership Issued On HLF ID");
    end;

    procedure HLMembershipValidUntilFieldID(): Text[50]
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Membership Valid Until HLF ID");
    end;

    procedure HLMembershipItemNoFieldID(): Text[50]
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Membership Item No. HLF ID");
    end;

    procedure ReadWebhookPayloadEnabled(): Boolean
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Read Member Data from Webhook");
    end;

    procedure UnsubscribeIfBlocked(): Boolean
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Unsubscribe if Blocked");
    end;

    procedure RequireGDPRApproval(): Boolean
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Require GDPR Approval");
    end;

    procedure RequireNewsletterSubscr(): Boolean
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Require Newsletter Subscrip.");
    end;

    procedure RequiredContactInfo(): Enum "NPR HL Required Contact Method"
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Required Contact Info");
    end;

    procedure SendHeybookingErrToEmail(): Text
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Send Heybooking Err. to E-Mail");
    end;

    procedure SendHeybookingFireEventsTrigger(): Boolean
    begin
        _HLSetup.GetRecordOnce(false);
        exit(_HLSetup."Send Heybooking Fire Events");
    end;

    procedure DataProcessingHandlerID(AutoCreate: Boolean): Code[20]
    begin
        if not AutoCreate then
            if _HLSetup.IsEmpty() then
                exit('');

        _HLSetup.GetRecordOnce(false);
        if _HLSetup."Data Processing Handler ID" = '' then begin
            SelectLatestVersion();
            _HLSetup.GetRecordOnce(true);
            if _HLSetup."Data Processing Handler ID" = '' then begin
                _HLSetup.SetDataProcessingHandlerIDToDefaultValue();
                _HLSetup.Modify();
            end;
        end;
        exit(_HLSetup."Data Processing Handler ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    begin
        SetupTaskProcessingJobQueue();
    end;

    #region Azure AD application
    internal procedure CreateAzureADApplication()
    var
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        PermissionSets: List of [Code[20]];
        AppDisplayNameLbl: Label 'NaviPartner HeyLoyalty integration', MaxLength = 50, Locked = true;
    begin
        PermissionSets.Add('D365 BUS FULL ACCESS');
#if BC17
        PermissionSets.Add('NP RETAIL');
#else
        PermissionSets.Add('NPR NP RETAIL');
#endif

        AADApplicationMgt.CreateAzureADApplicationAndSecret(AppDisplayNameLbl, SecretDisplayName(), PermissionSets);
    end;

    internal procedure CreateAzureADApplicationSecret()
    var
        AppInfo: ModuleInfo;
        AADApplication: Record "AAD Application";
        AADApplicationList: Page "AAD Application List";
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        NoAppsToManageErr: Label 'No AAD Apps with App Name like %1 to manage.';
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);

        AADApplication.SetFilter("App Name", '@' + AppInfo.Name);
        if AADApplication.IsEmpty() then
            Error(NoAppsToManageErr, AppInfo.Name);

        AADApplicationList.LookupMode(true);
        AADApplicationList.SetTableView(AADApplication);
        if AADApplicationList.RunModal() <> Action::LookupOK then
            exit;

        AADApplicationList.GetRecord(AADApplication);
        AADApplicationMgt.CreateAzureADSecret(AADApplication."Client Id", SecretDisplayName());
    end;

    local procedure SecretDisplayName(): Text
    var
        SecretDisplayNameLbl: Label 'NaviPartner HeyLoyalty integration - %1', Comment = '%1 = today''s date', Locked = true;
    begin
        exit(StrSubstNo(SecretDisplayNameLbl, Format(Today(), 0, 9)));
    end;
    #endregion

#if not (BC17 or BC18)
    #region clear configuration on company/environment copy
    [EventSubscriber(ObjectType::Report, Report::"Copy Company", 'OnAfterCreatedNewCompanyByCopyCompany', '', false, false)]
    local procedure HLOnAfterCreatedNewCompanyByCopyCompany(NewCompanyName: Text[30])
    begin
        DisableIntegration(NewCompanyName);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", 'OnClearCompanyConfig', '', false, false)]
    local procedure HLOnClearCompanyConfiguration(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    begin
        DisableIntegration(CompanyName);
    end;

    local procedure DisableIntegration(NewCompanyName: Text)
    var
        HLSetup: Record "NPR HL Integration Setup";
    begin
        if (NewCompanyName <> '') and (NewCompanyName <> CompanyName()) then
            HLSetup.ChangeCompany(NewCompanyName);
        if HLSetup.Get() and HLSetup."Enable Integration" then begin
            HLSetup."Enable Integration" := false;
            HLSetup.Modify();
        end;
    end;
    #endregion
#endif
}
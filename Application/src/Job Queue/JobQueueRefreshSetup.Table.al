table 6059870 "NPR Job Queue Refresh Setup"
{
    Access = Internal;
    Caption = 'Job Queue Refresh Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(20; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = OrganizationIdentifiableInformation;
            InitValue = true;

            trigger OnValidate()
            begin
                if Enabled then
                    InitTimeZone();
            end;
        }
        field(30; "Last Refreshed"; DateTime)
        {
            Caption = 'Last Refreshed';
            DataClassification = CustomerContent;
        }
        field(40; "Use External JQ Refresher"; Boolean)
        {
            Caption = 'Use External JQ Refresher';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            var
                ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
                EnvironmentInformation: Codeunit "Environment Information";
                TenantManageOptions: Enum "NPR Ext. JQ Refresher Options";
                HttpResponseMessage: HttpResponseMessage;
                ResponseText: Text;
                OnPremLbl: Label 'NP Retail External JQ Refresher integration is supported only on Cloud environment.\Current environment - ''OnPrem''.';
            begin
                if "Use External JQ Refresher" then begin
                    if EnvironmentInformation.IsOnPrem() then
                        Error(OnPremLbl);
                    ExternalJQRefresherMgt.CheckBaseAppVerion(true);
                end;
                ExternalJQRefresherMgt.PromptOnHttpCallsIfSandbox();
                if "Use External JQ Refresher" then begin
                    "Ext. JQ Refresher Enabled at" := CurrentDateTime();
                    InitWebserviceTimeZone();
                end else
                    "Ext. JQ Refresher Enabled at" := 0DT;
                Modify();

                if "Use External JQ Refresher" then begin
                    ExternalJQRefresherMgt.CreateTenantWebService();
                    ExternalJQRefresherMgt.ManageExternalJQRefresherTenants(TenantManageOptions::create, HttpResponseMessage);
                end else
                    ExternalJQRefresherMgt.ManageExternalJQRefresherTenants(TenantManageOptions::delete, HttpResponseMessage);
                HttpResponseMessage.Content().ReadAs(ResponseText);
                Message(ResponseText);
            end;
        }
        field(45; "Ext. JQ Refresher Enabled at"; DateTime)
        {
            Caption = 'Ext. JQ Refresher Enabled at';
            DataClassification = CustomerContent;
        }
        field(50; "Default Refresher User"; Text[250])
        {
            Caption = 'Default JQ Runner User Name';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-06-14';
            ObsoleteReason = 'Replaced by field "Default Refresher User Name"';
        }
        field(51; "Default Refresher User Name"; Code[50])
        {
            Caption = 'Default JQ Runner User Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateRefresherUser("Default Refresher User Name");
            end;
        }
        field(60; "Create Missing Custom JQs"; Boolean)
        {
            Caption = 'Create Missing Custom JQs';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-06-17';
            ObsoleteReason = 'Can only be changed from a PTE by subscribing to the OnRefreshserCheckIfCreateMissingCustomJobs() event of codeunit 6014663 "NPR Job Queue Management".';
        }
        field(70; "Default Job Time Zone"; Text[180])
        {
            Caption = 'Default Job Time Zone';
            DataClassification = SystemMetadata;
        }
        field(80; "Webservice Time Zone"; Text[180])
        {
            Caption = 'Webservice Time Zone';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                UpdateRefresherUsers();
            end;
        }
        field(90; "Language ID"; Integer)
        {
            Caption = 'Language ID';
            DataClassification = SystemMetadata;
            TableRelation = "Windows Language"."Language ID";

            trigger OnValidate()
            begin
                UpdateRefresherUsers();
            end;
        }
    }

    keys
    {
        key(PK; "Primary Key") { }
    }

    internal procedure GetSetup();
    begin
        if not Get() then begin
            Init();
            Insert();
            Commit();
        end;
    end;

    internal procedure InitTimeZone()
    var
        UserPersonalization: Record "User Personalization";
        SessionSetting: SessionSettings;
    begin
        if not UserPersonalization.Get(UserSecurityID()) then begin
            SessionSetting.Init();
            UserPersonalization."Time Zone" := CopyStr(SessionSetting.TimeZone(), 1, MaxStrLen(UserPersonalization."Time Zone"));
        end;
        "Default Job Time Zone" := UserPersonalization."Time Zone";
        InitWebserviceTimeZone();
    end;

    internal procedure InitWebserviceTimeZone()
    begin
        if "Webservice Time Zone" = '' then
            "Webservice Time Zone" := 'UTC';  //For online Business Central environments, the Services Default Time Zone setting is always set to UTC
    end;

    internal procedure GetWebserviceUserTimeZoneOffset() TimeZoneOffset: Duration
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        InitWebserviceTimeZone();
        TypeHelper.GetTimezoneOffset(TimeZoneOffset, "Webservice Time Zone");
    end;

    internal procedure UpdateRefresherUsers()
    var
        AADApplication: Record "AAD Application";
        ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
    begin
        ExternalJQRefresherMgt.FilterJQRefresherAADApps(AADApplication);
        if AADApplication.FindSet() then
            repeat
                UpdateRefresherUserSettings(AADApplication."User ID");
            until AADApplication.Next() = 0;
    end;

    internal procedure UpdateRefresherUser(RefresherUserName: Code[50])
    var
        User: Record User;
    begin
        if RefresherUserName = '' then
            exit;
        User.SetRange("User Name", RefresherUserName);
        if User.FindFirst() then
            UpdateRefresherUserSettings(User."User Security ID");
    end;

    local procedure UpdateRefresherUserSettings(RefresherUserSecurityID: Guid)
    var
        UserPersonalization: Record "User Personalization";
        SessionSetting: SessionSettings;
    begin
        InitWebserviceTimeZone();
        if not UserPersonalization.Get(RefresherUserSecurityID) then begin
            SessionSetting.Init();
            UserPersonalization.Init();
            UserPersonalization."User SID" := RefresherUserSecurityID;
            UserPersonalization."Language ID" := SessionSetting.LanguageId();
            UserPersonalization."Locale ID" := SessionSetting.LocaleId();
            UserPersonalization."Time Zone" := "Webservice Time Zone";
            UserPersonalization.Scope := UserPersonalization.Scope::Tenant;
            UserPersonalization.Insert();
        end;

        if ((UserPersonalization."Language ID" = "Language ID") or ("Language ID" = 0)) and
           (UserPersonalization."Time Zone" = "Webservice Time Zone") and
           (UserPersonalization.Scope = UserPersonalization.Scope::Tenant)
        then
            exit;

        if "Language ID" <> 0 then
            UserPersonalization."Language ID" := "Language ID";
        UserPersonalization."Time Zone" := "Webservice Time Zone";
        UserPersonalization.Scope := UserPersonalization.Scope::Tenant;
        UserPersonalization.Modify();
    end;

    internal procedure CreateMissingCustomJQs(): Boolean
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        Create: Boolean;
    begin
        JobQueueMgt.OnRefreshserCheckIfCreateMissingCustomJobs(Create);
        exit(Create);
    end;

    internal procedure GetTimeZoneName(): Text
#if not (BC17 or BC18)
    var
        TimeZoneSelection: Codeunit "Time Zone Selection";
#endif
    begin
#if not (BC17 or BC18)
        if Rec."Default Job Time Zone" = '' then
            exit('');
        exit(TimeZoneSelection.GetTimeZoneDisplayName(Rec."Default Job Time Zone"));
#else
        exit(Rec."Default Job Time Zone");
#endif
    end;
}
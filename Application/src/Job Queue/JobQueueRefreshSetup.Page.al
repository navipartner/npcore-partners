page 6150891 "NPR Job Queue Refresh Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'Job Queue Refresh Setup';
    AdditionalSearchTerms = 'JQ Refresher';
    DeleteAllowed = false;
    InsertAllowed = false;
    Extensible = false;
    PageType = Card;
    SourceTable = "NPR Job Queue Refresh Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether refreshing the list of NP Retail related job queue entries should be enabled. Default value is true.';
                }
                field("Use External JQ Refresher"; Rec."Use External JQ Refresher")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether refreshing the list of NP Retail related job queue entries should be performed by an external Job Queue Refresher Worker regardless of user activity.';
                }
                field("Create Missing Custom JQs"; Rec.CreateMissingCustomJQs())
                {
                    Caption = 'Create Missing Custom JQs';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the job queue refresher is allowed to automatically recreate missing job queue entries. This only affects custom jobs. Missing NP-protected job queue entries are always recreated. The setting can only be changed from a PTE by subscribing to the OnRefreshserCheckIfCreateMissingCustomJobs() event of codeunit 6014663 "NPR Job Queue Management".';
                    Editable = false;
                    Importance = Additional;
                }
                group(DefaultRefresherUser)
                {
                    ShowCaption = false;
                    Visible = _ExternalJQRefresherIsEnabled;
                    field("Default Refresher User Name"; Rec."Default Refresher User Name")
                    {
                        ApplicationArea = NPRRetail;
                        Tooltip = 'Specifies the default Job Queue runner user which will be used for refreshing job queue entries if no Job Queue runner is specified.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
                        begin
                            exit(ExternalJQRefresherMgt.LookupJQRefresherUserName(Text));
                        end;
                    }
                }
                field("Time Zone Name"; Rec.GetTimeZoneName())
                {
                    Caption = 'Default Job Time Zone';
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the time zone in which your job queues are usually set up and expected to run. This only applies to jobs with a defined "Starting Time" or "Ending Time". If the external job queue refresher is enabled, the system will adjust the starting and ending times of jobs from the time zone in which the job was originally created to the time zone in which the refresher user operates (in Business Central SaaS environment, this is UTC).';
#if not (BC17 or BC18)
                    trigger OnAssistEdit()
                    var
                        TimeZoneSelection: Codeunit "Time Zone Selection";
                        TimeZoneChangedMsg: Label 'You have changed the time zone. Please note that this change will take effect on the next job queue refresher run.';
                    begin
                        TimeZoneSelection.LookupTimeZone(Rec."Default Job Time Zone");
                        if xRec."Default Job Time Zone" <> Rec."Default Job Time Zone" then begin
                            Rec.Validate("Default Job Time Zone");
                            Rec.Modify();
                            Message(TimeZoneChangedMsg);
                        end;
                    end;
#endif
                }
                field("Language ID"; Rec."Language ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the language code for job queue runner users.';
                    Importance = Additional;
                    Visible = false;
                }
                field("Last Refreshed"; Rec."Last Refreshed FF")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when the list of NP Retail related job queue entries was refreshed the last time.';
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR Job Queue Refresh Logs");
                    end;
                }
            }
            part("Monitored Job Queues"; "NPR Monitored JQ Entries")
            {
                Caption = 'Monitored Jobs';
                UpdatePropagation = Both;
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(External)
            {
                Caption = 'External JQ Refresher';
                action("Refresh Now")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Refresh Now';
                    Image = Refresh;
                    Tooltip = 'Request an immediate refresh of job queues for the current company by the external job queue refresher.';
                    Enabled = _ExternalJQRefresherIsEnabled;

                    trigger OnAction()
                    var
                        HttpResponseMessage: HttpResponseMessage;
                        Window: Dialog;
                        ResponseText: Text;
                        RequestingRefreshTxt: Label 'Requesting job queue refresh...';
                        NotEnoughTimePassedErr: Label 'Please wait at least one minute after enabling the external refresher before requesting an immediate refresh.';
                    begin
                        if Format(Rec) <> Format(xRec) then
                            CurrPage.SaveRecord();
                        if Rec."Ext. JQ Refresher Enabled at" <> 0DT then
                            if CurrentDateTime() - Rec."Ext. JQ Refresher Enabled at" < 60000 then
                                Error(NotEnoughTimePassedErr);
                        Window.Open(RequestingRefreshTxt);
                        _ExternalJQRefresherMgt.SendRefreshRequest(HttpResponseMessage);
                        HttpResponseMessage.Content().ReadAs(ResponseText);
                        Sleep(2000);
                        Window.Close();
                        CurrPage.Update(false);
                        if ResponseText <> '' then
                            Message(ResponseText);
                    end;
                }

                action("Enable External JQ Refresher")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Enable External JQ Refresher';
                    Image = Start;
                    ToolTip = 'Enable the external job queue refresher.';
                    Visible = not _ExternalJQRefresherIsEnabled;

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord();
                        ToggleExtJQRefresher(true);
                        CurrPage.Update(false);
                    end;
                }
                action("Disable External JQ Refresher")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Disable External JQ Refresher';
                    Image = Stop;
                    ToolTip = 'Disable the external job queue refresher.';
                    Visible = _ExternalJQRefresherIsEnabled;

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord();
                        ToggleExtJQRefresher(false);
                        CurrPage.Update(false);
                    end;
                }
                action("Create External JQ Refresher User")
                {
                    Caption = 'Create External JQ Refresher User';
                    ToolTip = 'This action will create a new Microsoft Entra ID App and an accompanying client secret.';
                    ApplicationArea = NPRRetail;
                    Image = Setup;

                    trigger OnAction()
                    var
                        ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
                        WarningLbl: Label 'This action will create a new Entra App user for the External Job Queue Refresher and automatically register it. You don''t need to save Client ID and Client Secret values.\Are you sure you want to continue?';
                    begin
                        if not Confirm(WarningLbl) then
                            exit;
                        CurrPage.SaveRecord();
                        ExternalJQRefresherMgt.CreateExternalJQRefresherUser(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action("Show External JQ Refresher Users")
                {
                    Caption = 'Show External JQ Refresher Users';
                    ToolTip = 'Opens a list of all users registered for the external job queue refresher, along with their information.';
                    ApplicationArea = NPRRetail;
                    Image = Navigate;
                    RunObject = Page "NPR Job Queue Runner Users";
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ConfigurationsValidationNotification: Notification;
        HttpResponseMessage: HttpResponseMessage;
        DisablingExternalJQWorkerLbl: Label 'Disabling External JQ Refresher.';
    begin
        Rec.GetSetup();
        if Rec."Use External JQ Refresher" then begin
            ClearLastError();
            if not _ExternalJQRefresherMgt.ValidateExternalJQRefresherTenantManager() then
                Rec."Use External JQ Refresher" := false
            else
                if not _ExternalJQRefresherMgt.CheckBaseAppVerion(false) then begin
                    Rec."Use External JQ Refresher" := false;
                    _ExternalJQRefresherMgt.ManageExternalJQRefresherTenants("NPR Ext. JQ Refresher Options"::delete, HttpResponseMessage);
                    _ExternalJQRefresherMgt.TryThrowIncompatibleBaseVersion();
                end;
            if not Rec."Use External JQ Refresher" then begin
                Rec.Modify();
                ConfigurationsValidationNotification.Message(GetLastErrorText() + ' ' + DisablingExternalJQWorkerLbl);
                ConfigurationsValidationNotification.Scope := NotificationScope::LocalScope;
                ConfigurationsValidationNotification.Send();
            end;
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        _ExternalJQRefresherIsEnabled := Rec."Use External JQ Refresher";
    end;

    local procedure ToggleExtJQRefresher(Enable: Boolean)
    begin
        Rec.Validate("Use External JQ Refresher", Enable);
    end;

    var
        _ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
        _ExternalJQRefresherIsEnabled: Boolean;
}

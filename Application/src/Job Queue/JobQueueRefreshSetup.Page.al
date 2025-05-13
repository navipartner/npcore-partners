page 6150891 "NPR Job Queue Refresh Setup"
{
    ApplicationArea = NPRRetail;
    Caption = 'Job Queue Refresh Setup';
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
                group(DefaultRefresherUser)
                {
                    ShowCaption = false;
                    Visible = _ExternalJQRefresherIsEnabled;
                    field("Default Refresher User"; Rec."Default Refresher User")
                    {
                        ApplicationArea = NPRRetail;
                        Tooltip = 'Specifies the default Job Queue runner user which will be used for refreshing job queue entries if no Job Queue runner is specified.';
                    }
                }
                field("Last Refreshed"; Rec."Last Refreshed")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when the list of NP Retail related job queue entries was refreshed the last time.';
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
                    Tooltip = 'Trigger an immediate refresh of job queues for the current company by the external job queue refresher.';
                    Enabled = _ExternalJQRefresherIsEnabled;

                    trigger OnAction()
                    var
                        HttpResponseMessage: HttpResponseMessage;
                        ResponseText: Text;
                    begin
                        CurrPage.SaveRecord();
                        _ExternalJQRefresherMgt.SendRefreshRequest(HttpResponseMessage);
                        HttpResponseMessage.Content().ReadAs(ResponseText);
                        Message(ResponseText);
                        CurrPage.Update(false);
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
            }
        }
    }

    trigger OnOpenPage()
    var
        ConfigurationsValidationNotification: Notification;
        DisablingExternalJQWorkerLbl: Label 'Disabling External JQ Refresher.';
    begin
        Rec.GetSetup();
        if Rec."Use External JQ Refresher" then begin
            ClearLastError();
            if not _ExternalJQRefresherMgt.ValidateExternalJQRefresherTenantManager() then begin
                Rec."Use External JQ Refresher" := false;
                Rec.Modify();
                ConfigurationsValidationNotification.Message(GetLastErrorText() + ' ' + DisablingExternalJQWorkerLbl);
                ConfigurationsValidationNotification.Scope := NotificationScope::LocalScope;
                ConfigurationsValidationNotification.Send();
            end;
        end;
        _ExternalJQRefresherIsEnabled := Rec."Use External JQ Refresher";
    end;

    local procedure ToggleExtJQRefresher(Enable: Boolean)
    begin
        Rec.Validate("Use External JQ Refresher", Enable);
        Rec.Modify();
        _ExternalJQRefresherIsEnabled := Enable;
    end;

    var
        _ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
        _ExternalJQRefresherIsEnabled: Boolean;
}

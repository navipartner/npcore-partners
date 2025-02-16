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
                field("Last Refreshed"; Rec."Last Refreshed")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the date and time when the list of NP Retail related job queue entries was refreshed the last time.';
                }
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
                        ResponseText: Text;
                    begin
                        ResponseText := _ExternalJQRefresherMgt.SendRefreshRequest();
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
                        ToggleExtJQRefresher(true);
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
                        ToggleExtJQRefresher(false);
                    end;
                }
                action("Create External JQ Refresher Entra App")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Create External JQ Refresher Entra App';
                    Image = Action;
                    ToolTip = 'Running this action will try to create the JQ Runner Entra app.\This action can only be used by a user that is an Entra ID Global Administrator. The procedure will create a single-tenant Entra app on your behalf and ask for the required admin consent.';

                    trigger OnAction()
                    begin
                        _ExternalJQRefresherMgt.CreateSaaSSetup();
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
            if not _ExternalJQRefresherMgt.ValidateSaaSSetup() then begin
                ConfigurationsValidationNotification.Message(GetLastErrorText());
                ConfigurationsValidationNotification.Scope := NotificationScope::LocalScope;
                ConfigurationsValidationNotification.Send();
            end else if not _ExternalJQRefresherMgt.ValidateExternalJQRefresherTenantManager() then begin
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
        ClearLastError();
        if Enable and not _ExternalJQRefresherMgt.ValidateSaaSSetup() then
            Error(GetLastErrorText());
        Rec.Validate("Use External JQ Refresher", Enable);
        Rec.Modify();
        _ExternalJQRefresherIsEnabled := Enable;
    end;

    var
        _ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
        _ExternalJQRefresherIsEnabled: Boolean;
}

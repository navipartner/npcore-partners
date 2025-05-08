page 6150805 "NPR SaaS Import Setup"
{
    Caption = 'SaaS Import Setup';
    PageType = Card;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR SaaS Import Setup";
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(Settings)
            {
                Caption = 'Settings';

                field("Disable Database Triggers"; Rec."Disable Database Triggers")
                {
                    ToolTip = 'Disable built-in database subscribers for baseapp modules like graph mgt. change log';
                    ApplicationArea = NPRRetail;
                }
                field("Disable Kill Session"; Rec."Disable StopSession")
                {
                    ToolTip = 'Specifies the value of the Disable StopSession on Prepare Import field.';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Debug)
            {
                Caption = 'Debug';

                field("Max Background Sessions"; Rec."Max Background Sessions")
                {
                    ToolTip = 'Max number of background sessions to parse chunks in parallel';
                    ApplicationArea = NPRRetail;
                }
                field("Max Task Scheduler Tasks"; Rec."Max Task Scheduler Tasks")
                {
                    ToolTip = 'Max number of task scheduler tasks to queue up for chunk parsing in parallel';
                    ApplicationArea = NPRRetail;
                }
                field("Synchronous Processing"; Rec."Synchronous Processing")
                {
                    ToolTip = 'If enabled the webservice session will start parsing the chunk directly instead of attempting to offload it';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeleteJobQueueTasks)
            {
                Caption = 'Delete Job Queue Entries';
                ToolTip = 'Delete all job queue entries to prevent DB noise while importing data';
                Image = RemoveLine;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    Company: Record Company;
                    ConfirmDeleteLbl: Label 'Are you sure you want to delete all job queue entries in all companies?';
                    ScheduledTask: Record "Scheduled Task";
                begin
                    if not Confirm(ConfirmDeleteLbl) then
                        exit;

                    Company.FindSet();
                    repeat
                        JobQueueEntry.ChangeCompany(Company.Name);
                        JobQueueEntry.ModifyAll(Status, JobQueueEntry.Status::"On Hold");
                    until Company.Next() = 0;

                    if ScheduledTask.FindSet() then
                        repeat
                            if TaskScheduler.CancelTask(ScheduledTask.ID) then;
                        until ScheduledTask.Next() = 0;

                    ScheduledTask.DeleteAll();
                end;
            }

            action(DeleteDatalog)
            {
                Caption = 'Delete data log subscribers';
                ToolTip = 'Delete all datalog triggers to prevent noise while importing data';
                Image = RemoveLine;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    DataLogSetupTable: Record "NPR Data Log Setup (Table)";
                    ConfirmDeleteLbl: Label 'Are you sure you want to disable data log?';
                begin
                    if not Confirm(ConfirmDeleteLbl) then
                        exit;

                    DataLogSetupTable.DeleteAll();
                end;
            }

            action(DisableChangelog)
            {
                Caption = 'Disable Changelog';
                ToolTip = 'Disables the changelog to prevent noise while importing data';
                Image = RemoveLine;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ChangeLogSetup: Record "Change Log Setup";
                    DisableTriggersFirstLbl: Label 'You must disable database triggers first to prevent change log from re-activating';
                    ConfirmDisableLbl: Label 'Are you sure you want to disable the change log?';
                begin
                    if not Confirm(ConfirmDisableLbl) then
                        exit;

                    if not Rec."Disable Database Triggers" then
                        Error(DisableTriggersFirstLbl);

                    if not ChangeLogSetup.Get() then
                        exit;

                    ChangeLogSetup.Validate("Change Log Activated", false);
                    ChangeLogSetup.Modify();
                end;
            }

            action(CreateAADApp)
            {
                Caption = 'Create Entra ID App';
                ToolTip = 'Register a Microsoft Entra ID Application in tenant and prompt for permission. Must be run by a global admin in SaaS.';
                Image = ApprovalSetup;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
                    PermissionSets: List of [Code[20]];
                    AppDisplayNameLbl: Label 'NaviPartner SaaS Migration integration';
                    SecretDisplayNameLbl: Label 'NaviPartner SaaS Migration - %1', Comment = '%1 = today''s date';
                begin
                    PermissionSets.Add('D365 BUS FULL ACCESS');
                    PermissionSets.Add('NPR NP RETAIL');
                    AADApplicationMgt.CreateAzureADApplicationAndSecret(AppDisplayNameLbl, SecretDisplayNameLbl, PermissionSets);
                end;
            }

            action(SetupWebservice)
            {
                Caption = 'Setup Webservice';
                ToolTip = 'Configure the webservice so it can be consumed from outside';
                Image = Setup;
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    WebServiceManagement: Codeunit "Web Service Management";
                    WebServiceAggregate: Record "Web Service Aggregate";
                    PublishedSuccessLbl: Label 'Webservice published successfully:\\SOAP:\%1\\ODATA:\%2\\Company ID:\%3';
                    Company: Record Company;
                    UrlComponents: List of [Text];
                begin
                    Company.Get(CompanyName);
                    WebServiceManagement.CreateTenantWebService(WebServiceAggregate."Object Type"::Codeunit, Codeunit::"NPR SaaS Import Service", 'saasmigration', true);
                    UrlComponents := GetUrl(ClientType::Web).Split('/');

                    Message(PublishedSuccessLbl,
                        GetUrl(ClientType::SOAP, CompanyName, ObjectType::Codeunit, Codeunit::"NPR SaaS Import Service"),
                        StrSubstNo('https://api.businesscentral.dynamics.com/v2.0/%1/%2/ODataV4/saasmigration', UrlComponents.Get(4), UrlComponents.Get(5)),
                        Format(Company.Id, 0, 4).ToLower());
                end;
            }

        }
        area(Navigation)
        {
            action(ShowChunks)
            {
                Caption = 'Import Chunks';
                Image = List;
                ToolTip = 'Show all the chunks as they can be asynchronous with sender. Useful to debug';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ImportChunks: Record "NPR SaaS Import Chunk";
                begin
                    Page.Runmodal(Page::"NPR SaaS Import Chunk List", ImportChunks);
                end;
            }
            action(ShowBackgroundSessions)
            {
                Caption = 'Background Sessions';
                Image = List;
                ToolTip = 'Show all the background sessions as they can be asynchronous with sender. Useful to debug';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    BackgroundSessions: Record "NPR SaaS Import Bgn. Session";
                begin
                    Page.Runmodal(Page::"NPR SaaS Import Bgn.Sess. List", BackgroundSessions);
                end;
            }
            action(ShowScheduledTasks)
            {
                Caption = 'Scheduled Tasks';
                Image = List;
                ToolTip = 'Show all the scheduled tasks as they can be asynchronous with sender. Useful to debug';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    ImportTasks: Record "NPR SaaS Import Task";
                begin
                    Page.Runmodal(Page::"NPR SaaS Import Task List", ImportTasks);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
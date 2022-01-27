page 6151505 "NPR Nc Import Types"
{
    Extensible = False;
    Caption = 'NaviConnect Import Types';
    CardPageID = "NPR Nc Import Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Import Type";
    UsageCategory = Administration;
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Control6150621)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import List Update Handler"; Rec."Import List Update Handler")
                {

                    ToolTip = 'Specifies the update handler, which will be used for getting new entries into import list';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Keep Import Entries for"; Rec."Keep Import Entries for")
                {

                    ToolTip = 'Specifies the value of the Keep Import Entries for field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Import Codeunit ID"; Rec."Import Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Import Codeunit ID field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Lookup Codeunit ID"; Rec."Lookup Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Lookup Codeunit ID field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Webservice Enabled"; Rec."Webservice Enabled")
                {

                    ToolTip = 'Specifies the value of the Webservice Enabled field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Webservice Codeunit ID"; Rec."Webservice Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Webservice Codeunit ID field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Ftp Enabled"; Rec."Ftp Enabled")
                {

                    ToolTip = 'Specifies the value of the Ftp Enabled field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Sftp; Rec.Sftp)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Sftp field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Ftp Host"; Rec."Ftp Host")
                {

                    ToolTip = 'Specifies the value of the Ftp Host field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Download Ftp")
            {
                Caption = 'Download Ftp';
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = Rec."Ftp Enabled";

                ToolTip = 'Executes the Download Ftp action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
                begin
                    NcSyncMgt.DownloadFtpType(Rec);
                end;
            }
            action(SendTestErrorMail)
            {
                Caption = 'Send Test Error E-mail';
                Image = SendMail;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = (Rec."Send E-mail on Error");

                ToolTip = 'Executes the Send Test Error E-mail action';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    NcImportMgt: Codeunit "NPR Nc Import Mgt.";
                begin
                    NcImportMgt.SendTestErrorMail(Rec);
                end;
            }
            action(ShowSetup)
            {
                Caption = 'Show Setup Page';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Shows setup page for the update handler, which will be used for getting new entries into import list';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    NcDependencyFactory: Codeunit "NPR Nc Dependency Factory";
                    ImportListUpdater: Interface "NPR Nc Import List IUpdate";
                begin
                    if NcDependencyFactory.CreateNcImportListUpdater(ImportListUpdater, Rec) then
                        ImportListUpdater.ShowSetup(Rec);
                end;
            }
            action(SetupJobQueue)
            {
                Caption = 'Setup Job Queue';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Sets up a Job Queue Entry to automate creation and processing of import list entries for selected import type';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    JobQueueEntry: Record "Job Queue Entry";
                    JobQueueMgt: Codeunit "NPR Job Queue Management";
                begin
                    CurrPage.SaveRecord();
                    JobQueueMgt.ScheduleNcImportListProcessing(JobQueueEntry, Rec.Code, '');
                    if not IsNullGuid(JobQueueEntry.ID) then
                        Page.Run(Page::"Job Queue Entry Card", JobQueueEntry);
                end;
            }
        }
        area(Navigation)
        {
            action(ShowErrorLog)
            {
                Caption = 'Show Error Log';
                Image = ErrorLog;

                ToolTip = 'View error log entries for selected impor type entry.';
                ApplicationArea = NPRNaviConnect;

                trigger OnAction()
                var
                    NcDependencyFactory: Codeunit "NPR Nc Dependency Factory";
                    ImportListUpdater: Interface "NPR Nc Import List IUpdate";
                begin
                    if NcDependencyFactory.CreateNcImportListUpdater(ImportListUpdater, Rec) then
                        ImportListUpdater.ShowErrorLog(Rec);
                end;
            }
        }
    }
}

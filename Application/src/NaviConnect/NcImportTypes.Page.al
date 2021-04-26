page 6151505 "NPR Nc Import Types"
{
    Caption = 'NaviConnect Import Types';
    CardPageID = "NPR Nc Import Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Import Type";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control6150621)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Import List Update Handler"; Rec."Import List Update Handler")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the update handler, which will be used for getting new entries into import list';
                }
                field("Keep Import Entries for"; Rec."Keep Import Entries for")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Keep Import Entries for field';
                }
                field("Import Codeunit ID"; Rec."Import Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Codeunit ID field';
                }
                field("Lookup Codeunit ID"; Rec."Lookup Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lookup Codeunit ID field';
                }
                field("Webservice Enabled"; Rec."Webservice Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Webservice Enabled field';
                }
                field("Webservice Codeunit ID"; Rec."Webservice Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Webservice Codeunit ID field';
                }
                field("Ftp Enabled"; Rec."Ftp Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ftp Enabled field';
                }
                field(Sftp; Rec.Sftp)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sftp field';
                }
                field("Ftp Host"; Rec."Ftp Host")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ftp Host field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Download Ftp action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Send Test Error E-mail action';

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
                ApplicationArea = All;
                ToolTip = 'Shows setup page for the update handler, which will be used for getting new entries into import list';

                trigger OnAction()
                var
                    NcDependencyFactory: Codeunit "NPR Nc Dependency Factory";
                    ImportListUpdater: Interface "NPR Nc Import List IUpdate";
                begin
                    if NcDependencyFactory.CreateNcImportListUpdater(ImportListUpdater, Rec) then
                        ImportListUpdater.ShowSetup(Rec);
                end;
            }
        }
        area(Navigation)
        {
            action(ShowErrorLog)
            {
                Caption = 'Show Error Log';
                Image = ErrorLog;
                ApplicationArea = All;
                ToolTip = 'View error log entries for selected impor type entry.';

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

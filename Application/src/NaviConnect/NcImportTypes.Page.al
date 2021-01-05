page 6151505 "NPR Nc Import Types"
{
    Caption = 'NaviConnect Import Types';
    CardPageID = "NPR Nc Import Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR Nc Import Type";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control6150621)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Import List Update Handler"; "Import List Update Handler")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the update handler, which will be used for getting new entries into import list';
                }
                field("Keep Import Entries for"; "Keep Import Entries for")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Keep Import Entries for field';
                }
                field("Import Codeunit ID"; "Import Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Import Codeunit ID field';
                }
                field("Lookup Codeunit ID"; "Lookup Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Lookup Codeunit ID field';
                }
                field("Webservice Enabled"; "Webservice Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Webservice Enabled field';
                }
                field("Webservice Codeunit ID"; "Webservice Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Webservice Codeunit ID field';
                }
                field("Ftp Enabled"; "Ftp Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ftp Enabled field';
                }
                field(Sftp; Sftp)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Sftp field';
                }
                field("Ftp Host"; "Ftp Host")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ftp Host field';
                }
                field("Server File Enabled"; "Server File Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Server File Enabled field';
                }
                field("Server File Path"; "Server File Path")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Server File Path field';
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = "Ftp Enabled";
                ApplicationArea = All;
                ToolTip = 'Executes the Download Ftp action';

                trigger OnAction()
                var
                    NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
                begin
                    NcSyncMgt.DownloadFtpType(Rec);
                end;
            }
            action("Download Server File")
            {
                Caption = 'Download Server File';
                Image = Save;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = "Server File Enabled";
                ApplicationArea = All;
                ToolTip = 'Executes the Download Server File action';

                trigger OnAction()
                var
                    NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
                begin
                    NcSyncMgt.DownloadServerFile(Rec);
                end;
            }
            action(SendTestErrorMail)
            {
                Caption = 'Send Test Error E-mail';
                Image = SendMail;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Visible = ("Send E-mail on Error");
                ApplicationArea = All;
                ToolTip = 'Executes the Send Test Error E-mail action';

                trigger OnAction()
                var
                    TempNcImportEntry: Record "NPR Nc Import Entry" temporary;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
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
    }
}
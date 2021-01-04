page 6151505 "NPR Nc Import Types"
{
    // NC1.21/TTH /20151118  CASE 227358 New object
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20161005  CASE 242552 Added action: Download Ftp
    // NC2.01/MHA /20161014  CASE 255397 Added field 7 "Keep Import Entries for"
    // NC2.02/MHA /20170223  CASE 262318 Added action: Action: SendTestErrorMail and fields 300 "Send e-mail on Error" and 305 "E-mail address on Error"
    // NC2.12/MHA /20180502  CASE 313362 Added fields 200 "Ftp Enabled", 205 "Ftp Host", 400 "Server File Enabled", 405 "Server File Path"
    // NC2.16/MHA /20180917  CASE 328432 Added field 203 "Sftp"

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
                    //-NC2.01 [242552]
                    NcSyncMgt.DownloadFtpType(Rec);
                    //+NC2.01 [242552]
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
                    //-NC2.12 [313362]
                    NcSyncMgt.DownloadServerFile(Rec);
                    //+NC2.12 [313362]
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
                    //-NC2.02 [262318]
                    NcImportMgt.SendTestErrorMail(Rec);
                    //+NC2.02 [262318]
                end;
            }
        }
    }
}


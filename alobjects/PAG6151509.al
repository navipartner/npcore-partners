page 6151509 "Nc Import Type Card"
{
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20161012  CASE 242552 Added action: Download Ftp and field 235 "Ftp Backup Path"
    // NC2.01/MHA /20161014  CASE 255397 Added field 7 "Keep Import Entries for"
    // NC2.02/MHA /20170223  CASE 262318 Added action: Action: SendTestErrorMail and fields 300 "Send e-mail on Error" and 305 "E-mail address on Error"
    // NC2.08/BR  /20171221  CASE 295322 Added Field 240 "Ftp Binary"
    // NC2.12/MHA /20180502  CASE 313362 Added fields 400 "Server File Enabled", 405 "Server File Path" and Action "Download Server File"
    // NC2.16/MHA /20180917  CASE 328432 Added field 203 "Sftp"

    Caption = 'Import Type Card';
    PageType = Card;
    SourceTable = "Nc Import Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Keep Import Entries for";"Keep Import Entries for")
                {
                }
                field("Lookup Codeunit ID";"Lookup Codeunit ID")
                {
                }
                field("Import Codeunit ID";"Import Codeunit ID")
                {
                }
                field("Send e-mail on Error";"Send e-mail on Error")
                {
                }
                field("E-mail address on Error";"E-mail address on Error")
                {
                }
            }
            group(Transfer)
            {
                Caption = 'Transfer';
                group(API)
                {
                    Caption = 'API';
                    field("Webservice Enabled";"Webservice Enabled")
                    {
                    }
                    field("Webservice Codeunit ID";"Webservice Codeunit ID")
                    {
                    }
                    field("Webservice Function";"Webservice Function")
                    {
                    }
                }
                group(Ftp)
                {
                    Caption = 'Ftp';
                    field("Ftp Enabled";"Ftp Enabled")
                    {
                    }
                    field(Sftp;Sftp)
                    {
                    }
                    field("Ftp Host";"Ftp Host")
                    {
                    }
                    field("Ftp Port";"Ftp Port")
                    {
                    }
                    field("Ftp Binary";"Ftp Binary")
                    {
                    }
                    field("Ftp User";"Ftp User")
                    {
                    }
                    field("Ftp Password";"Ftp Password")
                    {
                    }
                    field("Ftp Passive";"Ftp Passive")
                    {
                    }
                    field("Ftp Path";"Ftp Path")
                    {
                    }
                    field("Ftp Backup Path";"Ftp Backup Path")
                    {
                    }
                    field("Ftp Filename";"Ftp Filename")
                    {
                    }
                }
                group(File)
                {
                    Caption = 'File';
                    field("Server File Enabled";"Server File Enabled")
                    {
                    }
                    field("Server File Path";"Server File Path")
                    {
                    }
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

                trigger OnAction()
                var
                    NcSyncMgt: Codeunit "Nc Sync. Mgt.";
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

                trigger OnAction()
                var
                    NcSyncMgt: Codeunit "Nc Sync. Mgt.";
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

                trigger OnAction()
                var
                    TempNcImportEntry: Record "Nc Import Entry" temporary;
                    NcImportMgt: Codeunit "Nc Import Mgt.";
                begin
                    //-NC2.02 [262318]
                    NcImportMgt.SendTestErrorMail(Rec);
                    //+NC2.02 [262318]
                end;
            }
        }
    }
}


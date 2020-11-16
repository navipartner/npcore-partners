page 6151509 "NPR Nc Import Type Card"
{
    // NC2.00/MHA /20160525  CASE 240005 NaviConnect
    // NC2.01/MHA /20161012  CASE 242552 Added action: Download Ftp and field 235 "Ftp Backup Path"
    // NC2.01/MHA /20161014  CASE 255397 Added field 7 "Keep Import Entries for"
    // NC2.02/MHA /20170223  CASE 262318 Added action: Action: SendTestErrorMail and fields 300 "Send e-mail on Error" and 305 "E-mail address on Error"
    // NC2.08/BR  /20171221  CASE 295322 Added Field 240 "Ftp Binary"
    // NC2.12/MHA /20180502  CASE 313362 Added fields 400 "Server File Enabled", 405 "Server File Path" and Action "Download Server File"
    // NC2.16/MHA /20180917  CASE 328432 Added field 203 "Sftp"
    // NPR5.55/CLVA/20200506 CASE 366790 Added Group XML Stylesheet
    // NPR5.55/MHA /20200604  CASE 408100 Added fields 520 "Max. Retry Count", 530 "Delay between Retries"

    Caption = 'Import Type Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR Nc Import Type";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Keep Import Entries for"; "Keep Import Entries for")
                {
                    ApplicationArea = All;
                }
                field("Lookup Codeunit ID"; "Lookup Codeunit ID")
                {
                    ApplicationArea = All;
                }
                field("Import Codeunit ID"; "Import Codeunit ID")
                {
                    ApplicationArea = All;
                }
                field("Send e-mail on Error"; "Send e-mail on Error")
                {
                    ApplicationArea = All;
                }
                field("E-mail address on Error"; "E-mail address on Error")
                {
                    ApplicationArea = All;
                }
                field("Max. Retry Count"; "Max. Retry Count")
                {
                    ApplicationArea = All;
                }
                field("Delay between Retries"; "Delay between Retries")
                {
                    ApplicationArea = All;
                }
            }
            group(Transfer)
            {
                Caption = 'Transfer';
                group(API)
                {
                    Caption = 'API';
                    field("Webservice Enabled"; "Webservice Enabled")
                    {
                        ApplicationArea = All;
                    }
                    field("Webservice Codeunit ID"; "Webservice Codeunit ID")
                    {
                        ApplicationArea = All;
                    }
                    field("Webservice Function"; "Webservice Function")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Ftp)
                {
                    Caption = 'Ftp';
                    field("Ftp Enabled"; "Ftp Enabled")
                    {
                        ApplicationArea = All;
                    }
                    field(Sftp; Sftp)
                    {
                        ApplicationArea = All;
                    }
                    field("Ftp Host"; "Ftp Host")
                    {
                        ApplicationArea = All;
                    }
                    field("Ftp Port"; "Ftp Port")
                    {
                        ApplicationArea = All;
                    }
                    field("Ftp Binary"; "Ftp Binary")
                    {
                        ApplicationArea = All;
                    }
                    field("Ftp User"; "Ftp User")
                    {
                        ApplicationArea = All;
                    }
                    field("Ftp Password"; "Ftp Password")
                    {
                        ApplicationArea = All;
                    }
                    field("Ftp Passive"; "Ftp Passive")
                    {
                        ApplicationArea = All;
                    }
                    field("Ftp Path"; "Ftp Path")
                    {
                        ApplicationArea = All;
                    }
                    field("Ftp Backup Path"; "Ftp Backup Path")
                    {
                        ApplicationArea = All;
                    }
                    field("Ftp Filename"; "Ftp Filename")
                    {
                        ApplicationArea = All;
                    }
                }
                group("File")
                {
                    Caption = 'File';
                    field("Server File Enabled"; "Server File Enabled")
                    {
                        ApplicationArea = All;
                    }
                    field("Server File Path"; "Server File Path")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group("XML Stylesheet")
            {
                Caption = 'XML Stylesheet';
                field(XMLStylesheetData; XMLStylesheetData)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;

                    trigger OnValidate()
                    begin
                        //-NPR5.55 [366790]
                        if "XML Stylesheet".HasValue then begin
                            CalcFields("XML Stylesheet");
                            Clear("XML Stylesheet");
                            Modify(false);
                        end;

                        if XMLStylesheetData <> '' then begin
                            Request.AddText(XMLStylesheetData);
                            "XML Stylesheet".CreateOutStream(OStream);
                            Request.Write(OStream);
                            Modify(false);
                        end;
                        //+NPR5.55 [366790]
                    end;
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

    trigger OnAfterGetRecord()
    begin
        //-NPR5.55 [366790]
        CalcFields("XML Stylesheet");

        if not "XML Stylesheet".HasValue then
            XMLStylesheetData := ''
        else begin
            "XML Stylesheet".CreateInStream(IStream);
            IStream.Read(XMLStylesheetData, MaxStrLen(XMLStylesheetData));
        end;
        //+NPR5.55 [366790]
    end;

    var
        XMLStylesheetData: Text;
        IStream: InStream;
        OStream: OutStream;
        Request: BigText;
}

